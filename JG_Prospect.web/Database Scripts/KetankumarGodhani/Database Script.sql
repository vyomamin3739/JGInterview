----------------------------------------------------------------------------------------------------
          --17 APR 2017
----------------------------------------------------------------------------------------------------
--1 LIVE

CREATE FUNCTION [dbo].[GetParent]
(    
      @pid int
)
RETURNS @Output TABLE (
      parenttaskid int
)
AS
BEGIN
		;with name_tree as 
		(
		   select taskid, parenttaskid
		   from tblTask
		   where taskid = @pid
		   union all
		   select C.taskid, C.parenttaskid
		   from tblTask c
		   join name_tree p on C.taskid = P.parenttaskid
			AND C.taskid<>C.parenttaskid 
		)
		
		insert INTO @Output(parenttaskid) select top 1 parenttaskid from name_tree order by parenttaskid OPTION (MAXRECURSION 0)
		 
      RETURN
END
GO

--2  LIVE
ALTER PROCEDURE [dbo].[GetInProgressTasks] 
	-- Add the parameters for the stored procedure here
	@userid int,
	@desigid int,
	@search varchar(100),
	@PageIndex INT , 
	@PageSize INT 
AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1, (select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
				from dbo.tblTask as a
				Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
				where a.[Status]  in (1,2,3,4)
				AND  (
				t.FristName LIKE '%'+ @search + '%'  or
				t.LastName LIKE '%'+ @search + '%'  or
				t.Email LIKE '%' + @search +'%'  
				) and  tasklevel=1 and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1


		end
    else if @userid=0 and @desigid=0
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1, Assigneduser,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			    from dbo.tblTask as a 
			LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON c.UserId = t.Id  
				where a.[Status]  in (1,2,3,4)  and parenttaskid is not null

			)as x
			)
				
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid>0  
		begin

			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (


			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			LEFT OUTER JOIN tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (1,2,3,4) and b.UserId=@userid
			and parenttaskid is not null
			) as x  
			)

		SELECT *
		INTO #temp3
		FROM Tasklist
	
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid=0 and @desigid>0
		begin
			
			;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser

			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (1,2,3,4)  and b.DesignationID=@desigid
			and parenttaskid is not null
			) as x

			)

	
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

--3 LIVE
ALTER PROCEDURE [dbo].[GetClosedTasks] 
	-- Add the parameters for the stored procedure here
	@userid int,
	@desigid int,
	@search varchar(100),
	@PageIndex INT, 
	@PageSize INT
AS
BEGIN
DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
			where a.[Status]  in (7,8,9,10,11,12,14)
			AND  (
			t.FristName LIKE '%'+ @search + '%'  or
			t.LastName LIKE '%'+ @search + '%'  or
			t.Email LIKE '%' + @search +'%'  
			) 
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1

		end
   else if @userid=0 and @desigid=0
		begin
		;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (
			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask  as a
			LEFT OUTER JOIN tbltaskassignedusers as b ON a.TaskId = b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)
			 and a.parenttaskid is not null
			) as x
			)

			
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid>0  
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			left outer join tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14) and b.UserId=@userid
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp3
		FROM Tasklist

		
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
				
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid=0 and @desigid>0
		begin
		;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,' ' AS Assigneduser
			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)  and b.DesignationID=@desigid 
			and parenttaskid is not null

			) as x
			)
			
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
go

--4 LIVE

ALTER PROCEDURE [dbo].[SP_SaveOrDeleteTask]  
	 @Mode tinyint, -- 0:Insert, 1: Update, 2: Delete  
	 @TaskId bigint,  
	 @Title varchar(250),  
	 @Url varchar(250),
	 @Description varchar(MAX),  
	 @Status tinyint,  
	 @DueDate datetime = NULL,  
	 @Hours varchar(25),
	 @CreatedBy int,	
	 @InstallId varchar(50) = NULL,
	 @ParentTaskId bigint = NULL,
	 @TaskType tinyint = NULL,
	 @TaskLevel int,
	 @MainTaskId int,
	 @TaskPriority tinyint = null,
	 @IsTechTask bit = NULL,
	 @DeletedStatus	TINYINT = 9,
	 @Result int output
AS  
BEGIN  
  
	IF @Mode=0  
	  BEGIN  
		INSERT INTO tblTask 
				(
					Title,
					Url,
					[Description],
					[Status],
					DueDate,
					[Hours],
					CreatedBy,
					CreatedOn,
					IsDeleted,
					InstallId,
					ParentTaskId,
					TaskType,
					TaskPriority,
					IsTechTask,
					AdminStatus,
					TechLeadStatus,
					OtherUserStatus,
					TaskLevel,
					MainParentId
				)
		VALUES
				(
					@Title,
					@Url,
					@Description,
					@Status,
					@DueDate,
					@Hours,
					@CreatedBy,
					GETDATE(),
					0,
					@InstallId,
					@ParentTaskId,
					@TaskType,
					@TaskPriority,
					@IsTechTask,
					0,
					0,
					0,
					@TaskLevel,
					@MainTaskId
				)  
  
		SET @Result=SCOPE_IDENTITY ()  
  
		RETURN @Result  
	END  
	ELSE IF @Mode=1 -- Update  
	BEGIN    
		UPDATE tblTask  
		SET  
			Title=@Title,  
			Url = @Url,
			[Description]=@Description,  
			[Status]=@Status,  
			DueDate=@DueDate,  
			[Hours]=@Hours,
			[TaskType] = @TaskType,
			[TaskPriority] = @TaskPriority,
			[IsTechTask] = @IsTechTask
		WHERE TaskId=@TaskId  

		SET @Result= @TaskId
  
		RETURN @Result  
	END  
	ELSE IF @Mode=2 --Delete  
	BEGIN  
		UPDATE tblTask  
		SET  
			IsDeleted=1,
			[Status] = @DeletedStatus
		WHERE TaskId=@TaskId OR ParentTaskId=@TaskId  
	END  
  
