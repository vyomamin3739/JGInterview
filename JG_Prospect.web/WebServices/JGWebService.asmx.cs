using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using JG_Prospect.Common;
using JG_Prospect.App_Code;
using System.Net.Mail;
using System.IO;

namespace JG_Prospect.WebServices
{
    /// <summary>
    /// Summary description for JGWebService
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class JGWebService : System.Web.Services.WebService
    {
        #region '--TaskComments--'

        [WebMethod]
        public object GetTaskComments(long intTaskId, long? intParentCommentId, int? intStartIndex, int? intPageSize)
        {
            DataSet dsTaskComments = TaskCommentBLL.Instance.GetTaskCommentsDataSet(intTaskId, intParentCommentId, intStartIndex, intPageSize);

            bool blSuccess = false;
            int intTotalRecords = 0, intRemainingRecords = 0;
            List<TaskComment> lstTaskComments = new List<TaskComment>();

            if (dsTaskComments != null && dsTaskComments.Tables.Count == 2)
            {
                blSuccess = true;

                intTotalRecords = Convert.ToInt32(dsTaskComments.Tables[1].Rows[0]["TotalRecords"]);

                foreach (DataRow drTaskComment in dsTaskComments.Tables[0].Rows)
                {
                    TaskComment objTaskComment = new TaskComment();
                    objTaskComment.Id = Convert.ToInt64(drTaskComment["Id"]);
                    objTaskComment.Comment = Convert.ToString(drTaskComment["Comment"]);
                    if (!string.IsNullOrEmpty(Convert.ToString(drTaskComment["ParentCommentId"])))
                    {
                        objTaskComment.ParentCommentId = Convert.ToInt64(drTaskComment["ParentCommentId"]);
                    }
                    else
                    {
                        objTaskComment.ParentCommentId = 0;
                    }
                    objTaskComment.TaskId = Convert.ToInt64(drTaskComment["TaskId"]);
                    objTaskComment.UserId = Convert.ToInt32(drTaskComment["UserId"]);
                    objTaskComment.DateCreated = Convert.ToDateTime(drTaskComment["DateCreated"]);

                    objTaskComment.TotalChildRecords = Convert.ToInt32(drTaskComment["TotalChildRecords"]);

                    objTaskComment.UserInstallId = Convert.ToString(drTaskComment["UserInstallId"]);
                    objTaskComment.UserName = Convert.ToString(drTaskComment["Username"]);
                    objTaskComment.UserFirstName = Convert.ToString(drTaskComment["FirstName"]);
                    objTaskComment.UserLastName = Convert.ToString(drTaskComment["LastName"]);
                    objTaskComment.UserEmail = Convert.ToString(drTaskComment["Email"]);

                    lstTaskComments.Add(objTaskComment);
                }

                if (intPageSize.HasValue)
                {
                    intRemainingRecords = intTotalRecords - intPageSize.Value;
                }
            }

            return new
            {
                Success = blSuccess,
                TotalRecords = intTotalRecords,
                RemainingRecords = intRemainingRecords,
                TaskComments = lstTaskComments
            };
        }

        [WebMethod(EnableSession = true)]
        public object SaveTaskComment(string strId, string strComment, string strParentCommentId, string strTaskId)
        {
            TaskComment objTaskComment = new TaskComment();
            objTaskComment.Id = 0;
            objTaskComment.Comment = strComment;
            if (string.IsNullOrEmpty(strParentCommentId) || strParentCommentId == "0")
            {
                objTaskComment.ParentCommentId = null;
            }
            else
            {
                objTaskComment.ParentCommentId = Convert.ToInt64(strParentCommentId);
            }
            objTaskComment.TaskId = Convert.ToInt64(strTaskId);
            objTaskComment.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);

            bool blSuccess = false;

            if (!string.IsNullOrEmpty(strId))
            {
                objTaskComment.Id = Convert.ToInt64(strId);
            }

            if (objTaskComment.Id > 0)
            {
                blSuccess = TaskCommentBLL.Instance.UpdateTaskComment(objTaskComment);
            }
            else
            {
                blSuccess = TaskCommentBLL.Instance.InsertTaskComment(objTaskComment);
            }

            var result = new
            {
                Success = blSuccess
            };

            return result;
        }

