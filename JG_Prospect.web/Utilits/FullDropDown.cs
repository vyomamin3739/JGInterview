using JG_Prospect.BLL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

using System.Collections.Generic;
using JG_Prospect.Common;

namespace JG_Prospect.Utilits
{
    /// <summary>
    /// Class is only Responsible for filling dropdown only
    /// </summary>
    public class FullDropDown
    {
        /// <summary>
        /// Will Fill Respective Task Task Dropdown
        /// </summary>
        /// <param name="ddlTechTask"></param>
        /// <returns></returns>
        public static DropDownList FillTechTaskDropDown(DropDownList ddlTechTask)
        {
            DataSet dsTechTask;

            dsTechTask = TaskGeneratorBLL.Instance.GetAllActiveTechTask();

            ddlTechTask.DataSource = dsTechTask;
            ddlTechTask.DataTextField = "Title";
            ddlTechTask.DataValueField = "TaskId";
            ddlTechTask.DataBind();

            return ddlTechTask;
        }

        /// <summary>
        /// Will Fill Intervals time dropsown 
        /// Copied from \Sr_App\EditUser.aspx.cs By Bhavik Vaishnani.
        /// </summary>
        /// <returns></returns>
        public static DropDownList GetTimeIntervals(DropDownList ddlInsteviewtime)
        {
            List<string> timeIntervals = new List<string>();
            TimeSpan startTime = new TimeSpan(0, 0, 0);
            DateTime startDate = new DateTime(DateTime.MinValue.Ticks); // Date to be used to get shortTime format.
            for (int i = 0; i < 48; i++)
            {
                int minutesToBeAdded = 30 * i;      // Increasing minutes by 30 minutes interval
                TimeSpan timeToBeAdded = new TimeSpan(0, minutesToBeAdded, 0);
                TimeSpan t = startTime.Add(timeToBeAdded);
                DateTime result = startDate + t;
                timeIntervals.Add(result.ToShortTimeString());      // Use Date.ToShortTimeString() method to get the desired format                
            }

            ddlInsteviewtime.DataSource = timeIntervals;
            ddlInsteviewtime.DataBind();

            return ddlInsteviewtime;
        }

