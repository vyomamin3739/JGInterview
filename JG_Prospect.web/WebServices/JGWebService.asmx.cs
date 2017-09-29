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
using Newtonsoft.Json;
using System.Web.Script.Services;
using System.Configuration;

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

        [WebMethod(EnableSession = true)]
        public object AdminFreezeTask(string strTaskApprovalId, string strTaskId, string strPassword)
        {
            string strMessage;
            bool blSuccess = false;

            if (string.IsNullOrEmpty(strPassword))
            {
                strMessage = "Sub Task cannot be freezed as password is not provided.";
            }
            else if (!strPassword.Equals(Convert.ToString(Session["loginpassword"])))
            {
                strMessage = "Sub Task cannot be freezed as password is not valid.";
            }
            else
            {

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
        public bool UpdateTaskSequence(Int64 Sequence, Int64 TaskID, Int32 DesignationID, bool IsTechTask)
        {
            TaskGeneratorBLL.Instance.UpdateTaskSequence(Sequence, TaskID, DesignationID, IsTechTask);
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
        public object AddNewSubTask(int ParentTaskId, String Title, String URL, String Desc, String Status, String Priority, String DueDate, String TaskHours, String InstallID, String Attachments, String TaskType, String TaskDesignations, string TaskLvl, bool blTechTask, Int64? Sequence)
        {
            return SaveSubTask(ParentTaskId, Title, URL, Desc, Status, Priority, DueDate, TaskHours, InstallID, Attachments, TaskType, TaskDesignations, TaskLvl, blTechTask, Sequence);
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
        public string GetLatestTaskSequence(Int32 DesignationId, bool IsTechTask)
        {
            string strMessage = string.Empty;
            DataSet dtResult = TaskGeneratorBLL.Instance.GetLatestTaskSequence(DesignationId, IsTechTask);
            if (dtResult != null)
            {
                strMessage = JsonConvert.SerializeObject(dtResult, Formatting.Indented);
            }
            else
            {
                strMessage = String.Empty;
            }
            return strMessage;
        }

        [WebMethod(EnableSession = true)]
        public bool DeleteTaskSequence(Int64 TaskId)
        {
            Boolean blnReturnResult = TaskGeneratorBLL.Instance.DeleteTaskSequence(TaskId);

            return blnReturnResult;
        }

        [WebMethod(EnableSession = true)]
        public bool DeleteTaskSubSequence(Int64 TaskId)
        {
            Boolean blnReturnResult = TaskGeneratorBLL.Instance.DeleteTaskSubSequence(TaskId);

            return blnReturnResult;
        }

        [WebMethod(EnableSession = true)]
        public string GetAssignUsers(string TaskDesignations)
        {
            // As subtasks are not having any seperate designations other than Parent task, not need to fecth users every time.
            DataSet dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, TaskDesignations);
            string strMessage;

            if (dsUsers != null && dsUsers.Tables.Count > 0)
            {


                DataTable dtUsers = CommonFunction.ApplyColorCodeToAssignUserDataTable(dsUsers.Tables[0]);

                dtUsers.TableName = "AssignedUsers";

                strMessage = JsonConvert.SerializeObject(dtUsers, Formatting.Indented);
            }
            else
            {
                strMessage = String.Empty;
            }
            return strMessage;
        }



        //[WebMethod(EnableSession = true)]
        //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        //public void GetAllTaskWithSequence()
        //{
        //    string strMessage = string.Empty;
        //    DataSet dtResult = TaskGeneratorBLL.Instance.GetAllTaskWithSequence(0, 999);
        //    if (dtResult != null && dtResult.Tables.Count > 0)
        //    {
        //        Context.Response.Clear();
        //        Context.Response.ContentType = "application/json";
        //        Context.Response.Write(JsonConvert.SerializeObject(dtResult.Tables[0], Formatting.Indented));

        //    }
        //    else
        //    {
        //        strMessage = String.Empty;
        //    }
        //    //return strMessage;
        //}


        [WebMethod(EnableSession = true)]
        public String GetAllTasksWithPaging(int? page, int? pageSize, String DesignationIDs, bool IsTechTask, Int64 HighlightedTaskID)
        {
            string strMessage = string.Empty;
            DataSet dtResult = TaskGeneratorBLL.Instance.GetAllTaskWithSequence(page == null ? 0 : Convert.ToInt32(page), pageSize == null ? 1000 : Convert.ToInt32(pageSize), DesignationIDs, IsTechTask, HighlightedTaskID);
            if (dtResult != null && dtResult.Tables.Count > 0)
            {
                //Context.Response.Clear();
                //Context.Response.ContentType = "application/json";
                //Context.Response.Write(JsonConvert.SerializeObject(dtResult, Formatting.Indented));
                dtResult.Tables[0].TableName = "Tasks";
                dtResult.Tables[1].TableName = "SubSeqTasks";
                dtResult.Tables[2].TableName = "RecordCount";

                DataRelation relation = dtResult.Relations.Add("relation", dtResult.Tables["Tasks"].Columns["Sequence"], dtResult.Tables["SubSeqTasks"].Columns["Sequence"]);
                relation.Nested = true;
                dtResult.DataSetName = "TasksData";

                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.LoadXml(dtResult.GetXml());
                strMessage = JsonConvert.SerializeXmlNode(doc).Replace("null", "\"\"").Replace("'", "\'");


                //strMessage = JsonConvert.SerializeObject(dtResult, Formatting.Indented);

            }
            else
            {
                strMessage = String.Empty;
            }
            return strMessage;
        }

        [WebMethod(EnableSession = true)]
        public String GetAllTasksforSubSequencing(Int32 DesignationId, String DesiSeqCode, bool IsTechTask, Int64 TaskId)
        {
            string strMessage = string.Empty;
            DataSet dtResult = TaskGeneratorBLL.Instance.GetAllTasksforSubSequencing(DesignationId, DesiSeqCode, IsTechTask, TaskId);

            if (dtResult != null && dtResult.Tables.Count > 0)
            {
                //Context.Response.Clear();
                //Context.Response.ContentType = "application/json";
                //Context.Response.Write(JsonConvert.SerializeObject(dtResult, Formatting.Indented));
                dtResult.Tables[0].TableName = "Tasks";


                strMessage = JsonConvert.SerializeObject(dtResult, Formatting.Indented);

            }
            else
            {
                strMessage = String.Empty;
            }
            return strMessage;
        }


        [WebMethod(EnableSession = true)]
        public bool UpdateTaskSubSequence(Int64 TaskID, Int64 TaskIdSeq, Int64 SubSeqTaskId, Int64 DesignationId)
        {
            string strMessage = string.Empty;
            bool Result = TaskGeneratorBLL.Instance.UpdateTaskSubSequence(TaskID, TaskIdSeq, SubSeqTaskId, DesignationId);

            return Result;

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
                else // if all users are removed, then set task status to open.
                {
                    TaskGeneratorBLL.Instance.UpdateTaskStatus
                                            (
                                                new Task()
                                                {
                                                    TaskId = intTaskId,
                                                    Status = Convert.ToUInt16(JGConstant.TaskStatus.Open)
                                                }
                                            );
                }
                // send email to all users of the department as task is assigned to designation, but not to any specific user.
                //else
                //{
                //    string strUserIDs = string.Join(",", arrDesignationUsers);

                //    SendEmailToAssignedUsers(intTaskId, strUserIDs.TrimEnd(','));
                //}
            }
            return true;
        }

        [WebMethod(EnableSession = true)]
        public bool SetTaskStatus(int intTaskId, string TaskStatus)
        {
            return TaskGeneratorBLL.Instance.SetTaskStatus(intTaskId, TaskStatus);
        }

        [WebMethod(EnableSession = true)]
        public bool TaskSwapSequence(Int64 FirstSequenceId, Int64 SecondSequenceId, Int64 FirstTaskId, Int64 SecondTaskId)
        {
            return TaskGeneratorBLL.Instance.TaskSwapSequence(FirstSequenceId, SecondSequenceId, FirstTaskId, SecondTaskId);
        }

        [WebMethod(EnableSession = true)]
        public bool TaskSwapSubSequence(Int64 FirstSequenceId, Int64 SecondSequenceId, Int64 FirstTaskId, Int64 SecondTaskId)
        {
            return TaskGeneratorBLL.Instance.TaskSwapSubSequence(FirstSequenceId, SecondSequenceId, FirstTaskId, SecondTaskId);
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

        private object SaveSubTask(int ParentTaskId, String Title, String URL, String Desc, String Status, String Priority, String DueDate, String TaskHours, String InstallID, String Attachments, String TaskType, String TaskDesignations, string TaskLvl, bool blTechTask, Int64? Sequence)
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
            objTask.Sequence = Sequence;
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
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}/sr_app/TaskGenerator.aspx?TaskId={1}", JGApplicationInfo.GetSiteURL(), intTaskId));

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

        #region "-- Apptitude Test --"

        [WebMethod(EnableSession = true)]
        public bool SaveExamDesignation(Int64 intExamId, string Designations)
        {
            bool returnVal = true;
            AptitudeTestBLL.Instance.UpdateMCQ_ExamDesignations(intExamId, Designations);
            return returnVal;
        }

        [WebMethod(EnableSession = true)]
        public String GetTestResultsByUserID(Int32 UserID)
        {
            DataTable dtResult = AptitudeTestBLL.Instance.GetPerformanceByUserID(UserID);
            String ExamResults;


            if (dtResult != null)
            {
                ExamResults = JsonConvert.SerializeObject(dtResult, Formatting.Indented);
            }
            else
            {
                ExamResults = String.Empty;
            }

            return ExamResults;

        }

        [WebMethod(EnableSession = true)]
        public static Int32 ExamTimeLeft()
        {
            int secondLeft = 0;

            // if exam start registration time available.
            if (JGSession.ExamTimerSetTime != null)
            {
                // Subtract Registered time from time now will yeild total time taken so far.
                TimeSpan TimeTaken = DateTime.Now.Subtract(Convert.ToDateTime(JGSession.ExamTimerSetTime));

                // Subtract total exam alloted time from time taken will yeild Time left to give exam.
                Double MilliSecondLeft = (JGSession.CurrentExamTime * 60000) - TimeTaken.TotalMilliseconds;

                //TODO: If timeup then call time up methods.

                // If time left to give exam then show that time.
                if (MilliSecondLeft > 0)
                {
                    secondLeft = Convert.ToInt32(MilliSecondLeft * 0.001);
                    //ScriptManager.RegisterStartupScript(this,this.Page.GetType(), "timerDisplay", "startExamTimer(" + secondLeft.ToString() + ");", true); 
                }

            }

            return secondLeft;

        }

        #endregion

        #region "-- Auto Email/SMS Templates --"

        [WebMethod(EnableSession = true)]
        public bool UpdateHTMLTemplateFromId(Int32 TemplateId, String FromID)
        {
            return HTMLTemplateBLL.Instance.UpdateHTMLTemplateFromId(TemplateId, FromID);
        }

        [WebMethod(EnableSession = true)]
        public bool UpdateHTMLTemplateSubject(Int32 TemplateId, String Subject)
        {
            return HTMLTemplateBLL.Instance.UpdateHTMLTemplateSubject(TemplateId, Subject);
        }

        [WebMethod(EnableSession = true)]
        public bool UpdateHTMLTemplateTriggerText(Int32 TemplateId, String TriggerText)
        {
            return HTMLTemplateBLL.Instance.UpdateHTMLTemplateTriggerText(TemplateId, TriggerText);
        }

        [WebMethod(EnableSession = true)]
        public bool UpdateHTMLTemplateFreQuency(Int32 TemplateId, Int32 FrequencyInDays, DateTime FrequencyStartDate, DateTime FrequencyTime)
        {
            // Send only date part to database
            FrequencyStartDate = FrequencyStartDate.Date;

            return HTMLTemplateBLL.Instance.UpdateHTMLTemplateFreQuency(TemplateId, FrequencyInDays, FrequencyStartDate, FrequencyTime);

        }


        [WebMethod(EnableSession = true)]
        public void TriggerBulkAutoEmail(Int32 TemplateId)
        {
            DataSet Designation = CommonFunction.GetDesignations();

            if (Designation != null && Designation.Tables.Count > 0 && Designation.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow RowItem in Designation.Tables[0].Rows)
                {
                    Int32 DesignationId = Convert.ToInt32(RowItem["ID"]);

                    CommonFunction.BulkEmail((HTMLTemplates)Enum.Parse(typeof(HTMLTemplates), TemplateId.ToString()), DesignationId);
                }
            }


        }



        #endregion

        #region "-- HR Module Methods --"

        [WebMethod(EnableSession = true)]
        public bool SendOfferMadeToCandidate(string UserEmail, Int32 UserID, string DesignationID)
        {
            int EditId = UserID;

            InstallUserBLL.Instance.UpdateOfferMade(EditId, UserEmail, "jmgrove");

            //Add User to GitHub Live Repository
            String DesignationCode = InstallUserBLL.Instance.GetUserDesignationCode(EditId);
            if (DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_Sr_Net_Developer))
                || DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_Jr_Net_Developer))
                || DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_Android_Developer))
                || DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_PHP_Developer))
                || DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_Jr_PHP_Developer))
                || DesignationCode.Equals(CommonFunction.GetDesignationCode(JGConstant.DesignationType.IT_Network_Admin))
                )
            {
                String gitUserName = InstallUserBLL.Instance.GetUserGithubUserName(EditId);
                CommonFunction.AddUserAsGitcollaborator(gitUserName, JGConstant.GitRepo.Live);
            }

            DataSet ds = new DataSet();
            string email, HireDate, EmpType, PayRates, Desig, LastName, Address, FirstName;
            email = HireDate = EmpType = PayRates = Desig = LastName = Address = FirstName = String.Empty;

            ds = InstallUserBLL.Instance.ChangeStatus(Convert.ToInt32(JGConstant.InstallUserStatus.OfferMade).ToString(), EditId, DateTime.Today, DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, "Offer Made from HR page - " + CommonFunction.FormatDateTimeString(DateTime.Now));

            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    if (Convert.ToString(ds.Tables[0].Rows[0]["Email"]) != "")
                    {
                        email = Convert.ToString(ds.Tables[0].Rows[0]["Email"]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0]["HireDate"]) != "")
                    {
                        HireDate = Convert.ToString(ds.Tables[0].Rows[0]["HireDate"]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0]["EmpType"]) != "")
                    {
                        EmpType = Convert.ToString(ds.Tables[0].Rows[0]["EmpType"]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0]["PayRates"]) != "")
                    {
                        PayRates = Convert.ToString(ds.Tables[0].Rows[0]["PayRates"]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0]["Designation"]) != "")
                    {
                        Desig = Convert.ToString(ds.Tables[0].Rows[0]["Designation"]);
                    }
                    if (!String.IsNullOrEmpty(ds.Tables[0].Rows[0]["FristName"].ToString()))
                    {
                        FirstName = ds.Tables[0].Rows[0]["FristName"].ToString();
                    }
                    if (!String.IsNullOrEmpty(ds.Tables[0].Rows[0]["LastName"].ToString()))
                    {
                        LastName = ds.Tables[0].Rows[0]["LastName"].ToString();
                    }
                    if (!String.IsNullOrEmpty(ds.Tables[0].Rows[0]["Address"].ToString()))
                    {
                        Address = ds.Tables[0].Rows[0]["Address"].ToString();
                    }
                }
            }
            //string strHtml = JG_Prospect.App_Code.CommonFunction.GetContractTemplateContent(199, 0, Desig);
            DesignationHTMLTemplate objHTMLTemplate = HTMLTemplateBLL.Instance.GetDesignationHTMLTemplate(HTMLTemplates.Offer_Made_Attachment_Template, DesignationID);
            string strHtml = objHTMLTemplate.Header + objHTMLTemplate.Body + objHTMLTemplate.Footer;
            strHtml = strHtml.Replace("#CurrentDate#", DateTime.Now.ToShortDateString());
            strHtml = strHtml.Replace("#FirstName#", FirstName);
            strHtml = strHtml.Replace("#LastName#", LastName);
            strHtml = strHtml.Replace("#Address#", Address);
            strHtml = strHtml.Replace("#Designation#", Desig);

            if (!string.IsNullOrEmpty(EmpType))
            {
                int intEmpType = 0;
                int.TryParse(EmpType, out intEmpType);

                if (intEmpType > 0)
                {
                    EmpType = CommonFunction.GetEnumDescription((JGConstant.EmploymentType)intEmpType);
                }

                strHtml = strHtml.Replace("#EmpType#", EmpType);

            }
            else
            {
                strHtml = strHtml.Replace("#EmpType#", "________________");
            }
            strHtml = strHtml.Replace("#JoiningDate#", HireDate);
            if (!string.IsNullOrEmpty(PayRates))
            {
                strHtml = strHtml.Replace("#RatePerHour#", PayRates);
            }
            else
            {
                strHtml = strHtml.Replace("#RatePerHour#", "____");
            }
            DateTime dtPayCheckDate;
            if (!string.IsNullOrEmpty(HireDate))
            {
                dtPayCheckDate = Convert.ToDateTime(HireDate);
            }
            else
            {
                dtPayCheckDate = DateTime.Now;
            }
            dtPayCheckDate = new DateTime(dtPayCheckDate.Year, dtPayCheckDate.Month, DateTime.DaysInMonth(dtPayCheckDate.Year, dtPayCheckDate.Month));
            strHtml = strHtml.Replace("#PayCheckDate#", dtPayCheckDate.ToShortDateString());

            string strPath = JG_Prospect.App_Code.CommonFunction.ConvertHtmlToPdf(strHtml, Server.MapPath(@"~\Sr_App\MailDocument\MailAttachments\"), "Job acceptance letter");
            List<Attachment> lstAttachments = new List<Attachment>();
            if (File.Exists(strPath))
            {
                Attachment attachment = new Attachment(strPath);
                attachment.Name = Path.GetFileName(strPath);
                lstAttachments.Add(attachment);
            }

            SendEmail(email, FirstName, LastName, "Offer Made", "", Desig, Convert.ToInt32(DesignationID), HireDate, EmpType, PayRates,
                HTMLTemplates.Offer_Made_Auto_Email, lstAttachments);

            //binddata();
            //GetSalesUsersStaticticsAndData();
            //ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopupOfferMade()", true);

            return true;

        }

        [WebMethod(EnableSession = true)]
        public bool SendInterviewDatetoCandidate(string UserEmail, Int32 UserID, string DesignationID, String InterviewDate, String InterviewTime, UInt64 TaskId)
        {
            int EditId = UserID;

            DataSet dsUser = InstallUserBLL.Instance.ChangeStatus
                                                   (
                                                      Convert.ToInt32(JGConstant.InstallUserStatus.InterviewDate).ToString(),
                                                      EditId,
                                                      Convert.ToDateTime(InterviewDate),
                                                      InterviewTime,
                                                      Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]),
                                                      JGSession.IsInstallUser.Value,
                                                      "Interview Date setup from HR page popup - " + CommonFunction.FormatDateTimeString(DateTime.Now)
                                                   );
            String FirstName = string.Empty, LastName = string.Empty, Designation = string.Empty, EmployeeType = string.Empty;

            if (dsUser.Tables.Count > 0 && dsUser.Tables[0].Rows.Count > 0)
            {
                FirstName = Convert.ToString(dsUser.Tables[0].Rows[0]["FristName"]);

                LastName = Convert.ToString(dsUser.Tables[0].Rows[0]["LastName"]);
                Designation = Convert.ToString(dsUser.Tables[0].Rows[0]["Designation"]);
               EmployeeType = Convert.ToString(dsUser.Tables[0].Rows[0]["EmpType"]);
            }

            SendEmail(
                                    UserEmail,
                                    FirstName,
                                    LastName,
                                    "Interview Date Auto Email",
                                    "",
                                    Designation,
                                    Convert.ToInt32(DesignationID),
                                    InterviewDate,
                                    EmployeeType,
                                    "",
                                    HTMLTemplates.InterviewDateAutoEmail,
                                    null,
                                    "JMGC-PC"
                                );

            //AssignedTask if any or Default
            if (TaskId > 0)
            {
                AssignedTaskToUser(UserID, TaskId); 
            }

            return true;

        }

        [WebMethod(EnableSession = true)]
        public string GetEditSalesPopupUsersWithPaging(int PageIndex, int PageSize, String UserIds, String Status, int DesignationId, String SortExpression)
        {
            string strMessage = string.Empty;
            DataSet dtResult = InstallUserBLL.Instance.GetPopupEditUsers(UserIds, Status, DesignationId, PageIndex, PageSize, SortExpression);

            if (dtResult != null && dtResult.Tables.Count > 0)
            {

                dtResult.Tables[0].TableName = "EditSalesUsers";

                strMessage = JsonConvert.SerializeObject(dtResult.Tables[0], Formatting.Indented);
            }
            else
            {
                strMessage = String.Empty;
            }

            return strMessage;

        }

        [WebMethod(EnableSession = true)]
        public string GetInterviewDateSequences(Int32 DesignationId, Int32 UserCount)
        {

            string strMessage = string.Empty;
            DataSet dtResult = TaskGeneratorBLL.Instance.GetInterviewDateSequences(DesignationId, UserCount);

            if (dtResult != null && dtResult.Tables.Count > 0)
            {
                dtResult.Tables[0].TableName = "Sequences";
                strMessage = JsonConvert.SerializeObject(dtResult.Tables[0], Formatting.Indented);
            }
            else
            {
                strMessage = String.Empty;
            }

            return strMessage;
        }
        
        #region "-- Private Methods --"
        private void SendEmail(string emailId, string FName, string LName, string status, string Reason, string Designition, int DesignitionId, string HireDate, string EmpType, string PayRates, HTMLTemplates objHTMLTemplateType, List<Attachment> Attachments = null, string strManager = "")
        {
            DesignationHTMLTemplate objHTMLTemplate = HTMLTemplateBLL.Instance.GetDesignationHTMLTemplate(objHTMLTemplateType, DesignitionId.ToString());

            //DataSet ds = AdminBLL.Instance.GetEmailTemplate(Designition, htmlTempID);// AdminBLL.Instance.FetchContractTemplate(104);
            //if (ds == null)
            //{
            //    ds = AdminBLL.Instance.GetEmailTemplate("Admin", htmlTempID);
            //}
            //else if (ds.Tables[0].Rows.Count == 0)
            //{
            //    ds = AdminBLL.Instance.GetEmailTemplate("Admin", htmlTempID);
            //}

            //string strHeader = ds.Tables[0].Rows[0]["HTMLHeader"].ToString(); //GetEmailHeader(status);
            //string strBody = ds.Tables[0].Rows[0]["HTMLBody"].ToString(); //GetEmailBody(status);
            //string strFooter = ds.Tables[0].Rows[0]["HTMLFooter"].ToString(); // GetFooter(status);
            //string strsubject = ds.Tables[0].Rows[0]["HTMLSubject"].ToString();

            string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
            string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();
            string fullname = FName + " " + LName;

            string strHeader = objHTMLTemplate.Header;
            string strBody = objHTMLTemplate.Body;
            string strFooter = objHTMLTemplate.Footer;
            string strsubject = objHTMLTemplate.Subject;

            strBody = strBody.Replace("#Email#", emailId).Replace("#email#", emailId);
            strBody = strBody.Replace("#FirstName#", FName);
            strBody = strBody.Replace("#LastName#", LName);
            strBody = strBody.Replace("#F&L name#", FName + " " + LName).Replace("#F&amp;L name#", FName + " " + LName);

            strBody = strBody.Replace("#Name#", FName).Replace("#name#", FName);
            strBody = strBody.Replace("#Date#", "").Replace("#date#", "");
            strBody = strBody.Replace("#Time#", "").Replace("#time#", "");
            strBody = strBody.Replace("#Designation#", Designition).Replace("#designation#", Designition);

            strFooter = strFooter.Replace("#Name#", FName).Replace("#name#", FName);
            strFooter = strFooter.Replace("#Date#", "").Replace("#date#", "");
            strFooter = strFooter.Replace("#Time#", "").Replace("#time#", "");
            strFooter = strFooter.Replace("#Designation#", Designition).Replace("#designation#", Designition);

            strBody = strBody.Replace("Lbl Full name", fullname);
            strBody = strBody.Replace("LBL position", Designition);
            //strBody = strBody.Replace("lbl: start date", txtHireDate.Text);
            //strBody = strBody.Replace("($ rate","$"+ txtHireDate.Text);
            strBody = strBody.Replace("Reason", Reason);

            strBody = strBody.Replace("#manager#", strManager);

            strBody = strHeader + strBody + strFooter;

            //Hi #lblFName#, <br/><br/>You are requested to appear for an interview on #lblDate# - #lblTime#.<br/><br/>Regards,<br/>

            if (status == "OfferMade")
            {
                //TODO : commented code for missing directive using Word = Microsoft.Office.Interop.Word;
                //createForeMenForJobAcceptance(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
            }
            if (status == "Deactive")
            {
                //TODO : commented code for missing directive using Word = Microsoft.Office.Interop.Word;
                //CreateDeactivationAttachment(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
            }

            List<Attachment> lstAttachments = objHTMLTemplate.Attachments;

            //for (int i = 0; i < lstAttachments.Count; i++)
            //{
            //    string sourceDir = Server.MapPath(ds.Tables[1].Rows[i]["DocumentPath"].ToString());
            //    if (File.Exists(sourceDir))
            //    {
            //        Attachment attachment = new Attachment(sourceDir);
            //        attachment.Name = Path.GetFileName(sourceDir);
            //        lstAttachments.Add(attachment);
            //    }
            //}

            if (Attachments != null)
            {
                lstAttachments.AddRange(Attachments);
            }

            try
            {
                JG_Prospect.App_Code.CommonFunction.SendEmail(Designition, emailId, strsubject, strBody, lstAttachments);

                //ScriptManager.RegisterStartupScript(this, this.GetType(), "UserMsg", "alert('An email notification has sent on " + emailId + ".');", true);
            }
            catch
            {
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "UserMsg", "alert('Error while sending email notification on " + emailId + ".');", true);
            }
        }

        private void AssignedTaskToUser(int UserID, UInt64 TaskId)
        {
            string ApplicantId = UserID.ToString();

            //If dropdown has any value then assigned it to user else. return 
            if (TaskId > 0)
            {
                // save (insert / delete) assigned users.
                //bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(ddlTechTask.SelectedValue), Session["EditId"].ToString());

                // save assigned user a TASK.
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedToMultipleUsers(TaskId, ApplicantId);

                // Change task status to assigned = 3.
                if (isSuccessful)
                    UpdateTaskStatus(Convert.ToInt32(TaskId), Convert.ToUInt16(JGConstant.TaskStatus.Assigned));

                SendEmailToAssignedUsers(Convert.ToInt32(TaskId), UserID.ToString());
            }
        }

        private void UpdateTaskStatus(Int32 taskId, UInt16 Status)
        {
            Task task = new Task();
            task.TaskId = taskId;
            task.Status = Status;

            int result = TaskGeneratorBLL.Instance.UpdateTaskStatus(task);    // save task master details

            //String AlertMsg;

            //if (result > 0)
            //{
            //    AlertMsg = "Status changed successfully!";
            //}
            //else
            //{
            //    AlertMsg = "Status change was not successfull, Please try again later.";
            //}
        }

        #endregion
        
        #endregion
    }
}