        #endregion

        #region '--TaskApproval--'

        [WebMethod(EnableSession = true)]
        public object FreezeTask(string strEstimatedHours, string strTaskApprovalId, string strTaskId, string strPassword)
        {
            string strMessage;
            bool blSuccess = false;

            decimal decEstimatedHours = 0;

            if (string.IsNullOrEmpty(strPassword))
            {
                strMessage = "Sub Task cannot be freezed as password is not provided.";
            }
            else if (!strPassword.Equals(Convert.ToString(Session["loginpassword"])))
            {
                strMessage = "Sub Task cannot be freezed as password is not valid.";
            }
            else if (string.IsNullOrEmpty(strEstimatedHours))
            {
                strMessage = "Sub Task cannot be freezed as estimated hours is not provided.";
            }
            else if (!decimal.TryParse(strEstimatedHours.Trim(), out decEstimatedHours) || decEstimatedHours <= 0)
            {
                strMessage = "Sub Task cannot be freezed as estimated hours is not valid.";
            }
            else
            {
                #region Update Estimated Hours

                TaskApproval objTaskApproval = new TaskApproval();
                if (string.IsNullOrEmpty(strTaskApprovalId))
                {
                    objTaskApproval.Id = 0;
                }
                else
                {
                    objTaskApproval.Id = Convert.ToInt64(strTaskApprovalId);
                }
                objTaskApproval.EstimatedHours = strEstimatedHours.Trim();
                objTaskApproval.Description = string.Empty;
                objTaskApproval.TaskId = Convert.ToInt32(strTaskId);
                objTaskApproval.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                objTaskApproval.IsInstallUser = JGSession.IsInstallUser.Value;

                if (objTaskApproval.Id > 0)
                {
                    TaskGeneratorBLL.Instance.UpdateTaskApproval(objTaskApproval);
                }
                else
                {
                    TaskGeneratorBLL.Instance.InsertTaskApproval(objTaskApproval);
                }

                #endregion

                #region Update Task (Freeze, Status)

                Task objTask = new Task();

                objTask.TaskId = Convert.ToInt32(strTaskId);

                bool blIsAdmin, blIsTechLead, blIsUser;

                blIsAdmin = blIsTechLead = blIsUser = false;
                if (JGSession.DesignationId == (byte)JG_Prospect.Common.JGConstant.DesignationType.Admin)
                {
                    objTask.AdminUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTask.IsAdminInstallUser = JGSession.IsInstallUser.Value;
                    objTask.AdminStatus = true;
                    blIsAdmin = true;
                }
                else if (JGSession.DesignationId == (byte)JG_Prospect.Common.JGConstant.DesignationType.IT_Lead)
                {
                    objTask.TechLeadUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTask.IsTechLeadInstallUser = JGSession.IsInstallUser.Value;
                    objTask.TechLeadStatus = true;
                    blIsTechLead = true;
                }
                else
                {
                    objTask.OtherUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTask.IsOtherUserInstallUser = JGSession.IsInstallUser.Value;
                    objTask.OtherUserStatus = true;
                    blIsUser = true;
                }

                TaskGeneratorBLL.Instance.UpdateSubTaskStatusById
                                            (
                                                objTask,
                                                blIsAdmin,
                                                blIsTechLead,
                                                blIsUser
                                            );

                blSuccess = true;
                strMessage = "Sub Task freezed successfully.";

                #endregion
            }

            var result = new
            {
                Success = blSuccess,
                Message = strMessage,
                TaskId = strTaskId
            };

            return result;
        }

        #endregion

        #region '--TaskWorkSpecification--'

        [WebMethod(EnableSession = true)]
        public object GetTaskWorkSpecifications(Int32 TaskId, Int64 intParentTaskWorkSpecificationId)
        {
            List<string> strTableData = new List<string>();

            DataSet ds = new DataSet();

            if (intParentTaskWorkSpecificationId == 0)
            {
                ds = TaskGeneratorBLL.Instance.GetTaskWorkSpecifications(TaskId, App_Code.CommonFunction.CheckAdminAndItLeadMode(), null, 0, null);
            }
            else
            {
                ds = TaskGeneratorBLL.Instance.GetTaskWorkSpecifications(TaskId, App_Code.CommonFunction.CheckAdminAndItLeadMode(), intParentTaskWorkSpecificationId, 0, null);
            }