        /// <summary>
        /// Fill UserStatus a Static Method in future can replace with DB
        /// </summary>
        /// <param name="ddlUserStatus"></param>
        /// <returns></returns>
        /// <remarks>
        /// Used with both JQuery Image msDropDown() and plain dropdown.
        /// </remarks>
        public static DropDownList FillUserStatus(DropDownList ddlUserStatus, string FirstItem = "", string FirstItemValue = "", Boolean Formatted = true)
        {
            List<UserStatus> lstUserStatus = new List<UserStatus>();
            UserStatus objUserStatus;

            if (FirstItem != "" && FirstItemValue != "")
            {
                objUserStatus = new UserStatus();
                objUserStatus.Status = FirstItem;
                objUserStatus.StatusValue = FirstItemValue;
                lstUserStatus.Add(objUserStatus);
            }

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Referral applicant";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.ReferralApplicant).ToString();
            lstUserStatus.Add(objUserStatus);

            //Task ID - ID#: ITSN042 - Passing the Status Text with HTML elements
            //for JQuery Image dropdown msDropDown()
            objUserStatus = new UserStatus();
            objUserStatus.Status = Formatted ? "Applicant <span class='ddlstatus-per-text' id='ddlstatusApplicant'><img src='../Sr_App/img/yellow-astrek.png' class='fnone'>Applicant Screened : 25%</span>" : "Applicant";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Applicant).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = Formatted ? "Interview Date <span class='ddlstatus-per-text' id='ddlstatusInterviewDate'><img src='../Sr_App/img/purple-astrek.png' class='fnone'>Applicant Screened : 20%</span>" : "Interview Date";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.InterviewDate).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Rejected";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Rejected).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = Formatted ? "Offer Made <span class='ddlstatus-per-text' id='ddlstatusOfferMade'><img src='../Sr_App/img/black-astrek.png' class='fnone'>New Hire : 80%</span>" : "Offer Made";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.OfferMade).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Active";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Active).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Deactive";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Deactive).ToString();
            lstUserStatus.Add(objUserStatus);

            ddlUserStatus.DataSource = lstUserStatus;
            ddlUserStatus.DataTextField = "Status";
            ddlUserStatus.DataValueField = "StatusValue";
            ddlUserStatus.DataBind();

            return ddlUserStatus;

            #region Old code  removed for Task ID - ID#: ITSN042
            /**             
            objUserStatus = new UserStatus();
            objUserStatus.Status = "Phone/Video Screened";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Phone_VideoScreened).ToString();
            lstUserStatus.Add(objUserStatus);

            //objUserStatus = new UserStatus();
            //objUserStatus.Status = "Install Prospect";
            //objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.InstallProspect).ToString();
            //lstUserStatus.Add(objUserStatus);

            //objUserStatus = new UserStatus();
            //objUserStatus.Status = "Applicant Screened : 20%";
            //objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.ApplicantScreened_20).ToString();
            //lstUserStatus.Add(objUserStatus);
            
            //objUserStatus = new UserStatus();
            //objUserStatus.Status = "Applicant Screened : 25%";
            //objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.ApplicantScreened_25).ToString();
            //lstUserStatus.Add(objUserStatus);

            //objUserStatus = new UserStatus();
            //objUserStatus.Status = "New Hire : 80%";
            //objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.NewHire_80).ToString();
            //lstUserStatus.Add(objUserStatus);                           
             * */
            #endregion
        }

        /// <summary>
        /// Set value of Image Attributes on the base of the status
        /// Currently Image Path only for Sr_App Pages.
        /// </summary>
        public static DropDownList UserStatusDropDown_Set_ImageAtt(DropDownList ddlstatus)
        {
            string imageURL = "";

            for (int i = 0; i < ddlstatus.Items.Count; i++)
            {
                switch ((JGConstant.InstallUserStatus)Convert.ToByte(ddlstatus.Items[i].Value))
                {
                    case JGConstant.InstallUserStatus.Applicant:
                    case JGConstant.InstallUserStatus.ReferralApplicant:
                        imageURL = "../Sr_App/img/red-astrek.png";
                        ddlstatus.Items[i].Attributes["data-image"] = imageURL;
                        break;
                    case JGConstant.InstallUserStatus.OfferMade:
                        imageURL = "../Sr_App/img/dark-blue-astrek.png";
                        ddlstatus.Items[i].Attributes["data-image"] = imageURL;
                        break;
                    case JGConstant.InstallUserStatus.Active:
                        imageURL = "../Sr_App/img/green-astrek.png";
                        ddlstatus.Items[i].Attributes["data-image"] = imageURL;
                        break;
                    case JGConstant.InstallUserStatus.InterviewDate:
                        imageURL = "../Sr_App/img/Light-Blue-astrek.png"; //purple-astrek.png
                        ddlstatus.Items[i].Attributes["data-image"] = imageURL;
                        break;
                    case JGConstant.InstallUserStatus.Deactive:
                    case JGConstant.InstallUserStatus.Rejected:
                        ddlstatus.Items[i].Attributes["data-image"] = "../Sr_App/img/white-astrek.png";
                        break;
                    default:
                        break;
                }
            }
            return ddlstatus;

            #region Old code  removed for Task ID - ID#: ITSN042
            /**
            case jgconstant.installuserstatus.phonescreened:
                imageurl = "../sr_app/img/yellow-astrek.png";
                ddlstatus.items[i].attributes["data-image"] = imageurl;
                break;
             
            case jgconstant.installuserstatus.applicantscreened_20:
                imageurl = "../sr_app/img/purple-astrek.png";
                ddlstatus.items[i].attributes["data-image"] = imageurl;
                break;
            case jgconstant.installuserstatus.applicantscreened_25:
                imageurl = "../sr_app/img/yellow-astrek.png";
                ddlstatus.items[i].attributes["data-image"] = imageurl;
                break;
            case jgconstant.installuserstatus.newhire_80:
                imageurl = "../sr_app/img/black-astrek.png";
                ddlstatus.items[i].attributes["data-image"] = imageurl;
                break;
             * */
            #endregion
        }

        class UserStatus
        {
            public string Status { get; set; }
            public string StatusValue { get; set; }
        }
    }
}