END
GO


-----------------------------------------------------------------------------------------
					---18 APR 2017
-----------------------------------------------------------------------------------------

--1 LIVE

ALTER PROCEDURE [dbo].[GetFrozenTasks] 
	-- Add the parameters for the stored procedure here
	@search varchar(100),
	@startdate varchar(50),
	@enddate varchar(50),
	@PageIndex INT , 
	@PageSize INT ,
	@userid int,
	@desigid int

AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

if @search<>''
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
										select a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					tblInstallUsers as t 
					where a.TaskId=b.TaskId and b.UserId=c.UserId 
					and b.TaskId=c.TaskId and c.UserId=t.Id 
					AND  ( 
					t.FristName LIKE '%'+@search+'%'  or 
					t.LastName LIKE '%'+@search+'%'  or 
					t.Email LIKE '%'+@search+'%' 
					)  and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					union all

					SELECT a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,
					tbltaskapprovals as b,tblInstallUsers as t
					where   a.MainParentId=b.TaskId and b.UserId=t.Id  
					and b.UserId=c.UserId and b.TaskId=c.TaskId
					AND  (
					t.FristName LIKE '%'+ @search + '%'  or
					t.LastName LIKE '%'+ @search + '%'  or
					t.Email LIKE '%' + @search +'%'  
					) 
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp
		FROM Tasklist


		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
		FROM #temp AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp
	end