            TaskWorkSpecification[] arrTaskWorkSpecification = null;

            string strFirstParentCustomId = "";
            string strLastCustomId = "";
            int intTotalRecordCount = 0;

            if (ds.Tables.Count == 4)
            {
                arrTaskWorkSpecification = new TaskWorkSpecification[ds.Tables[0].Rows.Count];
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    DataRow dr = ds.Tables[0].Rows[i];
                    arrTaskWorkSpecification[i] = new TaskWorkSpecification();
                    arrTaskWorkSpecification[i].Id = Convert.ToInt64(dr["Id"]);
                    arrTaskWorkSpecification[i].CustomId = Convert.ToString(dr["CustomId"]);
                    arrTaskWorkSpecification[i].AdminStatus = Convert.ToBoolean(dr["AdminStatus"]);
                    arrTaskWorkSpecification[i].TechLeadStatus = Convert.ToBoolean(dr["TechLeadStatus"]);
                    arrTaskWorkSpecification[i].OtherUserStatus = Convert.ToBoolean(dr["OtherUserStatus"]);
                    arrTaskWorkSpecification[i].Description = Convert.ToString(dr["Description"]);
                    arrTaskWorkSpecification[i].Title = Convert.ToString(dr["Title"]);
                    arrTaskWorkSpecification[i].URL = Convert.ToString(dr["URL"]);
                    if (!string.IsNullOrEmpty(dr["ParentTaskWorkSpecificationId"].ToString()))
                    {
                        arrTaskWorkSpecification[i].ParentTaskWorkSpecificationId = Convert.ToInt64(dr["ParentTaskWorkSpecificationId"]);
                    }
                    arrTaskWorkSpecification[i].TaskWorkSpecificationsCount = Convert.ToInt32(dr["SubTaskWorkSpecificationCount"]);
                }

                intTotalRecordCount = Convert.ToInt32(ds.Tables[1].Rows[0]["TotalRecordCount"]);

                if (ds.Tables[2].Rows.Count > 0)
                {
                    strFirstParentCustomId = Convert.ToString(ds.Tables[2].Rows[0]["FirstParentCustomId"]);
                }
                if (ds.Tables[3].Rows.Count > 0)
                {
                    strLastCustomId = Convert.ToString(ds.Tables[3].Rows[0]["LastChildCustomId"]);
                }
            }

            string strNextCustomId = string.Empty;

