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
        public static DropDownList FillUserStatus(DropDownList ddlUserStatus, string FirstItem = "", string FirstItemValue = "")
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

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Applicant";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Applicant).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Phone/Video Screened";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Phone_VideoScreened).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Rejected";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.Rejected).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Interview Date";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.InterviewDate).ToString();
            lstUserStatus.Add(objUserStatus);

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Offer Made";
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

            objUserStatus = new UserStatus();
            objUserStatus.Status = "Install Prospect";
            objUserStatus.StatusValue = Convert.ToByte(JGConstant.InstallUserStatus.InstallProspect).ToString();
            lstUserStatus.Add(objUserStatus);

            ddlUserStatus.DataSource = lstUserStatus;
            ddlUserStatus.DataTextField = "Status";
            ddlUserStatus.DataValueField = "StatusValue";
            ddlUserStatus.DataBind();

            return ddlUserStatus;
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
                    case JGConstant.InstallUserStatus.PhoneScreened:
                        imageURL = "../Sr_App/img/yellow-astrek.png";
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
                    default:
                        //ddlstatus.Items[i].Attributes["data-image"] = "../Sr_App/img/white-astrek.png";
                        break;
                }
                //System.Web.UI.WebControls.ListItem item = ddlCountry.Items[i];
                //item.Attributes["data-image"] = imageURL;
            }
            return ddlstatus;
        }


        class UserStatus
        {
            public string Status { get; set; }
            public string StatusValue { get; set; }
        }
    }
}