else if @userid=0 and @desigid=0
	begin
		;WITH 
		Tasklist AS
		(
			select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
			from (

				select distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
				 --and (DateCreated >=@startdate  
				 --and DateCreated <= @enddate) 

				union all

					SELECT distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a
					where 
					parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)


		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp1
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
		FROM #temp1 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1
	end

else if @userid>0  
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.UserId=@userid
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 
					union all
				
					SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskapprovals as c
					where   a.MainParentId=c.TaskId    and c.UserId=@userid
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp2
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
		FROM #temp2 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2
	end

else if @userid=0 and @desigid>0
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					--select a.* from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					--tblTaskdesignations as d
					--where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					 tblTaskdesignations as d
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  and c.TaskId=d.TaskId and d.DesignationID=@desigid
					 and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

					 union all

					 	SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,tblTaskdesignations as d,
					tbltaskapprovals as b 
					where   a.MainParentId=b.TaskId  and d.DesignationID=@desigid
					 and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp3
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
		FROM #temp3 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3
	end
END
GO

---------------------------------------------------
--2 LIVE


ALTER PROCEDURE [dbo].[GetNonFrozenTasks]
	-- Add the parameters for the stored procedure here

	@startdate varchar(50),
	@enddate varchar(50),
	@PageIndex INT , 
	@PageSize INT  
	

As
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1


;WITH 
	Tasklist AS
	(	
		select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
		Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,(select * from [GetParent](TaskId)) as MainParentId,
		case 
			when (ParentTaskId is null and  TaskLevel=1) then InstallId 
			when (tasklevel =1 and ParentTaskId>0) then 
				(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
			when (tasklevel =2 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
			(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
			+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
			when (tasklevel =3 and ParentTaskId>0) then
			(select InstallId from tbltask where taskid in (
			(select parenttaskid from tbltask where taskid in (
			(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
			+'-'+
				(select InstallId from tbltask where taskid in (
			(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
			+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
		end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
		from (
			select *
			from  tbltask where [Status]=1 
			--and (CreatedOn >=@startdate and CreatedOn <= @enddate ) 
		) as x
	)

	---- get CTE data into temp table
	SELECT *
	INTO #temp
	FROM Tasklist
	WHERE
		(AdminStatus is null OR AdminStatus = 0)
		and (TechLeadStatus is null OR TechLeadStatus = 0)
		and (OtherUserStatus is null OR OtherUserStatus = 0)


	SELECT * 
	FROM #temp 
	WHERE 
		RowNo_Order >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNo_Order < (@StartIndex + @PageSize)
		)
	ORDER BY RowNo_Order

	SELECT
	COUNT(*) AS TotalRecords
		FROM #temp
END
GO


-----------------------------------------------------------------------------------------
					---19 APR 2017
-----------------------------------------------------------------------------------------

--1
ALTER PROCEDURE [dbo].[GetInProgressTasks] 
	-- Add the parameters for the stored procedure here
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT , 
	@PageSize INT 
AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1, (select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
				from dbo.tblTask as a
				Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
				where a.[Status]  in (1,2,3,4)
				AND  (
				t.FristName LIKE '%'+ @search + '%'  or
				t.LastName LIKE '%'+ @search + '%'  or
				t.Email LIKE '%' + @search +'%'  
				) and  tasklevel=1 and parenttaskid is not null
				--order by [Status] desc

				--union all

				--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
				--from dbo.tblTask as a, tbltaskassignedusers as b,tblInstallUsers as t
				--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=t.Id
				--AND  (
				--t.FristName LIKE '%'+ @search + '%'  or
				--t.LastName LIKE '%'+ @search + '%'  or
				--t.Email LIKE '%' + @search +'%'  
				--) and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1


		end
    else if @userid='0' and @desigid=''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1, Assigneduser,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			    from dbo.tblTask as a 
			LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON c.UserId = t.Id  
				where a.[Status]  in (1,2,3,4)  and parenttaskid is not null

			)as x
			)
				
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin

			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (


			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			LEFT OUTER JOIN tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (1,2,3,4) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a, tbltaskassignedusers as b
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=@userid
			--and parenttaskid is not null
			 
			) as x  
			)

		SELECT *
		INTO #temp3
		FROM Tasklist
	
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
			
			;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser

			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (1,2,3,4)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a
			--LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			--LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.UserId
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = c.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.DesignationID=@desigid
			--and parenttaskid is not null
			) as x

			)

	
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

--2

ALTER PROCEDURE [dbo].[GetClosedTasks] 
	-- Add the parameters for the stored procedure here
	--@userid int,
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT, 
	@PageSize INT
AS
BEGIN
DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
			where a.[Status]  in (7,8,9,10,11,12,14)
			AND  (
			t.FristName LIKE '%'+ @search + '%'  or
			t.LastName LIKE '%'+ @search + '%'  or
			t.Email LIKE '%' + @search +'%'  
			) 
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1

		end
   else if @userid='0' and @desigid=''
		begin
		;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (
			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask  as a
			LEFT OUTER JOIN tbltaskassignedusers as b ON a.TaskId = b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)
			 and a.parenttaskid is not null
			) as x
			)

			
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			left outer join tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp3
		FROM Tasklist

		
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
				
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
		;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,' ' AS Assigneduser
			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,',')) 
			and parenttaskid is not null

			) as x
			)
			
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO



-----------------------------------------------------------------------------------------
					---21 APR 2017
-----------------------------------------------------------------------------------------

--1
ALTER PROCEDURE [dbo].[SP_GetInstallUsers]    

	@Key int,  
	@Designations varchar(4000),
	@ActiveStatus varchar(5) = '1',
	@InterviewDateStatus varchar(5) = '5',
	@OfferMadeStatus varchar(5) = '6'
	AS 
BEGIN    

	IF @Key = 1  
	BEGIN
		SELECT
			DISTINCT(Designation) AS Designation 
			FROM tblinstallUsers 
			WHERE Designation IS NOT NULL     
			ORDER BY Designation
	END
	ELSE IF @Key = 2
	BEGIN
			SELECT 
			DISTINCT FristName + ' ' + NameMiddleInitial + '. ' + LastName + '  ' + UserInstallId  AS FristName, tblinstallUsers.Id , [Status]
			FROM tblinstallUsers 
			WHERE  
			(FristName IS NOT NULL AND FristName <> '' )  AND 
			(tblinstallUsers.[Status] = @ActiveStatus OR 
			tblinstallUsers.[Status] = @OfferMadeStatus OR 
			tblinstallUsers.[Status] = @InterviewDateStatus
			) AND 
			(Designation IN (SELECT Item FROM dbo.SplitString(@Designations,','))
			OR
			Convert(Nvarchar(max),DesignationID)  IN (SELECT Item FROM dbo.SplitString(@Designations,','))
			)
			ORDER BY Status, FristName
	END	
END
GO

-----------------------------------------------------------------------------------------
					---22 APR 2017
-----------------------------------------------------------------------------------------

--1
ALTER PROCEDURE [dbo].[GetFrozenTasks] 
	-- Add the parameters for the stored procedure here
	@search varchar(100),
	@startdate varchar(50),
	@enddate varchar(50),
	@PageIndex INT , 
	@PageSize INT ,
	--@userid int,
	--@desigid int
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)=''

AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

if @search<>''
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
										select a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					tblInstallUsers as t 
					where a.TaskId=b.TaskId and b.UserId=c.UserId 
					and b.TaskId=c.TaskId and c.UserId=t.Id 
					AND  ( 
					t.FristName LIKE '%'+@search+'%'  or 
					t.LastName LIKE '%'+@search+'%'  or 
					t.Email LIKE '%'+@search+'%' 
					)  and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					union all

					SELECT a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,
					tbltaskapprovals as b,tblInstallUsers as t
					where   a.MainParentId=b.TaskId and b.UserId=t.Id  
					and b.UserId=c.UserId and b.TaskId=c.TaskId
					AND  (
					t.FristName LIKE '%'+ @search + '%'  or
					t.LastName LIKE '%'+ @search + '%'  or
					t.Email LIKE '%' + @search +'%'  
					) 
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp
		FROM Tasklist


		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp
	end
