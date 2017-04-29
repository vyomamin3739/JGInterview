USE [JGBS_Interview]
GO

/****** Object:  Table [dbo].[tblRejectionReason]    Script Date: 4/21/2017 10:45:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblRejectionReason](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Reason] [varchar](100) NULL,
 CONSTRAINT [PK_tblRejectionReason] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
-- =============================================
-- Author:		<Sonali Agarwal>
-- Create date: <21Apr,2017>
-- Description:	<Get details from the table tblRejectionReason>
-- =============================================
ALTER PROCEDURE [dbo].[UDP_GetRejectionReason]	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Id, Reason FROM tblRejectionReason
	ORDER BY Reason
END
GO
-- =============================================
-- Author:		<Sonali Agarwal>
-- Create date: <21Apr,2017>
-- Description:	<Check if a record with same reason exists in the table tblRejectionReason>
-- =============================================
create PROCEDURE [dbo].[UDP_CheckDuplicateRejectionReason]	-- Add the parameters for the stored procedure here
@Reason varchar(100) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT Id,Reason FROM tblRejectionReason
	WHERE Reason=@Reason
END
--modified/created by Other Party
GO
-- =============================================
-- Author:		<Sonali Agarwal>
-- Create date: <21Apr,2017>
-- Description:	<Insert record in the table tblRejectionReason>
-- =============================================
ALTER PROCEDURE [dbo].[UDP_AddRejectionReason]	-- Add the parameters for the stored procedure here
@Reason varchar(100) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[tblRejectionReason]
           (Reason)
     VALUES
           (@Reason)

		   SELECT Id,Reason
			 FROM tblRejectionReason

END
--modified/created by Other Party
GO
-- =============================================
-- Author:		<Sonali Agarwal>
-- Create date: <21Apr,2017>
-- Description:	<Delete record from the table tblRejectionReason>
-- =============================================
create PROCEDURE [dbo].[UDP_DeleteRejectionReason]	-- Add the parameters for the stored procedure here
@Reason varchar(100) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DELETE FROM tblRejectionReason
      WHERE Reason=@Reason
END
--modified/created by Other Party