            if (string.IsNullOrEmpty(strFirstParentCustomId) || intParentTaskWorkSpecificationId == 0)
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("A", strLastCustomId);
            }
            // parent list has alphabetical numbering.
            else if (strFirstParentCustomId.Equals("A"))
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("1", strLastCustomId);
            }
            // parent list has decimal numbering.
            else if (strFirstParentCustomId.Equals("1"))
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("1a", strLastCustomId);
            }
            // parent list has custom numbering.
            else if (strFirstParentCustomId.Equals("1a"))
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("1", strLastCustomId);
            }
            // parent list has roman numbering.
            else if (strFirstParentCustomId.Equals("i") || strFirstParentCustomId.Equals("I"))
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("a", strLastCustomId);
            }
            else
            {
                strNextCustomId = App_Code.CommonFunction.GetNextSequenceValue("I", strLastCustomId, true);
            }

            int intPendingCount = 0;

            DataSet dsTaskSpecificationStatus = TaskGeneratorBLL.Instance.GetPendingTaskWorkSpecificationCount(TaskId);
            if (dsTaskSpecificationStatus.Tables.Count > 1 && dsTaskSpecificationStatus.Tables[1].Rows.Count > 0)
            {
                intPendingCount = Convert.ToInt32(dsTaskSpecificationStatus.Tables[1].Rows[0]["PendingRecordCount"]);
            }

            var result = new
            {
                NextCustomId = strNextCustomId,
                TotalRecordCount = intTotalRecordCount,
                PendingCount = intPendingCount,
                Records = arrTaskWorkSpecification
            };

            return result;
        }

        [WebMethod(EnableSession = true)]
        public bool SaveTaskWorkSpecification(Int64 intId, string strCustomId, string strDescription, string strTitle, string strURL, Int64 intTaskId, Int64 intParentTaskWorkSpecificationId, string strPassword = "")
        {
            bool blSuccess = true;

            if (intTaskId > 0)
            {
                TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();
                objTaskWorkSpecification.Id = intId;
                objTaskWorkSpecification.CustomId = strCustomId;
                objTaskWorkSpecification.TaskId = intTaskId;
                objTaskWorkSpecification.Description = Server.HtmlDecode(strDescription);
                objTaskWorkSpecification.Title = strTitle;
                objTaskWorkSpecification.URL = strURL;

                // save will revoke freezed status.
                objTaskWorkSpecification.AdminStatus = false;
                objTaskWorkSpecification.TechLeadStatus = false;

                if (strPassword.Equals(Convert.ToString(Session["loginpassword"])))
                {
                    if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
                    {
                        objTaskWorkSpecification.AdminUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        objTaskWorkSpecification.IsAdminInstallUser = JGSession.IsInstallUser.Value;
                        objTaskWorkSpecification.AdminStatus = true;
                    }
                    else if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
                    {
                        objTaskWorkSpecification.TechLeadUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        objTaskWorkSpecification.IsTechLeadInstallUser = JGSession.IsInstallUser.Value;
                        objTaskWorkSpecification.TechLeadStatus = true;
                    }
                    else
                    {
                        objTaskWorkSpecification.OtherUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        objTaskWorkSpecification.IsOtherUserInstallUser = JGSession.IsInstallUser.Value;
                        objTaskWorkSpecification.OtherUserStatus = true;
                    }
                }

                if (intParentTaskWorkSpecificationId > 0)
                {
                    objTaskWorkSpecification.ParentTaskWorkSpecificationId = intParentTaskWorkSpecificationId;
                }

                if (objTaskWorkSpecification.Id == 0)
                {
                    TaskGeneratorBLL.Instance.InsertTaskWorkSpecification(objTaskWorkSpecification);
                }
                else
                {
                    TaskGeneratorBLL.Instance.UpdateTaskWorkSpecification(objTaskWorkSpecification);
                }
            }
            else
            {
                blSuccess = false;
            }
            return blSuccess;
        }

        [WebMethod(EnableSession = true)]
        public bool DeleteTaskWorkSpecification(Int64 intId)
        {
            bool blSuccess = false;

            if (TaskGeneratorBLL.Instance.DeleteTaskWorkSpecification(intId) > 0)
            {
                blSuccess = true;
            }

            return blSuccess;
        }

        [WebMethod(EnableSession = true)]
        public int UpdateTaskWorkSpecificationStatusById(Int64 intId, string strPassword)
        {
            if (strPassword.Equals(Convert.ToString(Session["loginpassword"])))
            {
                TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();
                objTaskWorkSpecification.Id = intId;

                bool blIsAdmin, blIsTechLead, blIsUser;

                blIsAdmin = blIsTechLead = blIsUser = false;
                if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
                {
                    objTaskWorkSpecification.AdminUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTaskWorkSpecification.IsAdminInstallUser = JGSession.IsInstallUser.Value;
                    objTaskWorkSpecification.AdminStatus = true;
                    blIsAdmin = true;
                }
                else if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
                {
                    objTaskWorkSpecification.TechLeadUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTaskWorkSpecification.IsTechLeadInstallUser = JGSession.IsInstallUser.Value;
                    objTaskWorkSpecification.TechLeadStatus = true;
                    blIsTechLead = true;
                }
                else
                {
                    objTaskWorkSpecification.OtherUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    objTaskWorkSpecification.IsOtherUserInstallUser = JGSession.IsInstallUser.Value;
                    objTaskWorkSpecification.OtherUserStatus = true;
                    blIsUser = true;
                }

                return TaskGeneratorBLL.Instance.UpdateTaskWorkSpecificationStatusById
                                            (
                                                objTaskWorkSpecification,
                                                blIsAdmin,
                                                blIsTechLead,
                                                blIsUser
                                            );
            }
            else
            {
                return -2;
            }
        }

        #endregion

        #region '--Task--'

        [WebMethod(EnableSession = true)]
        public bool UpdateTaskTitleById(string tid, string title)
        {
            TaskGeneratorBLL.Instance.UpdateTaskTitleById(tid, title);
            return true;
        }

        [WebMethod(EnableSession = true)]
        public bool UpdateTaskURLById(string tid, string URL)
        {
            TaskGeneratorBLL.Instance.UpdateTaskURLById(tid, URL);
            return true;
        }

        [WebMethod(EnableSession = true)]
        public bool UpdateTaskDescriptionById(string tid, string Description)
        {
            TaskGeneratorBLL.Instance.UpdateTaskDescriptionById(tid, Description);
            return true;
        }

        [WebMethod(EnableSession = true)]
        public object AddNewSubTask(int ParentTaskId, String Title, String URL, String Desc, String Status, String Priority, String DueDate, String TaskHours, String InstallID, String Attachments, String TaskType, String TaskDesignations, string TaskLvl, bool blTechTask)
        {
            return SaveSubTask(ParentTaskId, Title, URL, Desc, Status, Priority, DueDate, TaskHours, InstallID, Attachments, TaskType, TaskDesignations, TaskLvl, blTechTask);
        }

        [WebMethod(EnableSession = true)]
        public object GetSubTaskId(string CommandArgument, string CommandName)
        {
            char[] delimiterChars = { '#' };
            string[] TaskLvlandInstallId = CommandName.Split(delimiterChars);

            string listIDOpt = string.Empty;
            string txtInstallId = string.Empty;
            string hdTaskLvl = TaskLvlandInstallId[0];
            string hdParentTaskId = TaskLvlandInstallId[2];
            string hdnCurrentEditingRow = TaskLvlandInstallId[3];

            if (TaskLvlandInstallId[0] == "2")
            {
                Task objTask = new Task();
                DataSet result = new DataSet();
                string vInstallId = TaskLvlandInstallId[1];
                result = TaskGeneratorBLL.Instance.GetTaskByMaxId(TaskLvlandInstallId[2], 2);
                if (result.Tables[0].Rows.Count > 0)
                {
                    vInstallId = result.Tables[0].Rows[0]["InstallId"].ToString();
                }
                string[] subtaskListIDSuggestion = getSUBSubtaskSequencing(vInstallId);
                if (subtaskListIDSuggestion.Length > 0)
                {
                    if (subtaskListIDSuggestion.Length > 1)
                    {
                        if (String.IsNullOrEmpty(subtaskListIDSuggestion[1]))
                        {
                            txtInstallId = subtaskListIDSuggestion[0];
                        }
                        else
                        {
                            txtInstallId = subtaskListIDSuggestion[1];
                        }
                    }
                    else
                    {
                        txtInstallId = subtaskListIDSuggestion[0];
                    }
                }
            }
            else
            {

                string[] roman4 = { "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii" };
                DataSet result = new DataSet();
                result = TaskGeneratorBLL.Instance.GetTaskByMaxId(TaskLvlandInstallId[2], 3);
                string vNextInstallId = "";
                if (result.Tables[0].Rows.Count > 0)
                {
                    string vInstallId = result.Tables[0].Rows[0]["InstallId"].ToString();

                    int cnt = -1;
                    for (int i = 0; i < roman4.Length; i++)
                    {
                        if (vInstallId == roman4[i])
                        {
                            cnt = i + 1;
                        }

                        if (cnt == i)
                        {
                            vNextInstallId = roman4[i];
                            break;
                        }
                    }
                }
                else { vNextInstallId = roman4[0]; }
                txtInstallId = vNextInstallId;
                result.Dispose();
            }


            var obj = new
            {
                hdTaskLvl = hdTaskLvl,
                hdParentTaskId = hdParentTaskId,
                txtInstallId = txtInstallId
            };

            return obj;
        }

        [WebMethod(EnableSession = true)]

        public bool SetTaskPriority(string taskid, string priority)
        {
            Task objTask = new Task();
            objTask.TaskId = Convert.ToInt32(taskid);
            if (taskid == "0")
            {
                objTask.TaskPriority = null;
            }
            else
            {
                objTask.TaskPriority = Convert.ToByte(priority);
            }
            TaskGeneratorBLL.Instance.UpdateTaskPriority(objTask);

            return true;
        }

        [WebMethod(EnableSession = true)]
        public object ValidateTaskStatus(Int32 intTaskId, int intTaskStatus, int[] arrAssignedUsers)
        {
            bool blResult = true;

            string strMessage = string.Empty;

            //if (
            //    strStatus != Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString() &&
            //    !TaskGeneratorBLL.Instance.IsTaskWorkSpecificationApproved(intTaskId)
            //   )
            //{
            //    blResult = false;
            //    strMessage = "Task work specifications must be approved, to change status from Specs In Progress.";
            //}
            //else
            // if task is in assigned status. it should have assigned user selected there in dropdown. 
            if (intTaskStatus == Convert.ToByte(JGConstant.TaskStatus.Assigned))
            {
                blResult = false;
                strMessage = "Task must be assigned to one or more users, to change status to assigned.";

                blResult = arrAssignedUsers.Length > 0;
            }

            var result = new
            {
                IsValid = blResult,
                Message = strMessage
            };

            return result;
        }

        [WebMethod(EnableSession = true)]
        public bool SaveAssignedTaskUsers(Int32 intTaskId, int intTaskStatus, int[] arrAssignedUsers, int[] arrDesignationUsers)
        {
            JGConstant.TaskStatus objTaskStatus = (JGConstant.TaskStatus)intTaskStatus;

            //if task id is available to save its note and attachement.
            if (intTaskId != 0)
            {
                string strUsersIds = string.Join(",", arrAssignedUsers);

                // save (insert / delete) assigned users.
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(intTaskId), strUsersIds);

                // send email to selected users.
                if (strUsersIds.Length > 0)
                {
                    if (isSuccessful)
                    {
                        // Change task status to assigned = 3.
                        if (objTaskStatus == JGConstant.TaskStatus.Open || objTaskStatus == JGConstant.TaskStatus.Requested)
                        {
                            TaskGeneratorBLL.Instance.UpdateTaskStatus
                                            (
                                                new Task()
                                                {
                                                    TaskId = intTaskId,
                                                    Status = Convert.ToUInt16(JGConstant.TaskStatus.Assigned)
                                                }
                                            );
                        }

                        SendEmailToAssignedUsers(intTaskId, strUsersIds);
                    }
                }
                // send email to all users of the department as task is assigned to designation, but not to any specific user.
                else
                {
                    string strUserIDs = string.Join(",", arrDesignationUsers);

                    SendEmailToAssignedUsers(intTaskId, strUserIDs.TrimEnd(','));
                }
            }
            return true;
        }

        [WebMethod(EnableSession = true)]
        public bool SetTaskStatus(int intTaskId, string TaskStatus)
        {
            return TaskGeneratorBLL.Instance.SetTaskStatus(intTaskId, TaskStatus);
        }

        #endregion

        #region '--Private Methods--'

        private string[] getSUBSubtaskSequencing(string sequence)
        {
            String[] ReturnSequence = new String[2];

            String[] numbercomponents = sequence.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries);


            //if no subtask sequence than start with roman number I.
            if (numbercomponents.Length == 0) // like number of subtask without alphabet I,II
            {
                int startSequence = 1;
                ReturnSequence[0] = ExtensionMethods.ToRoman(startSequence);
                ReturnSequence[1] = String.Concat(ReturnSequence[0], " - a"); // concat existing roman number with alphabet.

            }
            else if (numbercomponents.Length == 1) // like number of subtask without alphabet I,II
            {
                int startSequence = 1;
                ReturnSequence[0] = ExtensionMethods.ToRoman(startSequence);
                ReturnSequence[1] = String.Concat(sequence, " - a"); // concat existing roman number with alphabet.

            }
            else  // if task sequence contains alphabet.
            {
                int numbersequence;
                numbercomponents[0] = numbercomponents[0].Trim();
                numbercomponents[1] = numbercomponents[1].Trim();


                char[] alphabetsequence = numbercomponents[1].ToCharArray();// get aplphabet from sequence

                bool parsed = ExtensionMethods.TryRomanParse(numbercomponents[0], out numbersequence); // parse roman to integer

                if (parsed)
                {
                    numbersequence++; // increase integer sequence

                    ReturnSequence[0] = ExtensionMethods.ToRoman(numbersequence); // convert integer sequnce to roman
                    ReturnSequence[1] = string.Concat(numbercomponents[0], " - ", ++alphabetsequence[0]); // advance alphabet to next alphabet.
                }
            }

            return ReturnSequence;
        }

        private object SaveSubTask(int ParentTaskId, String Title, String URL, String Desc, String Status, String Priority, String DueDate, String TaskHours, String InstallID, String Attachments, String TaskType, String TaskDesignations, string TaskLvl, bool blTechTask)
        {
            bool blnReturnVal = false;
            Task objTask = null;

            objTask = new Task();
            objTask.Mode = 0;

            objTask.Title = Title;
            objTask.Url = URL;
            objTask.Description = Desc;
            objTask.IsTechTask = blTechTask;

            // Convert Task Status string to int, if invalid value passed, set it to default "Open" status
            int inttaskStatus = ParseTaskStatus(Status);

            objTask.Status = inttaskStatus;

            if (Priority.Equals("0"))
            {
                objTask.TaskPriority = null;
            }
            else
            {
                objTask.TaskPriority = ParseTaskPriority(Priority);
            }

            objTask.DueDate = DueDate;
            objTask.Hours = TaskHours;
            objTask.CreatedBy = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            objTask.InstallId = InstallID.Trim();
            objTask.ParentTaskId = ParentTaskId;
            objTask.Attachment = Attachments;
            int maintaskid = Convert.ToInt32(Context.Request.QueryString["TaskId"]);

            if (!String.IsNullOrEmpty(TaskType))
            {
                objTask.TaskType = ParseTaskType(TaskType);
            }

            int TaskLevel = Convert.ToInt32(TaskLvl);

            // save task master details to database.
            long TaskId = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask, TaskLevel, maintaskid);

            // If Task is saved successfully and its level 1 & 2 task then proceed further to save its related data like attachments and designations.
            if (TaskId > 0 && !String.IsNullOrEmpty(TaskDesignations) && !String.IsNullOrEmpty(TaskDesignations))
            {
                // save assgined designation.
                SaveTaskDesignations(TaskId, InstallID.Trim(), TaskDesignations);

                // save attached file by user to database.
                UploadUserAttachements(Convert.ToInt64(TaskId), Attachments, JGConstant.TaskFileDestination.SubTask);

                blnReturnVal = true;
            }
            var result = new
            {
                Success = blnReturnVal,
                TaskId = TaskId
            };

            return result;
        }

        /// <summary>
        /// Convert task status string to int constant to save in database.
        /// if no proper string sent for respective status constant it will default set as OPEN.
        /// </summary>
        /// <param name="TaskStatus"></param>
        /// <returns></returns>
        private static int ParseTaskStatus(string TaskStatus)
        {
            int inttaskStatus = 0;

            int.TryParse(TaskStatus, out inttaskStatus);

            inttaskStatus = (inttaskStatus > 0) == true ? inttaskStatus : Convert.ToInt32(JGConstant.TaskStatus.Open);
            return inttaskStatus;
        }

        /// <summary>
        ///  Convert task priority string to int constant to save in database.
        /// if no proper string sent for respective priority constant it will default set as LOW.
        /// </summary>
        /// <param name="TaskPriority"></param>
        /// <returns></returns>
        private static byte ParseTaskPriority(string TaskPriority)
        {
            byte inttaskPriority = 0;

            byte.TryParse(TaskPriority, out inttaskPriority);

            inttaskPriority = (inttaskPriority > 0) == true ? inttaskPriority : Convert.ToByte(JGConstant.TaskPriority.Low);

            return inttaskPriority;
        }

        /// <summary>
        ///  Convert task type string to int constant to save in database.
        /// if no proper string sent for respective task type constant it will default set as ENHANCEMENT.
        /// </summary>
        /// <param name="TaskType"></param>
        /// <returns></returns>
        private static Int16 ParseTaskType(string TaskType)
        {
            Int16 inttaskType = 0;

            Int16.TryParse(TaskType, out inttaskType);

            inttaskType = (inttaskType > 0) == true ? inttaskType : Convert.ToByte(JGConstant.TaskType.Enhancement);

            return inttaskType;
        }

        private void SaveTaskDesignations(long TaskId, String InstallID, String SubTaskDesignations)
        {
            //if task id is available to save its note and attachement.
            if (!string.IsNullOrEmpty(SubTaskDesignations))
            {

                int indexofComma = SubTaskDesignations.IndexOf(',');
                int copyTill = indexofComma > 0 ? indexofComma : SubTaskDesignations.Length;

                //string designationcode = GetInstallIdFromDesignation(designations.Substring(0, copyTill));
                string designationcode = InstallID;

                TaskGeneratorBLL.Instance.SaveTaskDesignations(Convert.ToUInt64(TaskId), SubTaskDesignations, designationcode);

            }
        }

        private static void UploadUserAttachements(long TaskId, string attachments, JG_Prospect.Common.JGConstant.TaskFileDestination objTaskFileDestination)
        {
            //User has attached file than save it to database.
            if (!String.IsNullOrEmpty(attachments))
            {
                TaskUser taskUserFiles = new TaskUser();

                if (!string.IsNullOrEmpty(attachments))
                {
                    String[] files = attachments.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);

                    foreach (String attachment in files)
                    {
                        String[] attachements = attachment.Split('@');

                        taskUserFiles.Attachment = attachements[0];
                        taskUserFiles.OriginalFileName = attachements[1];
                        taskUserFiles.Mode = 0; // insert data.
                        taskUserFiles.TaskId = TaskId;
                        taskUserFiles.UserId = Convert.ToInt32(HttpContext.Current.Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        taskUserFiles.TaskUpdateId = null;
                        taskUserFiles.UserType = JGSession.IsInstallUser ?? false;
                        taskUserFiles.TaskFileDestination = objTaskFileDestination;
                        TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                    }
                }
            }
        }

        private void SendEmailToAssignedUsers(int intTaskId, string strInstallUserIDs)
        {
            try
            {
                string strHTMLTemplateName = "Task Generator Auto Email";
                DataSet dsEmailTemplate = AdminBLL.Instance.GetEmailTemplate(strHTMLTemplateName, 108);
                foreach (string userID in strInstallUserIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    DataSet dsUser = TaskGeneratorBLL.Instance.GetInstallUserDetails(Convert.ToInt32(userID));

                    string emailId = dsUser.Tables[0].Rows[0]["Email"].ToString();
                    string FName = dsUser.Tables[0].Rows[0]["FristName"].ToString();
                    string LName = dsUser.Tables[0].Rows[0]["LastName"].ToString();
                    string fullname = FName + " " + LName;

                    string strHeader = dsEmailTemplate.Tables[0].Rows[0]["HTMLHeader"].ToString();
                    string strBody = dsEmailTemplate.Tables[0].Rows[0]["HTMLBody"].ToString();
                    string strFooter = dsEmailTemplate.Tables[0].Rows[0]["HTMLFooter"].ToString();
                    string strsubject = dsEmailTemplate.Tables[0].Rows[0]["HTMLSubject"].ToString();

                    strBody = strBody.Replace("#Fname#", fullname);
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}://{1}/sr_app/TaskGenerator.aspx?TaskId={2}", HttpContext.Current.Request.Url.Scheme, HttpContext.Current.Request.Url.Host.ToString(), intTaskId));

                    strBody = strHeader + strBody + strFooter;

                    List<Attachment> lstAttachments = new List<Attachment>();
                    // your remote SMTP server IP.
                    for (int i = 0; i < dsEmailTemplate.Tables[1].Rows.Count; i++)
                    {
                        string sourceDir = Server.MapPath(dsEmailTemplate.Tables[1].Rows[i]["DocumentPath"].ToString());
                        if (File.Exists(sourceDir))
                        {
                            Attachment attachment = new Attachment(sourceDir);
                            attachment.Name = Path.GetFileName(sourceDir);
                            lstAttachments.Add(attachment);
                        }
                    }
                    CommonFunction.SendEmail(strHTMLTemplateName, emailId, strsubject, strBody, lstAttachments);
                }
            }
            catch (Exception ex)
            {

            }
        }

        #endregion
    }
}