else if @userid='0' and @desigid=''
	begin
		;WITH 
		Tasklist AS
		(
			select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
			from (

				select distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
				 --and (DateCreated >=@startdate  
				 --and DateCreated <= @enddate) 

				union all

					SELECT distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a
					where 
					parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)


		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp1
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp1 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1
	end

else if @userid<>'0'
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.UserId in (select * from [dbo].[SplitString](@userid,','))
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 
					union all
				
					SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskapprovals as c
					where   a.MainParentId=c.TaskId    and c.UserId in (select * from [dbo].[SplitString](@userid,','))
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp2
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp2 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2
	end

else if @userid='0' and @desigid<>''
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					--select a.* from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					--tblTaskdesignations as d
					--where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					 tblTaskdesignations as d
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  and c.TaskId=d.TaskId and d.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
					 and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

					 union all

					 	SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,tblTaskdesignations as d,
					tbltaskapprovals as b 
					where   a.MainParentId=b.TaskId  and d.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
					 and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp3
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp3 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3
	end

--if @search<>''
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					select a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					tblInstallUsers as t 
--					where a.TaskId=b.TaskId and b.UserId=c.UserId 
--					and b.TaskId=c.TaskId and c.UserId=t.Id 
--					AND  ( 
--					t.FristName LIKE '%'+@search+'%'  or 
--					t.LastName LIKE '%'+@search+'%'  or 
--					t.Email LIKE '%'+@search+'%' 
--					)  and  tasklevel=1 and parenttaskid is not null
					
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 

--					union all

--					SELECT a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,
--					tbltaskapprovals as b,tblInstallUsers as t
--					where   a.MainParentId=b.TaskId and b.UserId=t.Id  
--					and b.UserId=c.UserId and b.TaskId=c.TaskId
--					AND  (
--					t.FristName LIKE '%'+ @search + '%'  or
--					t.LastName LIKE '%'+ @search + '%'  or
--					t.Email LIKE '%' + @search +'%'  
--					) 
--					and parenttaskid is not null
--			) as x
--		)

--		SELECT *
--		INTO #temp
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp
--	end
--else if @userid=0 and @desigid=0
--	begin
--		;WITH 
--		Tasklist AS
--		(
--			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--			case 
--				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--				when (tasklevel =1 and ParentTaskId>0) then 
--					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--				when (tasklevel =2 and ParentTaskId>0) then
--				 (select InstallId from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--				when (tasklevel =3 and ParentTaskId>0) then
--				(select InstallId from tbltask where taskid in (
--				(select parenttaskid from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--				+'-'+
--				 (select InstallId from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--			end as 'InstallId',Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--			from (

--				select distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
--					where a.TaskId=b.TaskId 
--					and b.TaskId=c.TaskId  
--					and  tasklevel=1 and parenttaskid is not null
--				 --and (DateCreated >=@startdate  
--				 --and DateCreated <= @enddate) 

--				union all

--					SELECT distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,
--					tbltaskapprovals as b 
--					where   a.MainParentId=b.TaskId  and
--					 b.TaskId=c.TaskId
--					and parenttaskid is not null


--			) as x
--		)


--		SELECT *
--		INTO #temp1
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp1 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp1
--	end

--else if @userid>0  
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
--					where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.UserId=@userid
--					and  tasklevel=1 and parenttaskid is not null
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 
--					union all
				
--					SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskapprovals as c
--					where   a.MainParentId=c.TaskId    and c.UserId=@userid
--					and parenttaskid is not null

--			) as x
--		)

--		SELECT *
--		INTO #temp2
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp2 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp2
--	end

--else if @userid=0 and @desigid>0
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					--select a.* from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					--tblTaskdesignations as d
--					--where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.TaskId=d.TaskId
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 

--					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					 tblTaskdesignations as d
--					where a.TaskId=b.TaskId 
--					and b.TaskId=c.TaskId  and c.TaskId=d.TaskId and d.DesignationID=@desigid
--					 and  tasklevel=1 and parenttaskid is not null

--					 union all

--					 	SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,tblTaskdesignations as d,
--					tbltaskapprovals as b 
--					where   a.MainParentId=b.TaskId  and d.DesignationID=@desigid
--					 and b.TaskId=c.TaskId and c.TaskId=d.TaskId
--					and parenttaskid is not null

--			) as x
--		)

--		SELECT *
--		INTO #temp3
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp3
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp3
--	end
END
GO

--2
ALTER PROCEDURE [dbo].[GetInProgressTasks] 
	-- Add the parameters for the stored procedure here
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT , 
	@PageSize INT 
AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],
			AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,
			convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1, (select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated, convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,
				(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
				,t.FristName + ' ' + t.LastName AS Assigneduser
				from dbo.tblTask as a
				Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
				where a.[Status]  in (1,2,3,4)
				AND  (
				t.FristName LIKE '%'+ @search + '%'  or
				t.LastName LIKE '%'+ @search + '%'  or
				t.Email LIKE '%' + @search +'%'  
				) and  tasklevel=1 and parenttaskid is not null
				--order by [Status] desc

				--union all

				--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
				--from dbo.tblTask as a, tbltaskassignedusers as b,tblInstallUsers as t
				--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=t.Id
				--AND  (
				--t.FristName LIKE '%'+ @search + '%'  or
				--t.LastName LIKE '%'+ @search + '%'  or
				--t.Email LIKE '%' + @search +'%'  
				--) and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1


		end
    else if @userid='0' and @desigid=''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1, 
			AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated, Assigneduser,ParentTaskTitle,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,a.[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,
				(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
				,t.FristName + ' ' + t.LastName AS Assigneduser
			    from dbo.tblTask as a 
			LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON c.UserId = t.Id  
				where a.[Status]  in (1,2,3,4)  and parenttaskid is not null

			)as x
			)
				
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin

			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (


			SELECT a.TaskId,[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,
			(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
			,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			LEFT OUTER JOIN tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (1,2,3,4) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a, tbltaskassignedusers as b
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=@userid
			--and parenttaskid is not null
			 
			) as x  
			)

		SELECT *
		INTO #temp3
		FROM Tasklist
	
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
			
			;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,a.[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,
			(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
			,t.FristName + ' ' + t.LastName AS Assigneduser

			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (1,2,3,4)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a
			--LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			--LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.UserId
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = c.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.DesignationID=@desigid
			--and parenttaskid is not null
			) as x

			)

	
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

--3
ALTER PROCEDURE [dbo].[GetClosedTasks] 
	-- Add the parameters for the stored procedure here
	--@userid int,
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT, 
	@PageSize INT
AS
BEGIN
DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
			where a.[Status]  in (7,8,9,10,11,12,14)
			AND  (
			t.FristName LIKE '%'+ @search + '%'  or
			t.LastName LIKE '%'+ @search + '%'  or
			t.Email LIKE '%' + @search +'%'  
			) 
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1

		end
   else if @userid='0' and @desigid=''
		begin
		;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (
			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask  as a
			LEFT OUTER JOIN tbltaskassignedusers as b ON a.TaskId = b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)
			 and a.parenttaskid is not null
			) as x
			)

			
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			left outer join tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp3
		FROM Tasklist

		
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
				
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
		;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel, t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,',')) 
			and parenttaskid is not null

			) as x
			)
			
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE [dbo].[GetNonFrozenTasks]
 -- Add the parameters for the stored procedure here

 @startdate varchar(50),
 @enddate varchar(50),
 @PageIndex INT , 
 @PageSize INT  
 

