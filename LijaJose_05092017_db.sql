------- Stored procedure to bookmark selected users:

USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[BookmarkInstallUsers]    Script Date: 09-05-2017 17:05:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lija
-- Create date: 08 May 2017
-- Description:	Bookmarks install users.
-- =============================================

ALTER PROCEDURE [dbo].[BookmarkInstallUsers] 
	@IDs IDs READONLY,
	@BookmarkStatus Varchar(5) = '12',
	@PreviousStatus varchar(20) ='',
	@BookmarkedUserId int = 0,
	@BookmarkedName VARCHAR(50) = '',
	@BookmarkedDate date ='',
	@BookmarkedTime varchar(50) =''
AS
BEGIN

	UPDATE dbo.tblInstallUsers 
	SET [Status] = @BookmarkStatus,
		PreviousStatus = @PreviousStatus,
		BookmarkedUserId = @BookmarkedUserId,
		BookmarkedName = @BookmarkedName,
		BookmarkedDate = @BookmarkedDate,
		BookmarkedTime = @BookmarkedTime
	WHERE Id IN (SELECT Id FROM @IDs)  
END

-------------Query to add required columns for Bookmarking.

USE [JGBS_Interview]
GO
ALTER TABLE [dbo].[tblInstallUsers]
ADD PreviousStatus VARCHAR(20) NULL, BookmarkedUserId INT NULL,BookmarkedName VARCHAR(50) NULL,BookmarkedDate DATE NULL, BookmarkedTime VARCHAR(50); 

---------------Updated below procedures with new columns added  in tblInstallUsers

1)[dbo].[UDP_UpdateInstallUsers] 
2)[dbo].[UDP_AddInstallUser]  

--------------Gets bookmark details for a install user

USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[GetBookmarkDetails]    Script Date: 09-05-2017 17:57:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lija
-- Create date: 09 May 2017
-- Description:	Gets Bookmark details for a install user.
-- =============================================
CREATE PROCEDURE [dbo].[GetBookmarkDetails] 
@id int
AS
BEGIN
	
	SELECT 
	PreviousStatus,
	BookmarkedUserId,
	BookmarkedName,
	BookmarkedDate,
	BookmarkedTime
	from tblInstallUsers
	where Id=@id
END

------------------Removes bookmarks or changes status to previous status.
USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[RemoveBookmarkInstallUser]    Script Date: 09-05-2017 22:20:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lija
-- Create date: 08 May 2017
-- Description:	Removes Bookmark or changes status to previous status for a install users.
-- =============================================

ALTER PROCEDURE [dbo].[RemoveBookmarkInstallUser] 
	@ID int
AS
BEGIN

	UPDATE dbo.tblInstallUsers 
	SET [Status] = PreviousStatus
	WHERE Id = @ID 
END
