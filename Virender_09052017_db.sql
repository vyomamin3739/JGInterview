USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetTouchPointLogDataByUserID_New]    Script Date: 09-05-2017 5.03.58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Virender K.
-- Create date: 09 - 05- 2017
-- Description:	Get Data of Touch Point Log _ New
-- =============================================
CREATE PROCEDURE [dbo].[Sp_GetTouchPointLogDataByUserID_New]
	-- Add the parameters for the stored procedure here 
	@userID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from tblUserTouchPointLog t
	--Get The City Name
	JOIN tblInstallUsers ON t.UserID = tblInstallUsers.Id

	where t.UserID = @userID
	END	


GO