As
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1


;WITH 
 Tasklist AS
 ( 
  select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
  Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,(select * from [GetParent](TaskId)) as MainParentId,
  case 
   when (ParentTaskId is null and  TaskLevel=1) then InstallId 
   when (tasklevel =1 and ParentTaskId>0) then 
    (select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
   when (tasklevel =2 and ParentTaskId>0) then
    (select InstallId from tbltask where taskid in (
   (select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
   +'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid) + '-' +InstallId 
     
   when (tasklevel =3 and ParentTaskId>0) then
   (select InstallId from tbltask where taskid in (
   (select parenttaskid from tbltask where taskid in (
   (select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
   +'-'+
    (select InstallId from tbltask where taskid in (
   (select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
   +'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid) + '-' +InstallId 
  end as 'InstallId' ,Row_number() OVER (order by x.TaskId ) AS RowNo_Order
  from (
   select a.*
   ,(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
   ,t.FristName + ' ' + t.LastName AS Assigneduser
   from  tbltask a
   LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
   LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
   LEFT OUTER JOIN tblInstallUsers as t ON c.UserId = t.Id  
   where a.[Status]=1 and (a.AdminStatus is null OR a.AdminStatus = 0)
  and (a.TechLeadStatus is null OR a.TechLeadStatus = 0)
  and (a.OtherUserStatus is null OR a.OtherUserStatus = 0)

   --and (CreatedOn >=@startdate and CreatedOn <= @enddate ) 
  ) as x
 )

 ---- get CTE data into temp table
 SELECT *
 INTO #temp
 FROM Tasklist
 
 SELECT * 
 FROM #temp 
 WHERE 
 RowNo_Order >= @StartIndex AND 
 (
  @PageSize = 0 OR 
  RowNo_Order < (@StartIndex + @PageSize)
 )
 ORDER BY RowNo_Order


 SELECT
 COUNT(*) AS TotalRecords
  FROM #temp
END

ALTER PROCEDURE [dbo].[GetInProgressTasks] 
	-- Add the parameters for the stored procedure here
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT , 
	@PageSize INT 
AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],
			AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,
			convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1, (select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated, convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,
				(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
				,t.FristName + ' ' + t.LastName AS Assigneduser
				from dbo.tblTask as a
				Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
				where a.[Status]  in (1,2,3,4)
				AND  (
				t.FristName LIKE '%'+ @search + '%'  or
				t.LastName LIKE '%'+ @search + '%'  or
				t.Email LIKE '%' + @search +'%'  
				) and  tasklevel=1 and parenttaskid is not null
				--order by [Status] desc

				--union all

				--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
				--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
				--from dbo.tblTask as a, tbltaskassignedusers as b,tblInstallUsers as t
				--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=t.Id
				--AND  (
				--t.FristName LIKE '%'+ @search + '%'  or
				--t.LastName LIKE '%'+ @search + '%'  or
				--t.Email LIKE '%' + @search +'%'  
				--) and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1


		end
    else if @userid='0' and @desigid=''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1, 
			AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated, Assigneduser,ParentTaskTitle,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

				SELECT a.TaskId,a.[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
				Title,[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,
				(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
				,t.FristName + ' ' + t.LastName AS Assigneduser
			    from dbo.tblTask as a 
			LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON c.UserId = t.Id  
				where a.[Status]  in (1,2,3,4)  and parenttaskid is not null

			)as x
			)
				
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin

			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (


			SELECT a.TaskId,[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,
			(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
			,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			LEFT OUTER JOIN tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (1,2,3,4) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a, tbltaskassignedusers as b
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.UserId=@userid
			--and parenttaskid is not null
			 
			) as x  
			)

		SELECT *
		INTO #temp3
		FROM Tasklist
	
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
			
			;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],AdminStatusUpdated, TechLeadStatusUpdated, OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,ParentTaskTitle,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,a.[Description],a.[Status],a.AdminStatusUpdated, a.TechLeadStatusUpdated, a.OtherUserStatusUpdated,convert(Date,DueDate ) as DueDate,
			a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,
			(select Title from tbltask where TaskId=(select * from [GetParent](a.TaskId))) AS ParentTaskTitle
			,t.FristName + ' ' + t.LastName AS Assigneduser

			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (1,2,3,4)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
			--and  tasklevel=1 
			and parenttaskid is not null
			--order by [Status] desc

			--union all 

			--SELECT a.TaskId,a.[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			--a.Title,a.[Hours],a.InstallId,a.ParentTaskId,a.TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			--from dbo.tblTask as a
			--LEFT OUTER JOIN tblTaskdesignations as b ON a.TaskId = b.TaskId 
			--LEFT OUTER JOIN tbltaskassignedusers as c ON a.TaskId = c.UserId
			--LEFT OUTER JOIN tblInstallUsers as t ON t.Id = c.UserId
			--where a.[Status]  in (1,2,3,4) and a.TaskId=b.TaskId and b.DesignationID=@desigid
			--and parenttaskid is not null
			) as x

			)

	
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

--3
ALTER PROCEDURE [dbo].[GetClosedTasks] 
	-- Add the parameters for the stored procedure here
	--@userid int,
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)='',
	@search varchar(100),
	@PageIndex INT, 
	@PageSize INT
AS
BEGIN
DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @str nvarchar(700)
	set @str = ''
	if @search<>''
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			Left Join tbltaskassignedusers as b ON a.TaskId=b.TaskId
				Left Join tblInstallUsers as t ON b.UserId=t.Id
			where a.[Status]  in (7,8,9,10,11,12,14)
			AND  (
			t.FristName LIKE '%'+ @search + '%'  or
			t.LastName LIKE '%'+ @search + '%'  or
			t.Email LIKE '%' + @search +'%'  
			) 
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp1
		FROM Tasklist

			SELECT
			*
			FROM #temp1
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1

		end
   else if @userid='0' and @desigid=''
		begin
		;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (
			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask  as a
			LEFT OUTER JOIN tbltaskassignedusers as b ON a.TaskId = b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)
			 and a.parenttaskid is not null
			) as x
			)

			
		SELECT *
		INTO #temp2
		FROM Tasklist

			SELECT
			*
			FROM #temp2
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2

		end
	else if @userid<>'0'  
		begin
			;WITH 
		Tasklist AS
		(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId ,ParentTaskId,TaskLevel,t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a
			left outer join tbltaskassignedusers as b on a.TaskId=b.TaskId
			LEFT OUTER JOIN tblInstallUsers as t ON t.Id = b.UserId
			where a.[Status]  in (7,8,9,10,11,12,14) and b.UserId in (select * from [dbo].[SplitString](@userid,','))
			and parenttaskid is not null
			) as x
			)
			
		SELECT *
		INTO #temp3
		FROM Tasklist

		
			SELECT
			*
			FROM #temp3
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
				
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3

		end
	else if @userid='0' and @desigid<>''
		begin
		;WITH 
		Tasklist AS
		(	
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,Assigneduser,InstallId as InstallId1,(select * from [GetParent](TaskId)) as MainParentId,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by TaskId ) AS RowNo_Order
			from (

			SELECT a.TaskId,[Description],a.[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],a.InstallId,ParentTaskId,TaskLevel, t.FristName + ' ' + t.LastName AS Assigneduser
			from dbo.tblTask as a 
			LEFT JOIN tbltaskassignedusers as c ON a.TaskId = c.TaskId
			LEFT JOIN tblTaskdesignations as b ON b.TaskId = c.TaskId
			LEFT JOIN tblInstallUsers as t ON t.Id = c.UserId
			where a.[Status]  in (7,8,9,10,11,12,14)  and b.DesignationID in (select * from [dbo].[SplitString](@desigid,',')) 
			and parenttaskid is not null

			) as x
			)
			
		SELECT *
		INTO #temp4
		FROM Tasklist

			SELECT
			*
			FROM #temp4
			WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
			order by [Status] desc
			
		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp4

		end
END
GO

--4 Latest SP for recent taks
ALTER PROCEDURE [dbo].[GetFrozenTasks] 
	-- Add the parameters for the stored procedure here
	@search varchar(100),
	@startdate varchar(50),
	@enddate varchar(50),
	@PageIndex INT , 
	@PageSize INT ,
	--@userid int,
	--@desigid int
	@userid nvarchar(MAX)='0',
	@desigid nvarchar(MAX)=''

AS
BEGIN

DECLARE @StartIndex INT  = 0
SET @StartIndex = (@PageIndex * @PageSize) + 1

if @search<>''
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId,
			(select * from [GetParent](TaskId)) as MainParentId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
										select a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					tblInstallUsers as t 
					where a.TaskId=b.TaskId and b.UserId=c.UserId 
					and b.TaskId=c.TaskId and c.UserId=t.Id 
					AND  ( 
					t.FristName LIKE '%'+@search+'%'  or 
					t.LastName LIKE '%'+@search+'%'  or 
					t.Email LIKE '%'+@search+'%' 
					)  and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					union all

					SELECT a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,
					tbltaskapprovals as b,tblInstallUsers as t
					where   a.MainParentId=b.TaskId and b.UserId=t.Id  
					and b.UserId=c.UserId and b.TaskId=c.TaskId
					AND  (
					t.FristName LIKE '%'+ @search + '%'  or
					t.LastName LIKE '%'+ @search + '%'  or
					t.Email LIKE '%' + @search +'%'  
					) 
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp
		FROM Tasklist


		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			--(select * from [GetParent](Tasks.TaskId)) as MainParentId,
			t.MainParentId as MParentId,
			(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp
	end
else if @userid='0' and @desigid=''
	begin
		;WITH 
		Tasklist AS
		(
			select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			,(select * from [GetParent](TaskId)) as MainParentId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
			case 
				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
				when (tasklevel =1 and ParentTaskId>0) then 
					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
				when (tasklevel =2 and ParentTaskId>0) then
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
				when (tasklevel =3 and ParentTaskId>0) then
				(select InstallId from tbltask where taskid in (
				(select parenttaskid from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
				+'-'+
				 (select InstallId from tbltask where taskid in (
				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
			end as 'InstallId',Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
			from (

				select distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
				 --and (DateCreated >=@startdate  
				 --and DateCreated <= @enddate) 

				union all

					SELECT distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a
					where 
					parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
			) as x
			) as y
		)


		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp1
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours
			--,(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,t.MainParentId  as MParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp1 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp1
	end

else if @userid<>'0'
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			,(select * from [GetParent](TaskId)) as MainParentId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
					where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.UserId in (select * from [dbo].[SplitString](@userid,','))
					and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 
					union all
				
					SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskapprovals as c
					where   a.MainParentId=c.TaskId    and c.UserId in (select * from [dbo].[SplitString](@userid,','))
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp2
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours
			--,(select * from [GetParent](Tasks.TaskId)) as MainParentId
			,t.MainParentId  as MParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp2 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp2
	end

else if @userid='0' and @desigid<>''
	begin
		;WITH 
		Tasklist AS
		(
				select  distinct(TaskId) ,[Description],[Status],convert(Date,DueDate ) as DueDate,
			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,InstallId
			,(select * from [GetParent](TaskId)) as MainParentId
			FROM
			(
			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
				case 
					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
					when (tasklevel =1 and ParentTaskId>0) then 
						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
					when (tasklevel =2 and ParentTaskId>0) then
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
					when (tasklevel =3 and ParentTaskId>0) then
					(select InstallId from tbltask where taskid in (
					(select parenttaskid from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
					+'-'+
					 (select InstallId from tbltask where taskid in (
					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
				from (
					--select a.* from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					--tblTaskdesignations as d
					--where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					--and (DateCreated >=@startdate  
					--and DateCreated <= @enddate) 

					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
					 tblTaskdesignations as d
					where a.TaskId=b.TaskId 
					and b.TaskId=c.TaskId  and c.TaskId=d.TaskId and d.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
					 and  tasklevel=1 and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

					 union all

					 	SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
					from dbo.tblTask as a,  tbltaskassignedusers as c,tblTaskdesignations as d,
					tbltaskapprovals as b 
					where   a.MainParentId=b.TaskId  and d.DesignationID in (select * from [dbo].[SplitString](@desigid,','))
					 and b.TaskId=c.TaskId and c.TaskId=d.TaskId
					and parenttaskid is not null
					and (AdminStatus = 1 OR TechLeadStatus = 1)

			) as x
			) as y
		)

		SELECT *,Row_number() OVER (  order by Tasklist.TaskId ) AS RowNo_Order
		INTO #temp3
		FROM Tasklist

		SELECT
			Tasks.* ,
			TaskApprovals.Id AS TaskApprovalId,
			TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
			TaskApprovals.Description AS TaskApprovalDescription,
			TaskApprovals.UserId AS TaskApprovalUserId,
			TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT TOP 1 EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			--(select * from [GetParent](Tasks.TaskId)) as MainParentId
			t.MainParentId  as MParentId
			,(select Title from tbltask where TaskId=(select * from [GetParent](Tasks.TaskId))) AS ParentTaskTitle
		FROM #temp3 AS t
			INNER JOIN [TaskListView] Tasks ON t.TaskId = Tasks.TaskId
			LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId --AND TaskApprovals.IsAdminOrITLead = @Admin
		WHERE 
			RowNo_Order >= @StartIndex AND 
			(
				@PageSize = 0 OR 
				RowNo_Order < (@StartIndex + @PageSize)
			)
		ORDER BY RowNo_Order

		SELECT
		COUNT(*) AS TotalRecords
		FROM #temp3
	end

--if @search<>''
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					select a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					tblInstallUsers as t 
--					where a.TaskId=b.TaskId and b.UserId=c.UserId 
--					and b.TaskId=c.TaskId and c.UserId=t.Id 
--					AND  ( 
--					t.FristName LIKE '%'+@search+'%'  or 
--					t.LastName LIKE '%'+@search+'%'  or 
--					t.Email LIKE '%'+@search+'%' 
--					)  and  tasklevel=1 and parenttaskid is not null
					
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 

--					union all

--					SELECT a.TaskId,a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,
--					tbltaskapprovals as b,tblInstallUsers as t
--					where   a.MainParentId=b.TaskId and b.UserId=t.Id  
--					and b.UserId=c.UserId and b.TaskId=c.TaskId
--					AND  (
--					t.FristName LIKE '%'+ @search + '%'  or
--					t.LastName LIKE '%'+ @search + '%'  or
--					t.Email LIKE '%' + @search +'%'  
--					) 
--					and parenttaskid is not null
--			) as x
--		)

--		SELECT *
--		INTO #temp
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp
--	end
--else if @userid=0 and @desigid=0
--	begin
--		;WITH 
--		Tasklist AS
--		(
--			select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--			Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--			case 
--				when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--				when (tasklevel =1 and ParentTaskId>0) then 
--					(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--				when (tasklevel =2 and ParentTaskId>0) then
--				 (select InstallId from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--				when (tasklevel =3 and ParentTaskId>0) then
--				(select InstallId from tbltask where taskid in (
--				(select parenttaskid from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--				+'-'+
--				 (select InstallId from tbltask where taskid in (
--				(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--				+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--			end as 'InstallId',Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--			from (

--				select distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
--					where a.TaskId=b.TaskId 
--					and b.TaskId=c.TaskId  
--					and  tasklevel=1 and parenttaskid is not null
--				 --and (DateCreated >=@startdate  
--				 --and DateCreated <= @enddate) 

--				union all

--					SELECT distinct( a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,
--					tbltaskapprovals as b 
--					where   a.MainParentId=b.TaskId  and
--					 b.TaskId=c.TaskId
--					and parenttaskid is not null


--			) as x
--		)


--		SELECT *
--		INTO #temp1
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp1 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp1
--	end

--else if @userid>0  
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c
--					where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.UserId=@userid
--					and  tasklevel=1 and parenttaskid is not null
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 
--					union all
				
--					SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskapprovals as c
--					where   a.MainParentId=c.TaskId    and c.UserId=@userid
--					and parenttaskid is not null

--			) as x
--		)

--		SELECT *
--		INTO #temp2
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp2 
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp2
--	end

--else if @userid=0 and @desigid>0
--	begin
--		;WITH 
--		Tasklist AS
--		(
--				select  TaskId ,[Description],[Status],convert(Date,DueDate ) as DueDate,
--				Title,[Hours],ParentTaskId,TaskLevel,InstallId as InstallId1,AdminStatus,TechLeadStatus,OtherUserStatus,
--				case 
--					when (ParentTaskId is null and  TaskLevel=1) then InstallId 
--					when (tasklevel =1 and ParentTaskId>0) then 
--						(select installid from tbltask where taskid=x.parenttaskid) +'-'+InstallId  
--					when (tasklevel =2 and ParentTaskId>0) then
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
					
--					when (tasklevel =3 and ParentTaskId>0) then
--					(select InstallId from tbltask where taskid in (
--					(select parenttaskid from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))))
--					+'-'+
--					 (select InstallId from tbltask where taskid in (
--					(select parentTaskId from tbltask where   taskid=x.parenttaskid) ))
--					+'-'+ (select InstallId from tbltask where   taskid=x.parenttaskid)	+ '-' +InstallId 
--				end as 'InstallId' ,Row_number() OVER (  order by x.TaskId ) AS RowNo_Order
--				from (
--					--select a.* from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					--tblTaskdesignations as d
--					--where a.TaskId=b.TaskId and b.TaskId=c.TaskId and c.TaskId=d.TaskId
--					--and (DateCreated >=@startdate  
--					--and DateCreated <= @enddate) 

--					select distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					 from tbltask as a,tbltaskapprovals as b,tbltaskassignedusers as c,
--					 tblTaskdesignations as d
--					where a.TaskId=b.TaskId 
--					and b.TaskId=c.TaskId  and c.TaskId=d.TaskId and d.DesignationID=@desigid
--					 and  tasklevel=1 and parenttaskid is not null

--					 union all

--					 	SELECT distinct(a.TaskId),a.[Description],a.[Status],convert(Date,a.DueDate ) as DueDate,
--					a.Title,a.[Hours],a.InstallId ,a.ParentTaskId,a.TaskLevel,a.AdminStatus,a.TechLeadStatus,a.OtherUserStatus
--					from dbo.tblTask as a,  tbltaskassignedusers as c,tblTaskdesignations as d,
--					tbltaskapprovals as b 
--					where   a.MainParentId=b.TaskId  and d.DesignationID=@desigid
--					 and b.TaskId=c.TaskId and c.TaskId=d.TaskId
--					and parenttaskid is not null

--			) as x
--		)

--		SELECT *
--		INTO #temp3
--		FROM Tasklist
--		WHERE (AdminStatus = 1 OR TechLeadStatus = 1)


--		SELECT * 
--		FROM #temp3
--		WHERE 
--			RowNo_Order >= @StartIndex AND 
--			(
--				@PageSize = 0 OR 
--				RowNo_Order < (@StartIndex + @PageSize)
--			)
--		ORDER BY RowNo_Order

--		SELECT
--		COUNT(*) AS TotalRecords
--		FROM #temp3
--	end
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Live Publish 04282017

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------