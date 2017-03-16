<?php
//sendemployee.php - original file name
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, GET, POST");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");


$serverName = "jgdbserver001.cdgdaha6zllk.us-west-2.rds.amazonaws.com"; //serverName\instanceName
$conn = mssql_connect($serverName, 'liveuser', 'JGLive@538%');
mssql_select_db("JGBS",$conn);
if( $conn === false ) {	die( print_r( mssql_error(), true)); }
// error_reporting(E_ALL);
// ini_set("display_errors", 1);
date_default_timezone_set("Asia/Kolkata");
$now=date("YmdHis"); //echo $now;




if(isset($_POST['submit']))
{

    //code to check existing record and return if already present
    $sql = "select * from dbo.tblInstallUsers where Email='".mysql_real_escape_string($_POST['email'])."' and Phone='".mysql_real_escape_string($_POST['phone'])."'"
		$result = mysql_query($sql);
		$alreadyExists = mysql_num_rows();
		if($alreadyExists) //record already exists with that email or phone
        {
            $redirect_url='http://web.jmgrovebuildingsupply.com/employment.php';
            header("location:$redirect_url");
        }


		if(isset($_POST['g-recaptcha-response']) && $_POST['g-recaptcha-response'] == ""){
            echo "Error : please verify captcha first";
            exit;
        }
		foreach($_POST as $key => $value) {
            $_POST[$key] = htmlspecialchars ($value);
        }
		// resume uploading
		if(basename( $_FILES['resume']['name'])!="")
        {
            $target_path="Resumes/$now";
            $target_path = $target_path . basename( $_FILES['resume']['name']);
            //pdf|doc|txt|gif|jpg|png|jpeg
            $allowedExts = array("pdf","doc","txt","docx","PDF","DOC","TXT","DOCX","gif","jpg","png","jpeg","GIF","JPG","PNG","JPEG");
            $extension = end(explode(".", $_FILES["resume"]["name"]));
            if (($_FILES["resume"]["size"] < 2097152)	&& in_array($extension, $allowedExts)){
                if(move_uploaded_file($_FILES['resume']['tmp_name'], $target_path))
                {
                    //	echo "The file ".  basename( $_FILES['resume']['name'])." has been uploaded successfully";
                    //echo 'file moved';
                    //exit();
                } else
                {
                    //echo 'locha';
                    //exit();
                    //echo "There was an error uploading the file, please try again!";
                }
            }
            else
            {
                echo "Error : please enter valid resume";
                exit;
            }
        }
		// profile pic uploading
		if(basename( $_FILES['profilepic']['name'])!="")
        {
            $target_path="ProfilePicture/$now";
            $target_path = $target_path . basename( $_FILES['profilepic']['name']);
            //gif|jpg|png|jpeg
            $allowedExts = array("gif","jpg","png","jpeg","GIF","JPG","PNG","JPEG");
            $extension = end(explode(".", $_FILES["profilepic"]["name"]));
            if (($_FILES["profilepic"]["size"] < 2097152)	&& in_array($extension, $allowedExts)){
                if(move_uploaded_file($_FILES['profilepic']['tmp_name'], $target_path))
                {
                    //echo "The file ".  basename( $_FILES['profilepic']['name'])." has been uploaded successfully";
                    //echo 'file moved';
                    //exit();
                } else
                {
                    //echo 'locha';
                    //exit();
                    //echo "There was an error uploading the file, please try again!";
                }
            }
            else
            {
                echo "Error : please enter valid profile picture";
                exit;
            }
        }
		// set variables
		$worked = isset($_POST['workedforjg']) && $_POST['workedforjg']=='yes' ? 1 : 0;
		$license = isset($_POST['license']) && $_POST['license']=='Yes' ? 1 : 0;
		$usertype = $_POST['position']=='sales' ? 'SalesUser' : 'installer';
		$CruntEmployement = strtolower($_POST['employed'])=='yes' ? 1 : 0; //Current employmemnt status
		$FELONY = isset($_POST['crime']) && strtolower($_POST['crime'])=='yes' ? 1 : 0; 	//felony yes/no
		$CrimeStatus = strtolower($_POST['drugtest'])=='yes' ? 1 : 0; //drug test yes/no
		$email_contact = (isset($_POST['email_contact'])) ? 1 : 0; // email contact preference
		$call_contact = (isset($_POST['call_contact'])) ? 1 : 0;  // call contact preference
		$text_contact = (isset($_POST['text_contact'])) ? 1 : 0; // text contact preference
		$mail_contact = (isset($_POST['mail_contact'])) ? 1 : 0; // mail contact preference
		$SourceUser = '1537';	//source user //$SourceUser = $_POST['source'];


		/*$SourceID = $_POST['source'];
		$SourceText = $_POST['source_text'];
		$EmpType = $_POST['jobtype']; //employmemnt type
		$Notes = $_POST['messagetorecruiter']; //recruiter message
		$NameMiddleInitial = $_POST['NameMiddleInitial']; //Nname Middle Initial message */

		// code added to make post data safe: Govind
		$SourceID = mysql_real_escape_string($_POST['source']);
		$SourceText = mysql_real_escape_string($_POST['source_text']);
		$EmpType = mysql_real_escape_string($_POST['jobtype']); //employmemnt type
		$Notes = mysql_real_escape_string($_POST['messagetorecruiter']); //recruiter message
		$NameMiddleInitial = mysql_real_escape_string($_POST['NameMiddleInitial']); //Nname Middle Initial message



		/*if(isset($_POST['crime']) && $_POST['crime'] !='')
		{$crime=$_POST['crime'];}
		else
		{$worked='no';} */

		// alterchange double quote to single quote
		// code added to make post data safe: Govind
		$sql = 'insert into dbo.tblInstallUsers ( SourceID,CountryCode,Password,FristName,LastName,Email,Phone,Address,Zip,State,City,	PrevApply,LicenseStatus,CrimeStatus,usertype,ResumePath,StartDate,PositionAppliedFor,DesignationID,Status,Source,SalaryReq,LeavingReason,DateSourced,CruntEmployement,FELONY,SourceUser,EmpType,Notes,
NameMiddleInitial,Designation,IsEmailContactPreference,IsCallContactPreference,IsTextContactPreference,IsMailContactPreference,Picture)values 
("'.mysql_real_escape_string($_POST['source']).'","'.mysql_real_escape_string($_POST['country']).'","jmgrove","'.mysql_real_escape_string($_POST['fname']).'","'.mysql_real_escape_string($_POST['lname']).'","'.mysql_real_escape_string($_POST['email']).'","'.mysql_real_escape_string($_POST['phone']).'","'.mysql_real_escape_string($_POST['address']).'","'.mysql_real_escape_string($_POST['zip']).'","'.mysql_real_escape_string($_POST['state']).'","'.mysql_real_escape_string($_POST['city']).'","'.mysql_real_escape_string($worked).'","'.$license.'","'.mysql_real_escape_string($CrimeStatus).'","'.mysql_real_escape_string($_POST['user_type']).'","http://jmgroveconstruction.com/Resumes/'.$now.basename( $_FILES['resume']['name']).'","'.$_POST['startdate'].'","'.mysql_real_escape_string($_POST['position_text']).'","'.mysql_real_escape_string($_POST['position']).'","2","'.mysql_real_escape_string($SourceText).'","'.mysql_real_escape_string($_POST['salaryrequirements']).'","'.mysql_real_escape_string($_POST['reasonforleaving']).'","GETDATE()","'.mysql_real_escape_string($CruntEmployement).'","'.mysql_real_escape_string($FELONY).'","'.$SourceUser.'","'.mysql_real_escape_string($EmpType).'","'.mysql_real_escape_string($Notes).'","'.mysql_real_escape_string($NameMiddleInitial).'","'.mysql_real_escape_string($_POST['position_text']).'","'.mysql_real_escape_string($email_contact).'","'.mysql_real_escape_string($call_contact).'","'.mysql_real_escape_string($text_contact).'","'.mysql_real_escape_string($mail_contact).'","http://jmgroveconstruction.com/ProfilePicture/'.$now.basename( $_FILES['profilepic']['name']).'")';

			//echo $sql;exit;
	$query = mssql_query($sql);
	if ($query === false){
        exit("<pre>".print_r(mssql_error(), true));
    }
    else
    {
        //echo "Record Inserted Successfully";
        // $URL="http://jmgroveconstruction.com/employment.php?view=formbox&rstatus=1";
        ///$URL="http://www.jmgroveconstruction.com/quote-service-contact-us.php?message=sent";
        $email = $_POST['email'];
        $result = mssql_fetch_assoc(mssql_query("select @@IDENTITY as id"));
        $lastID = $result['id'];


        $redirect_url='http://web.jmgrovebuildingsupply.com/stafflogin.aspx?Email='.$email.'&ID='.$lastID;
        //$redirect_url='http://www.jmgroveconstruction.com/demo/quote-service-contact-us.php?message=sent';
        header("location:$redirect_url");
    }


}


?>