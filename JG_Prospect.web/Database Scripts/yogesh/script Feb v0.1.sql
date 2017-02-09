DROP PROCEDURE UDP_deleteInstalluser
GO

/****** Object:  StoredProcedure [dbo].[DeleteInstallUsers]    Script Date: 03-Feb-17 9:59:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 19 Jan 2017
-- Description:	Deletes install users.
-- =============================================
ALTER PROCEDURE [dbo].[DeleteInstallUsers]
	@IDs IDs READONLY
AS
BEGIN

	DELETE
	FROM dbo.tblInstallUsers 
	WHERE Id IN (SELECT Id FROM @IDs)
	
 END
 GO

 /****** Object:  StoredProcedure [dbo].[DeleteInstallUsers]    Script Date: 03-Feb-17 9:59:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 19 Jan 2017
-- Description:	Deactivates install users.
-- =============================================
CREATE PROCEDURE [dbo].[DeactivateInstallUsers]
	@IDs IDs READONLY,
	@DeactiveStatus Varchar(5) = '3'
AS
BEGIN
	
	UPDATE dbo.tblInstallUsers 
	SET 
		[STATUS] = @DeactiveStatus
	WHERE Id IN (SELECT Id FROM @IDs)
       
 END
 GO


CREATE TABLE tblRoles_ApplicationFeatures
(
Id INT IDENTITY(1,1) UNIQUE NOT NULL,
RoleId INT NOT NULL,
ApplicationFeatureId INT NOT NULL,
IsEnabled BIT NOT NULL,
PRIMARY KEY(RoleId, ApplicationFeatureId)
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Feb 2017
-- Description:	Gets all application features for role.
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationFeaturesByRoleId]
	@RoleId INT
AS
BEGIN
	
	SELECT *
	FROM tblRoles_ApplicationFeatures
	WHERE RoleId = @RoleId
	ORDER BY RoleId

 END
 GO

 
/****** Object:  StoredProcedure [dbo].[sp_GetHrData]    Script Date: 07-Feb-17 10:24:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Yogesh    
-- Create date: 16 Jan 2017    
-- Description: Gets statictics and records for edit user page.    
-- =============================================    
-- [sp_GetHrData] '0','0','0', '0', NULL,NULL,0,10    
ALTER PROCEDURE [dbo].[sp_GetHrData]    
 @SearchTerm VARCHAR(15) = NULL,    
 @Status VARCHAR(50),    
 @DesignationId INT,    
 @SourceId INT,    
 @AddedByUserId INT,    
 @FromDate DATE = NULL,    
 @ToDate DATE = NULL,    
 @PageIndex INT = NULL,     
 @PageSize INT = NULL,    
 @SortExpression VARCHAR(50),    
 @InterviewDateStatus VARChAR(5) = '5',    
 @RejectedStatus VARChAR(5) = '9'    
AS    
BEGIN    
     
 SET NOCOUNT ON;    
     
 IF @Status = '0'    
 BEGIN    
  SET @Status = NULL    
 END    
    
 IF @DesignationId = '0'    
 BEGIN    
  SET @DesignationId = NULL    
 END    
     
 IF @SourceId = '0'    
 BEGIN    
  SET @SourceId = NULL    
 END    
    
 IF @AddedByUserId = 0    
 BEGIN    
  SET @AddedByUserId = NULL    
 END    
    
 DECLARE @StartIndex INT  = 0    
    
 IF @PageIndex IS NULL    
 BEGIN    
  SET @PageIndex = 0    
 END    
    
 IF @PageSize IS NULL    
 BEGIN    
  SET @PageSize = 0    
 END    
    
 SET @StartIndex = (@PageIndex * @PageSize) + 1    
    
 -- get statistics (Status)    
 SELECT     
  t.Status, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id     
 WHERE     
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.status    
     
 -- get statistics (AddedBy)    
 SELECT     
  ISNULL(U.Username, t2.FristName + '' + t2.LastName)  AS AddedBy, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t 
   
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblInstallUsers t2 ON t2.Id = t.SourceUser
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id 
      
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY U.Username,t2.FristName,t2.LastName    
    
 -- get statistics (Designation)    
 SELECT     
  t.Designation, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.Designation    
     
 -- get statistics (Source)    
 SELECT     
  t.Source, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.Source    
    
 -- get records    
 ;WITH SalesUsers    
 AS     
 (    
  SELECT     
   t.Id,    
   t.FristName,    
   t.LastName,    
   t.Phone,    
   t.Zip,    
   d.DesignationName AS Designation,    
   t.Status,    
   t.HireDate,    
   t.InstallId,    
   t.picture,     
   t.CreatedDateTime,     
   Isnull(s.Source,'') AS Source,    
   t.SourceUser,     
   ISNULL(U.Username,t2.FristName + ' ' + t2.LastName)  AS AddedBy ,    
    ISNULL (t.UserInstallId ,t.id) As UserInstallId ,     
   InterviewDetail = case     
         when (t.Status=@InterviewDateStatus) then CAST(coalesce(t.RejectionDate,'') AS VARCHAR)  + ' ' + coalesce(t.InterviewTime,'')     
         else '' end,    
   RejectDetail = case when (t.Status=@RejectedStatus ) then CAST(coalesce(t.RejectionDate,'') AS VARCHAR) + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'')     
         else '' end,    
   t.Email,     
   t.DesignationID,     
   ISNULL(t1.[UserInstallId] , t2.[UserInstallId]) As AddedByUserInstallId,     
   ISNULL(t1.Id,t2.Id) As AddedById ,     
   0 as 'EmpType'    
   ,NULL as [Aggregate] ,    
   t.Phone As PrimaryPhone ,     
   t.CountryCode,     
   t.Resumepath    
   --ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId    
   ,Task.TaskId AS 'TechTaskId',     
   Task.InstallId as 'TechTaskInstallId',    
   ROW_NUMBER() OVER    
       (    
        ORDER BY    
         CASE WHEN @SortExpression = 'Id ASC' THEN t.Id END ASC,    
         CASE WHEN @SortExpression = 'Id DESC' THEN t.Id END DESC,    
         CASE WHEN @SortExpression = 'Status ASC' THEN t.Status END ASC,    
         CASE WHEN @SortExpression = 'Status DESC' THEN t.Status END DESC,    
         CASE WHEN @SortExpression = 'FristName ASC' THEN t.FristName END ASC,    
         CASE WHEN @SortExpression = 'FristName DESC' THEN t.FristName END DESC,    
         CASE WHEN @SortExpression = 'Designation ASC' THEN d.DesignationName END ASC,    
         CASE WHEN @SortExpression = 'Designation DESC' THEN d.DesignationName END DESC,    
         CASE WHEN @SortExpression = 'Source ASC' THEN s.Source END ASC,    
         CASE WHEN @SortExpression = 'Source DESC' THEN s.Source END DESC,    
         CASE WHEN @SortExpression = 'Phone ASC' THEN t.Phone END ASC,    
         CASE WHEN @SortExpression = 'Phone DESC' THEN t.Phone END DESC,    
         CASE WHEN @SortExpression = 'Zip ASC' THEN t.Phone END ASC,    
         CASE WHEN @SortExpression = 'Zip DESC' THEN t.Phone END DESC,    
         CASE WHEN @SortExpression = 'CreatedDateTime ASC' THEN t.CreatedDateTime END ASC,    
         CASE WHEN @SortExpression = 'CreatedDateTime DESC' THEN t.CreatedDateTime END DESC    
            
       ) AS RowNumber    
  FROM     
   tblInstallUsers t     
    LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
    LEFT OUTER JOIN tblInstallUsers t2 ON t2.Id = t.SourceUser
	LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
    LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
    LEFT OUTER JOIN tbl_Designation d ON t.DesignationId = d.Id      
    LEFT JOIN tblSource s ON t.SourceId = s.Id    
	OUTER APPLY
	(
		SELECT TOP 1 tsk.TaskId, tsk.InstallId, ROW_NUMBER() OVER(ORDER BY u.TaskUserId DESC) AS RowNo
		FROM tblTaskAssignedUsers u 
				INNER JOIN tblTask tsk ON u.TaskId = tsk.TaskId AND 
					(tsk.ParentTaskId IS NOT NULL OR tsk.IsTechTask = 1) 
		WHERE u.UserId = t.Id
	) AS Task
  WHERE     
   (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
   AND     
   (    
    @SearchTerm IS NULL OR     
    1 = CASE    
      WHEN t.InstallId LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.FristName LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.LastName LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Email LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Phone LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.CountryCode LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Zip LIKE '%'+ @SearchTerm + '%' THEN 1    
      ELSE 0    
     END    
   )    
   AND ISNULL(t.Status,'') = ISNULL(@Status, ISNULL(t.Status,''))    
   AND ISNULL(d.Id,'') = ISNULL(@DesignationId, ISNULL(d.Id,''))    
   AND ISNULL(s.Id,'') = ISNULL(@SourceId, ISNULL(s.Id,''))    
   AND ISNULL(U.Id,'')=ISNULL(@AddedByUserId,ISNULL(U.Id,''))    
   AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
   AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 )    
    
 SELECT *    
 FROM SalesUsers    
 WHERE     
  RowNumber >= @StartIndex AND     
  (    
   @PageSize = 0 OR     
   RowNumber < (@StartIndex + @PageSize)    
  )    
    
 -- get record count    
 SELECT COUNT(*) AS TotalRecordCount    
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id        
   LEFT OUTER JOIN tbl_Designation d ON t.DesignationId = d.Id        
   LEFT JOIN tblSource s ON t.SourceId = s.Id    
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND     
  (    
   @SearchTerm IS NULL OR     
   1 = CASE    
     WHEN t.InstallId LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.FristName LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.LastName LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Email LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Phone LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.CountryCode LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Zip LIKE '%'+ @SearchTerm + '%' THEN 1    
     ELSE 0    
    END    
  )    
  AND ISNULL(t.Status,'') = ISNULL(@Status, ISNULL(t.Status,''))    
  AND ISNULL(d.Id,'') = ISNULL(@DesignationId, ISNULL(d.Id,''))    
  AND ISNULL(s.Id,'') = ISNULL(@SourceId, ISNULL(s.Id,''))    
  AND ISNULL(U.Id,'')=ISNULL(@AddedByUserId,ISNULL(U.Id,''))    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
END    
GO

/****** Object:  StoredProcedure [dbo].[sp_GetHrData]    Script Date: 08-Feb-17 9:20:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Yogesh    
-- Create date: 16 Jan 2017    
-- Description: Gets statictics and records for edit user page.    
-- =============================================    
-- [sp_GetHrData] '0','0','0', '0', NULL,NULL,0,10    
ALTER PROCEDURE [dbo].[sp_GetHrData]    
 @SearchTerm VARCHAR(15) = NULL,    
 @Status VARCHAR(50),    
 @DesignationId INT,    
 @SourceId INT,    
 @AddedByUserId INT,    
 @FromDate DATE = NULL,    
 @ToDate DATE = NULL,    
 @PageIndex INT = NULL,     
 @PageSize INT = NULL,    
 @SortExpression VARCHAR(50),    
 @InterviewDateStatus VARChAR(5) = '5',    
 @RejectedStatus VARChAR(5) = '9'    
AS    
BEGIN    
     
 SET NOCOUNT ON;    
     
 IF @Status = '0'    
 BEGIN    
  SET @Status = NULL    
 END    
    
 IF @DesignationId = '0'    
 BEGIN    
  SET @DesignationId = NULL    
 END    
     
 IF @SourceId = '0'    
 BEGIN    
  SET @SourceId = NULL    
 END    
    
 IF @AddedByUserId = 0    
 BEGIN    
  SET @AddedByUserId = NULL    
 END    
    
 DECLARE @StartIndex INT  = 0    
    
 IF @PageIndex IS NULL    
 BEGIN    
  SET @PageIndex = 0    
 END    
    
 IF @PageSize IS NULL    
 BEGIN    
  SET @PageSize = 0    
 END    
    
 SET @StartIndex = (@PageIndex * @PageSize) + 1    
    
 -- get statistics (Status)    
 SELECT     
  t.Status, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id     
 WHERE     
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.status    
     
 -- get statistics (AddedBy)    
 SELECT     
  ISNULL(U.Username, t2.FristName + '' + t2.LastName)  AS AddedBy, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t 
   
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblInstallUsers t2 ON t2.Id = t.SourceUser
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id 
      
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY U.Username,t2.FristName,t2.LastName    
    
 -- get statistics (Designation)    
 SELECT     
  t.Designation, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.Designation    
     
 -- get statistics (Source)    
 SELECT     
  t.Source, COUNT(*) [Count]     
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 GROUP BY t.Source    
    
 -- get records    
 ;WITH SalesUsers    
 AS     
 (    
  SELECT     
   t.Id,    
   t.FristName,    
   t.LastName,    
   t.Phone,    
   t.Zip,    
   d.DesignationName AS Designation,    
   t.Status,    
   t.HireDate,    
   t.InstallId,    
   t.picture,     
   t.CreatedDateTime,     
   Isnull(s.Source,'') AS Source,    
   t.SourceUser,     
   ISNULL(U.Username,t2.FristName + ' ' + t2.LastName)  AS AddedBy ,    
    ISNULL (t.UserInstallId ,t.id) As UserInstallId ,     
   InterviewDetail = case     
         when (t.Status=@InterviewDateStatus) then CAST(coalesce(t.RejectionDate,'') AS VARCHAR)  + ' ' + coalesce(t.InterviewTime,'')     
         else '' end,    
   RejectDetail = case when (t.Status=@RejectedStatus ) then CAST(coalesce(t.RejectionDate,'') AS VARCHAR) + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'')     
         else '' end,    
   t.Email,     
   t.DesignationID,     
   ISNULL(t1.[UserInstallId] , t2.[UserInstallId]) As AddedByUserInstallId,     
   ISNULL(t1.Id,t2.Id) As AddedById ,     
   0 as 'EmpType'    
   ,NULL as [Aggregate] ,    
   t.Phone As PrimaryPhone ,     
   t.CountryCode,     
   t.Resumepath  ,  
   --ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId ,   
   Task.TaskId AS 'TechTaskId',
   Task.ParentTaskId AS 'ParentTechTaskId', 
   Task.InstallId as 'TechTaskInstallId',    
   ROW_NUMBER() OVER    
       (    
        ORDER BY    
         CASE WHEN @SortExpression = 'Id ASC' THEN t.Id END ASC,    
         CASE WHEN @SortExpression = 'Id DESC' THEN t.Id END DESC,    
         CASE WHEN @SortExpression = 'Status ASC' THEN t.Status END ASC,    
         CASE WHEN @SortExpression = 'Status DESC' THEN t.Status END DESC,    
         CASE WHEN @SortExpression = 'FristName ASC' THEN t.FristName END ASC,    
         CASE WHEN @SortExpression = 'FristName DESC' THEN t.FristName END DESC,    
         CASE WHEN @SortExpression = 'Designation ASC' THEN d.DesignationName END ASC,    
         CASE WHEN @SortExpression = 'Designation DESC' THEN d.DesignationName END DESC,    
         CASE WHEN @SortExpression = 'Source ASC' THEN s.Source END ASC,    
         CASE WHEN @SortExpression = 'Source DESC' THEN s.Source END DESC,    
         CASE WHEN @SortExpression = 'Phone ASC' THEN t.Phone END ASC,    
         CASE WHEN @SortExpression = 'Phone DESC' THEN t.Phone END DESC,    
         CASE WHEN @SortExpression = 'Zip ASC' THEN t.Phone END ASC,    
         CASE WHEN @SortExpression = 'Zip DESC' THEN t.Phone END DESC,    
         CASE WHEN @SortExpression = 'CreatedDateTime ASC' THEN t.CreatedDateTime END ASC,    
         CASE WHEN @SortExpression = 'CreatedDateTime DESC' THEN t.CreatedDateTime END DESC    
            
       ) AS RowNumber    
  FROM     
   tblInstallUsers t     
    LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
    LEFT OUTER JOIN tblInstallUsers t2 ON t2.Id = t.SourceUser
	LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
    LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id       
    LEFT OUTER JOIN tbl_Designation d ON t.DesignationId = d.Id      
    LEFT JOIN tblSource s ON t.SourceId = s.Id    
	OUTER APPLY
	(
		SELECT TOP 1 tsk.TaskId, tsk.ParentTaskId, tsk.InstallId, ROW_NUMBER() OVER(ORDER BY u.TaskUserId DESC) AS RowNo
		FROM tblTaskAssignedUsers u 
				INNER JOIN tblTask tsk ON u.TaskId = tsk.TaskId AND 
					(tsk.ParentTaskId IS NOT NULL OR tsk.IsTechTask = 1) 
		WHERE u.UserId = t.Id
	) AS Task
  WHERE     
   (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
   AND     
   (    
    @SearchTerm IS NULL OR     
    1 = CASE    
      WHEN t.InstallId LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.FristName LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.LastName LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Email LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Phone LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.CountryCode LIKE '%'+ @SearchTerm + '%' THEN 1    
      WHEN t.Zip LIKE '%'+ @SearchTerm + '%' THEN 1    
      ELSE 0    
     END    
   )    
   AND ISNULL(t.Status,'') = ISNULL(@Status, ISNULL(t.Status,''))    
   AND ISNULL(d.Id,'') = ISNULL(@DesignationId, ISNULL(d.Id,''))    
   AND ISNULL(s.Id,'') = ISNULL(@SourceId, ISNULL(s.Id,''))    
   AND ISNULL(U.Id,'')=ISNULL(@AddedByUserId,ISNULL(U.Id,''))    
   AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
   AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
 )    
    
 SELECT *    
 FROM SalesUsers    
 WHERE     
  RowNumber >= @StartIndex AND     
  (    
   @PageSize = 0 OR     
   RowNumber < (@StartIndex + @PageSize)    
  )    
    
 -- get record count    
 SELECT COUNT(*) AS TotalRecordCount    
 FROM     
  tblInstallUsers t     
   LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser    
   LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id    
   LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id        
   LEFT OUTER JOIN tbl_Designation d ON t.DesignationId = d.Id        
   LEFT JOIN tblSource s ON t.SourceId = s.Id    
 WHERE      
  (t.UserType = 'SalesUser' OR t.UserType = 'sales')    
  AND     
  (    
   @SearchTerm IS NULL OR     
   1 = CASE    
     WHEN t.InstallId LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.FristName LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.LastName LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Email LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Phone LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.CountryCode LIKE '%'+ @SearchTerm + '%' THEN 1    
     WHEN t.Zip LIKE '%'+ @SearchTerm + '%' THEN 1    
     ELSE 0    
    END    
  )    
  AND ISNULL(t.Status,'') = ISNULL(@Status, ISNULL(t.Status,''))    
  AND ISNULL(d.Id,'') = ISNULL(@DesignationId, ISNULL(d.Id,''))    
  AND ISNULL(s.Id,'') = ISNULL(@SourceId, ISNULL(s.Id,''))    
  AND ISNULL(U.Id,'')=ISNULL(@AddedByUserId,ISNULL(U.Id,''))    
  AND CAST(t.CreatedDateTime as date) >= CAST(ISNULL(@FromDate,t.CreatedDateTime) as date)     
  AND CAST(t.CreatedDateTime as date) <= CAST(ISNULL(@ToDate,t.CreatedDateTime) as date)    
END
GO

