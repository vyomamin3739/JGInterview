CREATE PROCEDURE [dbo].[UDP_GETUserGithubUsername]    
(
@Id int  
)
AS    
BEGIN    
SELECT        GitUserName
FROM          [tblInstallUsers]
WHERE Id  = @Id
END

GO

ALTER PROCEDURE [dbo].[usp_UpdateInstallUserConfirmDetails] 
(
	@UserId INT,
	@Address VARCHAR(100),
	@DOB VARCHAR(25),
	@maritalstatus VARCHAR(25),
	@Attachements VARCHAR(MAX),
	@PCLiscense VARCHAR(MAX),
	@Citizenship VARCHAR(50),
	@GithubUsername VARCHAR(50)
)
AS
BEGIN
UPDATE       tblInstallUsers
SET                [Address] = @Address, DOB = @DOB, maritalstatus = @maritalstatus, Attachements = @Attachements , PCLiscense = @PCLiscense, Citizenship = @Citizenship, GitUserName = @GithubUsername
WHERE Id = @UserId
END

GO

ALTER PROCEDURE [dbo].[UDP_GETInstallUserDetails]
	@id int
As 
BEGIN

	SELECT 
		u.Id,FristName,Lastname,Email,[Address], ISNULL(d.DesignationName, Designation) AS Designation,
		[Status],[Password],Phone,Picture,Attachements,zip,[state],city,
		Bussinessname,SSN,SSN1,SSN2,[Signature],DOB,Citizenship,' ',
		EIN1,EIN2,A,B,C,D,E,F,G,H,[5],[6],[7],maritalstatus,PrimeryTradeId,SecondoryTradeId,Source,Notes,StatusReason,GeneralLiability,PCLiscense,WorkerComp,HireDate,TerminitionDate,WorkersCompCode,NextReviewDate,EmpType,LastReviewDate,PayRates,ExtraEarning,ExtraEarningAmt,
		PayMethod,Deduction,DeductionType,AbaAccountNo,AccountNo,AccountType,PTradeOthers,
		STradeOthers,DeductionReason,InstallId,SuiteAptRoom,FullTimePosition,ContractorsBuilderOwner,MajorTools,DrugTest,ValidLicense,TruckTools,PrevApply,LicenseStatus,CrimeStatus,StartDate,SalaryReq,Avialability,ResumePath,skillassessmentstatus,assessmentPath
		,WarrentyPolicy,CirtificationTraining,businessYrs,underPresentComp,websiteaddress,PersonName,PersonType,CompanyPrinciple,UserType,Email2,Phone2,CompanyName,SourceUser,DateSourced,InstallerType,BusinessType,CEO,LegalOfficer,President,Owner,AllParteners,
		MailingAddress,Warrantyguarantee,WarrantyYrs,MinorityBussiness,WomensEnterprise,InterviewTime,CruntEmployement,CurrentEmoPlace,LeavingReason,CompLit,FELONY,shortterm,LongTerm,BestCandidate,TalentVenue,Boardsites,NonTraditional,ConSalTraning,BestTradeOne,
		BestTradeTwo,BestTradeThree
		,aOne,aOneTwo,bOne,cOne,aTwo,aTwoTwo,bTwo,cTwo,aThree,aThreeTwo,bThree,cThree,TC,ExtraIncomeType,RejectionDate ,UserInstallId
        ,PositionAppliedFor, PhoneExtNo, PhoneISDCode ,DesignationID, CountryCode
		,NameMiddleInitial , IsEmailPrimaryEmail, IsPhonePrimaryPhone, IsEmailContactPreference, IsCallContactPreference, IsTextContactPreference, IsMailContactPreference, d.ID AS DesignationId, 
		SourceID,DesignationCode
	
	FROM tblInstallUsers u 
			LEFT JOIN tbl_Designation d ON u.DesignationID = d.ID

	WHERE u.ID=@id

END

GO

create procedure [dbo].[UpdateGithubUsername]
@GithubUsername VARCHAR(50),
@UserId INT
as
begin
update tblInstallUsers set GitUserName = @GithubUsername
WHERE Id = @UserId
end

GO

CREATE PROCEDURE UDP_GETInstallUserDesignationCode
	-- Add the parameters for the stored procedure here
	@UserID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [DesignationCode] FROM [dbo].[tblInstallUsers] JOIN
	[dbo].[tbl_Designation]
	ON
	[dbo].[tbl_Designation].[ID] = [dbo].[tblInstallUsers].[DesignationID]
	WHERE [dbo].[tblInstallUsers].[Id] = @UserID
END
GO
