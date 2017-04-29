-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE  [dbo].[GetParentChildTasks]
	-- Add the parameters for the stored procedure here
	@taskid int
AS
BEGIN
	
select TaskId,ParentTaskId,InstallId,MainParentId,Description,Title,URL,TaskLevel
 from tbltask where taskid=@taskid  and tasklevel=1
union all
--- level-2
select TaskId,ParentTaskId,InstallId,MainParentId,Description,Title,URL,TaskLevel
 from tbltask where parenttaskid=@taskid and tasklevel=2
union all
--- level-3
select TaskId,ParentTaskId,InstallId,MainParentId,Description,Title,URL,TaskLevel
 from tbltask where tasklevel=3 and parenttaskid in (select taskid from tbltask where parenttaskid=@taskid) 
END
GO
