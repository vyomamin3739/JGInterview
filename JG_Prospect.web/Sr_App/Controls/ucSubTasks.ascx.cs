#region '--using--'

using JG_Prospect.App_Code;
using JG_Prospect.BLL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using Saplin.Controls;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

#endregion

namespace JG_Prospect.Sr_App.Controls
{
    public partial class ucSubTasks : System.Web.UI.UserControl
    {
        #region '--Members--'

        private List<string> lstSubTaskFiles = new List<string>();

        #endregion

        #region '--Properties--'

        public delegate void OnLoadTaskData(Int64 intTaskId);

        public OnLoadTaskData LoadTaskData;

        public EventHandler OnAddNewSubTask;

        public int TaskId { get; set; }

        public int HighlightedTaskId { get; set; }

        public string controlMode { get; set; }

        public bool IsAdminMode { get; set; }

        public JGConstant.TaskStatus TaskStatus
        {
            get;
            set;
        }

        public bool UserAcceptance
        {
            get;
            set;
        }

        public String LastSubTaskSequence
        {
            get
            {
                if (ViewState["LastSubTaskSequence"] != null)
                {
                    return ViewState["LastSubTaskSequence"].ToString();
                }
                return string.Empty;
            }
            set
            {
                ViewState["LastSubTaskSequence"] = value;
            }
        }

        private List<Task> lstSubTasks
        {
            get
            {
                if (ViewState["lstSubTasks"] == null)
                {
                    ViewState["lstSubTasks"] = new List<Task>();
                }
                return (List<Task>)ViewState["lstSubTasks"];
            }
            set
            {
                ViewState["lstSubTasks"] = value;
            }
        }

        private SortDirection SubTaskSortDirection
        {
            get
            {
                if (ViewState["SubTaskSortDirection"] == null)
                {
                    return SortDirection.Descending;
                }
                return (SortDirection)ViewState["SubTaskSortDirection"];
            }
            set
            {
                ViewState["SubTaskSortDirection"] = value;
            }
        }

        private string SubTaskSortExpression
        {
            get
            {
                if (ViewState["SubTaskSortExpression"] == null)
                {
                    return "CreatedOn";
                }
                return Convert.ToString(ViewState["SubTaskSortExpression"]);
            }
            set
            {
                ViewState["SubTaskSortExpression"] = value;
            }
        }

        public string SubTaskDesignations
        {
            get
            {
                if (ViewState["SubTaskDesignations"] == null)
                {
                    return string.Empty;
                }
                return Convert.ToString(ViewState["SubTaskDesignations"]);
            }
            set
            {
                ViewState["SubTaskDesignations"] = value;
            }
        }

        #endregion

        #region '--Page Events--'

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                FillInitialData();
                hdnAdminMode.Value = this.IsAdminMode.ToString();
            }
        }

        #endregion

        #region '--Control Events--'

        #region '--gvSubTasks--'

        protected void gvSubTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                ListBox ddcbAssigned = e.Row.FindControl("ddcbAssigned") as ListBox;
                Label lblAssigned = e.Row.FindControl("lblAssigned") as Label;

                if (this.IsAdminMode)
                {
                    DataSet dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")).Trim());

                    ddcbAssigned.Items.Clear();
                    ddcbAssigned.DataSource = dsUsers;
                    ddcbAssigned.DataTextField = "FristName";
                    ddcbAssigned.DataValueField = "Id";
                    ddcbAssigned.DataBind();

                    ddcbAssigned.Attributes.Add("TaskId", DataBinder.Eval(e.Row.DataItem, "TaskId").ToString());
                    ddcbAssigned.Attributes.Add("TaskStatus", DataBinder.Eval(e.Row.DataItem, "Status").ToString());

                    SetTaskAssignedUsers(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")), ddcbAssigned);

                    lblAssigned.Visible = false;
                }
                else
                {
                    lblAssigned.Text = getSingleValueFromCommaSeperatedString(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")));
                    lblAssigned.ToolTip = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers"));
                    ddcbAssigned.Visible = false;
                }

                DropDownList ddlStatus = e.Row.FindControl("ddlStatus") as DropDownList;
                ddlStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlStatus.DataTextField = "Text";
                ddlStatus.DataValueField = "Value";
                ddlStatus.DataBind();
                //ddlStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;

                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TaskType").ToString()))
                {
                    (e.Row.FindControl("ltrlTaskType") as Literal).Text = CommonFunction.GetTaskTypeList().FindByValue(DataBinder.Eval(e.Row.DataItem, "TaskType").ToString()).Text;
                }

                DropDownList ddlTaskPriority = e.Row.FindControl("ddlTaskPriority") as DropDownList;
                if (ddlTaskPriority != null)
                {
                    ddlTaskPriority.DataSource = CommonFunction.GetTaskPriorityList();
                    ddlTaskPriority.DataTextField = "Text";
                    ddlTaskPriority.DataValueField = "Value";
                    ddlTaskPriority.DataBind();

                    if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TaskPriority").ToString()))
                    {
                        ddlTaskPriority.SelectedValue = DataBinder.Eval(e.Row.DataItem, "TaskPriority").ToString();
                    }

                    //if (controlMode == "0")
                    //{
                    //    ddlTaskPriority.Attributes.Add("SubTaskIndex", e.Row.RowIndex.ToString());
                    //}
                    //else
                    {
                        ddlTaskPriority.Attributes.Add("TaskId", DataBinder.Eval(e.Row.DataItem, "TaskId").ToString());
                    }
                }

                SetStatusSelectedValue(ddlStatus, DataBinder.Eval(e.Row.DataItem, "Status").ToString());

                if (this.IsAdminMode)
                {
                    e.Row.FindControl("ltrlInstallId").Visible = false;
                }
                else
                {
                    e.Row.FindControl("lbtnInstallId").Visible = false;

                    if (!ddlStatus.SelectedValue.Equals(Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()))
                    {
                        ddlStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()).Enabled = false;
                    }
                }

                //if (controlMode == "0")
                //{
                //    ddlStatus.Attributes.Add("SubTaskIndex", e.Row.RowIndex.ToString());
                //}
                //else
                {
                    ddlStatus.Attributes.Add("TaskId", DataBinder.Eval(e.Row.DataItem, "TaskId").ToString());
                }

                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TaskUserFiles").ToString()))
                {
                    string attachments = DataBinder.Eval(e.Row.DataItem, "TaskUserFiles").ToString();
                    string[] attachment = attachments.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    if (attachment != null && attachment.Length > 0)
                    {
                        this.lstSubTaskFiles.AddRange(attachment);
                    }

                    Repeater rptAttachments = (Repeater)e.Row.FindControl("rptAttachment");
                    rptAttachments.DataSource = attachment;
                    rptAttachments.DataBind();
                }

                CheckBox chkAdmin = e.Row.FindControl("chkAdmin") as CheckBox;
                CheckBox chkITLead = e.Row.FindControl("chkITLead") as CheckBox;
                CheckBox chkUser = e.Row.FindControl("chkUser") as CheckBox;

                TextBox txtPasswordToFreezeSubTask = e.Row.FindControl("txtPasswordToFreezeSubTask") as TextBox;

                bool blAdminStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "AdminStatus"));
                bool blTechLeadStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "TechLeadStatus"));
                bool blOtherUserStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "OtherUserStatus"));

                chkAdmin.Checked = blAdminStatus;
                chkITLead.Checked = blTechLeadStatus;
                chkUser.Checked = blOtherUserStatus;

                chkAdmin.Enabled = !blAdminStatus;
                chkITLead.Enabled = !blTechLeadStatus;
                chkUser.Enabled = !blOtherUserStatus;

                SetFreezeColumnUI(txtPasswordToFreezeSubTask, chkAdmin, chkITLead, chkUser);

                if (chkAdmin.Enabled)
                {
                    chkAdmin.Attributes.Add("onclick", "ucSubTasks_OnApprovalCheckBoxChanged(this);");
                }
                if (blAdminStatus)
                {
                    e.Row.FindControl("divAdmin").Visible = true;
                }
                if (chkITLead.Enabled)
                {
                    chkITLead.Attributes.Add("onclick", "ucSubTasks_OnApprovalCheckBoxChanged(this);");
                }
                if (blTechLeadStatus)
                {
                    e.Row.FindControl("divITLead").Visible = true;
                }
                if (chkUser.Enabled)
                {
                    chkUser.Attributes.Add("onclick", "ucSubTasks_OnApprovalCheckBoxChanged(this);");
                }
                if (blOtherUserStatus)
                {
                    e.Row.FindControl("divUser").Visible = true;
                }

                if (blAdminStatus && blTechLeadStatus && blOtherUserStatus && !this.IsAdminMode)// Added condition for allowing admin to edit task even after freezing task.
                {
                    e.Row.FindControl("ltrlInstallId").Visible = true;
                    e.Row.FindControl("lbtnInstallId").Visible = false;
                }

                string strRowCssClass = string.Empty;

                if (e.Row.RowState == DataControlRowState.Alternate)
                {
                    strRowCssClass = "AlternateRow";
                }
                else
                {
                    strRowCssClass = "FirstRow";
                }

                JGConstant.TaskStatus objTaskStatus = (JGConstant.TaskStatus)Convert.ToByte(DataBinder.Eval(e.Row.DataItem, "Status"));
                JGConstant.TaskPriority? objTaskPriority = null;

                if (
                    !string.IsNullOrEmpty(ddlTaskPriority.SelectedValue) &&
                    ddlTaskPriority.SelectedValue != "0"
                   )
                {
                    objTaskPriority = (JGConstant.TaskPriority)Convert.ToByte(ddlTaskPriority.SelectedValue);
                }

                strRowCssClass += " " + CommonFunction.GetTaskRowCssClass(objTaskStatus, objTaskPriority);

                switch (objTaskStatus)
                {
                    case JGConstant.TaskStatus.Closed:
                        ddcbAssigned.Enabled = false;
                        ddlStatus.Enabled = false;
                        break;
                    case JGConstant.TaskStatus.Deleted:
                        ddcbAssigned.Enabled = false;
                        ddlStatus.Enabled = false;
                        break;
                }

                if (Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "TaskId")) == this.HighlightedTaskId)
                {
                    strRowCssClass += " yellowthickborder";
                }

                e.Row.CssClass = strRowCssClass;

            }
        }

        protected void gvSubTasks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("edit-sub-task"))
            {
                ClearSubTaskData();

                hdnTaskApprovalId.Value = "0";
                hdnSubTaskId.Value = "0";
                hdnSubTaskIndex.Value = "-1";

                btnSaveSubTaskAttachment.Visible = true;

                //if (controlMode == "0")
                //{
                //    hdnSubTaskIndex.Value = e.CommandArgument.ToString();

                //    Task objTask = this.lstSubTasks[Convert.ToInt32(hdnSubTaskIndex.Value)];

                //    txtTaskListID.Text = objTask.InstallId.ToString();
                //    txtSubTaskTitle.Text = Server.HtmlDecode(objTask.Title);
                //    txtSubTaskDescription.Text = Server.HtmlDecode(objTask.Description);

                //    if (objTask.TaskType.HasValue && ddlTaskType.Items.FindByValue(objTask.TaskType.Value.ToString()) != null)
                //    {
                //        ddlTaskType.SelectedValue = objTask.TaskType.Value.ToString();
                //    }

                //    txtSubTaskDueDate.Text = CommonFunction.FormatToShortDateString(objTask.DueDate);
                //    txtSubTaskHours.Text = objTask.Hours;
                //    ddlSubTaskStatus.SelectedValue = objTask.Status.ToString();
                //    if (objTask.TaskPriority.HasValue)
                //    {
                //        ddlSubTaskPriority.SelectedValue = objTask.TaskPriority.Value.ToString();
                //    }
                //}
                //else
                //{
                    int intRowIndex = Convert.ToInt32(e.CommandArgument);
                    hdnSubTaskId.Value = gvSubTasks.DataKeys[intRowIndex]["TaskId"].ToString();
                    hdnTaskApprovalId.Value = (gvSubTasks.Rows[intRowIndex].FindControl("hdnTaskApprovalId") as HiddenField).Value;
                    txtEstimatedHours.Text = (gvSubTasks.Rows[intRowIndex].FindControl("txtEstimatedHours") as TextBox).Text;

                    DataSet dsTaskDetails = TaskGeneratorBLL.Instance.GetTaskDetails(Convert.ToInt32(hdnSubTaskId.Value));

                    DataTable dtTaskMasterDetails = dsTaskDetails.Tables[0];
                    DataTable dtTaskDesignationDetails = dsTaskDetails.Tables[1];

                    txtTaskListID.Text = dtTaskMasterDetails.Rows[0]["InstallId"].ToString();
                    txtSubTaskTitle.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Title"].ToString());
                    txtUrl.Text = dtTaskMasterDetails.Rows[0]["Url"].ToString();
                    txtSubTaskDescription.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Description"].ToString());

                    ListItem item = ddlTaskType.Items.FindByValue(dtTaskMasterDetails.Rows[0]["TaskType"].ToString());

                    if (item != null)
                    {
                        ddlTaskType.SelectedIndex = ddlTaskType.Items.IndexOf(item);
                    }

                    txtSubTaskDueDate.Text = CommonFunction.FormatToShortDateString(dtTaskMasterDetails.Rows[0]["DueDate"]);
                    txtSubTaskHours.Text = dtTaskMasterDetails.Rows[0]["Hours"].ToString();
                    ddlSubTaskStatus.SelectedValue = dtTaskMasterDetails.Rows[0]["Status"].ToString();
                    if (!this.IsAdminMode)
                    {
                        if (!ddlSubTaskStatus.SelectedValue.Equals(Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()))
                        {
                            ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()).Enabled = false;
                        }
                    }
                    trSubTaskStatus.Visible = true;
                    if (!string.IsNullOrEmpty(dtTaskMasterDetails.Rows[0]["TaskPriority"].ToString()))
                    {
                        ddlSubTaskPriority.SelectedValue = dtTaskMasterDetails.Rows[0]["TaskPriority"].ToString();
                    }

                    int numbersequence;
                    if (ExtensionMethods.TryRomanParse(txtTaskListID.Text, out numbersequence))
                    {
                        rfvTitle.Enabled =
                        rfvUrl.Enabled = true;
                    }
                    else
                    {
                        rfvTitle.Enabled =
                        rfvUrl.Enabled = false;
                    }

                    SetTaskDesignationDetails(dtTaskDesignationDetails);

                    FillSubtaskAttachments(Convert.ToInt32(hdnSubTaskId.Value));
                //}
                
                upAddSubTask.Update();
                hdnCurrentEditingRow.Value = intRowIndex.ToString();

                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "sliddownsubtaskbelowrespectivetask", String.Concat("showSubTaskEditView('#",divSubTask.ClientID,"',", hdnCurrentEditingRow.Value, ");"), true);
            }
            else if (e.CommandName.Equals("sub-task-feedback"))
            {
                ltrlSubTaskFeedbackTitle.Text = "Sub Task : " + gvSubTasks.DataKeys[Convert.ToInt32(e.CommandArgument)]["InstallId"].ToString();

                //Commented By: Yogesh Keraliya
                //Date: 12132016
                // All users can add comment to task now.
                //if (this.IsAdminMode)
                //{
                //    tblAddEditSubTaskFeedback.Visible = true;
                //}
                //else
                //{
                //    tblAddEditSubTaskFeedback.Visible = false;
                //}
                upSubTaskFeedbackPopup.Update();
                ScriptManager.RegisterStartupScript(
                                                    (sender as Control),
                                                    this.GetType(),
                                                    "ShowPopup",
                                                    string.Format(
                                                                    "ShowPopup(\"#{0}\");",
                                                                    divSubTaskFeedbackPopup.ClientID
                                                                ),
                                                    true
                                              );
            }
        }

        protected void gvSubTasks_Sorting(object sender, GridViewSortEventArgs e)
        {
            if (this.SubTaskSortExpression == e.SortExpression)
            {
                if (this.SubTaskSortDirection == SortDirection.Ascending)
                {
                    this.SubTaskSortDirection = SortDirection.Descending;
                }
                else
                {
                    this.SubTaskSortDirection = SortDirection.Ascending;
                }
            }
            else
            {
                this.SubTaskSortExpression = e.SortExpression;
                this.SubTaskSortDirection = SortDirection.Ascending;
            }

            SetSubTaskDetails();
        }

        protected void gvSubTasks_ddcbAssigned_SelectedIndexChanged(object sender, EventArgs e)
        {
            ListBox ddcbAssigned = (ListBox)sender;
            GridViewRow objGridViewRow = (GridViewRow)ddcbAssigned.NamingContainer;
            int intTaskId = Convert.ToInt32(ddcbAssigned.Attributes["TaskId"].ToString());
            DropDownList ddlTaskStatus = objGridViewRow.FindControl("ddlStatus") as DropDownList;

            if (ValidateTaskStatus(ddlTaskStatus, ddcbAssigned, intTaskId))
            {
                SaveAssignedTaskUsers(ddcbAssigned, (JGConstant.TaskStatus)Convert.ToByte(ddcbAssigned.Attributes["TaskStatus"]), intTaskId);
            }

            SetSubTaskDetails();
        }

        protected void gvSubTasks_ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddlStatus = sender as DropDownList;
            //if (controlMode == "0")
            //{
            //    this.lstSubTasks[Convert.ToInt32(ddlStatus.Attributes["SubTaskIndex"].ToString())].Status = Convert.ToInt32(ddlStatus.SelectedValue);

            //    SetSubTaskDetails(this.lstSubTasks);
            //}
            //else
            {
                TaskGeneratorBLL.Instance.UpdateTaskStatus
                                            (
                                                new Task()
                                                {
                                                    TaskId = Convert.ToInt32(ddlStatus.Attributes["TaskId"].ToString()),
                                                    Status = Convert.ToInt32(ddlStatus.SelectedValue)
                                                }
                                            );

                SetSubTaskDetails();
            }
        }

        protected void gvSubTasks_ddlTaskPriority_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddlTaskPriority = sender as DropDownList;
            //if (controlMode == "0")
            //{
            //    if (ddlTaskPriority.SelectedValue == "0")
            //    {
            //        this.lstSubTasks[Convert.ToInt32(ddlTaskPriority.Attributes["SubTaskIndex"].ToString())].TaskPriority = null;
            //    }
            //    else
            //    {
            //        this.lstSubTasks[Convert.ToInt32(ddlTaskPriority.Attributes["SubTaskIndex"].ToString())].TaskPriority = Convert.ToByte(ddlTaskPriority.SelectedValue);
            //    }

            //    SetSubTaskDetails(this.lstSubTasks);
            //}
            //else
            {
                Task objTask = new Task();
                objTask.TaskId = Convert.ToInt32(ddlTaskPriority.Attributes["TaskId"].ToString());
                if (ddlTaskPriority.SelectedValue == "0")
                {
                    objTask.TaskPriority = null;
                }
                else
                {
                    objTask.TaskPriority = Convert.ToByte(ddlTaskPriority.SelectedItem.Value);
                }
                TaskGeneratorBLL.Instance.UpdateTaskPriority(objTask);

                SetSubTaskDetails();
            }
        }

        protected void gvSubTasks_txtPasswordToFreezeSubTask_TextChanged(object sender, EventArgs e)
        {
            TextBox txtPassword = sender as TextBox;
            GridViewRow objGridViewRow = txtPassword.Parent.Parent as GridViewRow;

            if (objGridViewRow != null)
            {
                decimal decEstimatedHours = 0;
                TextBox txtEstimatedHours = objGridViewRow.FindControl("txtEstimatedHours") as TextBox;
                HiddenField hdnTaskApprovalId = objGridViewRow.FindControl("hdnTaskApprovalId") as HiddenField;

                if (txtPassword == null || string.IsNullOrEmpty(txtPassword.Text))
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Sub Task cannot be freezed as password is not provided.");
                }
                else if (!txtPassword.Text.Equals(Convert.ToString(Session["loginpassword"])))
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Sub Task cannot be freezed as password is not valid.");
                }
                else if (txtEstimatedHours == null || string.IsNullOrEmpty(txtEstimatedHours.Text))
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Sub Task cannot be freezed as estimated hours is not provided.");
                }
                else if (!decimal.TryParse(txtEstimatedHours.Text.Trim(), out decEstimatedHours) || decEstimatedHours <= 0)
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Sub Task cannot be freezed as estimated hours is not valid.");
                }
                else
                {
                    #region Update Estimated Hours

                    TaskApproval objTaskApproval = new TaskApproval();
                    if (string.IsNullOrEmpty(hdnTaskApprovalId.Value))
                    {
                        objTaskApproval.Id = 0;
                    }
                    else
                    {
                        objTaskApproval.Id = Convert.ToInt64(hdnTaskApprovalId.Value);
                    }
                    objTaskApproval.EstimatedHours = txtEstimatedHours.Text.Trim();
                    objTaskApproval.Description = string.Empty;
                    objTaskApproval.TaskId = Convert.ToInt32(gvSubTasks.DataKeys[objGridViewRow.RowIndex]["TaskId"].ToString());
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

                    objTask.TaskId = Convert.ToInt32(gvSubTasks.DataKeys[objGridViewRow.RowIndex]["TaskId"].ToString());

                    bool blIsAdmin, blIsTechLead, blIsUser;

                    blIsAdmin = blIsTechLead = blIsUser = false;
                    if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
                    {
                        objTask.AdminUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        objTask.IsAdminInstallUser = JGSession.IsInstallUser.Value;
                        objTask.AdminStatus = true;
                        blIsAdmin = true;
                    }
                    else if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
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

                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Sub Task freezed successfully.");

                    #endregion
                }

                SetSubTaskDetails();
            }
        }

        protected void gvSubTasks_chkUiRequested_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox chkUiRequested = sender as CheckBox;
            GridViewRow objGridViewRow = chkUiRequested.Parent.Parent as GridViewRow;

            if (objGridViewRow != null)
            {
                Int64 intTaskId = Convert.ToInt32(gvSubTasks.DataKeys[objGridViewRow.RowIndex]["TaskId"].ToString());
                TaskGeneratorBLL.Instance.UpdateTaskUiRequested(intTaskId, chkUiRequested.Checked);
            }
            SetSubTaskDetails();
        }

        #endregion

        #region '--gvSubTasks : Attachment Column--'

        protected void rptAttachment_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadFile")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[1].Trim(), files[2].Trim());
            }
            else if (e.CommandName == "delete-attachment")
            {
                DeleteWorkSpecificationFile(e.CommandArgument.ToString());

                SetSubTaskDetails();
            }
        }

        protected void rptAttachment_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string file = Convert.ToString(e.Item.DataItem);

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                LinkButton lbtnDelete = (LinkButton)e.Item.FindControl("lbtnDelete");
                LinkButton lbtnAttchment = (LinkButton)e.Item.FindControl("lbtnDownload");
                //Literal ltlFileName = (Literal)e.Item.FindControl("ltlFileName");
                Literal ltlUpdateTime = (Literal)e.Item.FindControl("ltlUpdateTime");
                Literal ltlCreatedUser = (Literal)e.Item.FindControl("ltlCreatedUser");

                lbtnDelete.CommandArgument = files[0] + "|" + files[1];

                if (files[2].Length > 13)// sort name with ....
                {
                    lbtnAttchment.Text = files[2];// String.Concat(files[2].Substring(0, 12), "..");
                    lbtnAttchment.Attributes.Add("title", files[2]);

                    //ltlFileName.Text = lbtnAttchment.Text;
                }
                else
                {
                    lbtnAttchment.Text = files[2];
                    //ltlFileName.Text = lbtnAttchment.Text;
                }

                ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);

                HtmlImage imgIcon = e.Item.FindControl("imgIcon") as HtmlImage;

                if (CommonFunction.IsImageFile(files[1].Trim()))
                {
                    imgIcon.Src = Page.ResolveUrl(string.Concat("~/TaskAttachments/", CommonFunction.ReplaceEncodeWhiteSpace(Server.UrlEncode(files[1].Trim()))));
                }
                else
                {
                    imgIcon.Src = CommonFunction.GetFileTypeIcon(files[1].Trim(), this.Page);
                }

                ((HtmlGenericControl)e.Item.FindControl("liImage")).Attributes.Add("data-thumb", imgIcon.Src);

                lbtnAttchment.CommandArgument = file;

                if (files.Length > 3)// if there are attachements available.
                {
                    ltlCreatedUser.Text = files[4]; // created user name
                    ltlUpdateTime.Text = string.Concat(
                                                        "<span>",
                                                        string.Format(
                                                                        "{0:M/d/yyyy}",
                                                                        Convert.ToDateTime(files[3])
                                                                     ),
                                                        "</span>&nbsp",
                                                        "<span style=\"color: red\">",
                                                        string.Format(
                                                                        "{0:hh:mm:ss tt}",
                                                                        Convert.ToDateTime(files[3])
                                                                        ),
                                                        "</span>&nbsp<span>(EST)</span>"
                                                     );
                }
            }
        }

        #endregion

        #region '--Add / Edit SubTask : Attachment--'

        protected void rptSubTaskAttachments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string file = Convert.ToString(DataBinder.Eval(e.Item.DataItem, "attachment"));

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                LinkButton lbtnAttchment = (LinkButton)e.Item.FindControl("lbtnDownload");
                LinkButton lbtnDeleteAttchment = (LinkButton)e.Item.FindControl("lbtnDelete");

                //ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);
                //ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnDeleteAttchment);

                lbtnDeleteAttchment.CommandArgument = Convert.ToString(DataBinder.Eval(e.Item.DataItem, "Id")) + "|" + files[0];

                if (files[1].Length > 40)// sort name with ....
                {
                    lbtnAttchment.Text = files[1]; // String.Concat(files[1].Substring(0, 40), "..");
                    lbtnAttchment.Attributes.Add("title", files[1]);
                }
                else
                {
                    lbtnAttchment.Text = files[1];
                }
                ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);
                lbtnAttchment.CommandArgument = file;

                if (CommonFunction.IsImageFile(files[0].Trim()))
                {
                    ((HtmlImage)e.Item.FindControl("imgIcon")).Src = String.Concat("~/TaskAttachments/", CommonFunction.ReplaceEncodeWhiteSpace(Server.UrlEncode(files[0].Trim())));
                }
                else
                {
                    ((HtmlImage)e.Item.FindControl("imgIcon")).Src = CommonFunction.GetFileTypeIcon(files[0].Trim(), this.Page);
                }
            }
        }

        protected void rptSubTaskAttachments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "download-attachment")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[0].Trim(), files[1].Trim());
            }
            else if (e.CommandName == "delete-attachment")
            {
                DeleteWorkSpecificationFile(e.CommandArgument.ToString());

                //Reload records.
                FillSubtaskAttachments(Convert.ToInt32(hdnSubTaskId.Value));

                SetSubTaskDetails();
                //ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "sliddownsubtaskbelowrespectivetask", String.Concat("showSubTaskEditView('#", divSubTask.ClientID, "',", hdnCurrentEditingRow.Value, ");"), true);
            }

        }

        #endregion

        #region '--rptImageGallery--'

        protected void rptImageGallery_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string file = Convert.ToString(e.Item.DataItem);

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                if (CommonFunction.IsImageFile(files[0].Trim()))
                {
                    string strUrl = Page.ResolveUrl(string.Concat("~/TaskAttachments/", CommonFunction.ReplaceEncodeWhiteSpace(Server.UrlEncode(files[0].Trim()))));
                    ((HtmlImage)e.Item.FindControl("imgImage")).Src = strUrl;
                    ((HtmlGenericControl)e.Item.FindControl("liImage")).Attributes.Add("data-thumb", strUrl);
                }
                else
                {
                    e.Item.FindControl("liImage").Visible = false;
                }
            }
        }

        #endregion

        protected void btnSaveCommentAttachment_Click(object sender, EventArgs e)
        {
            UploadUserAttachements(null, hdnSubTaskNoteAttachments.Value);

            hdnSubTaskNoteAttachments.Value = "";

            Response.Redirect("~/Sr_App/TaskGenerator.aspx?TaskId=" + TaskId.ToString());

        }

        protected void btnSaveSubTaskFeedback_Click(object sender, EventArgs e)
        {
            string notes = txtSubtaskComment.Text;

            if (string.IsNullOrEmpty(notes))
                return;

            SaveTaskNotesNAttachments();

            ScriptManager.RegisterStartupScript(
                                                   (sender as Control),
                                                   this.GetType(),
                                                   "HidePopup",
                                                   string.Format(
                                                                   "HidePopup(\"#{0}\");",
                                                                   divSubTaskFeedbackPopup.ClientID
                                                               ),
                                                   true
                                             );

            Response.Redirect("~/Sr_App/TaskGenerator.aspx?TaskId=" + TaskId.ToString());

        }

        protected void lbtnAddNewSubTask_Click(object sender, EventArgs e)
        {
            if (OnAddNewSubTask != null)
            {
                OnAddNewSubTask(sender, e);
            }

            ShowAddNewSubTaskSection(false);
        }

        //protected void ddlTaskType_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (ddlTaskType.SelectedValue == Convert.ToInt16(JGConstant.TaskType.Enhancement).ToString())
        //    {
        //        trDateHours.Visible = true;
        //    }
        //    else
        //    {
        //        trDateHours.Visible = false;
        //    }
        //    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
        //}

        protected void ddlUserDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            //LoadUsersByDesgination();

            //ddlAssignedUsers_SelectedIndexChanged(sender, e);

            ddlUserDesignation.Texts.SelectBoxCaption = "Select";

            foreach (ListItem item in ddlUserDesignation.Items)
            {
                if (item.Selected)
                {
                    ddlUserDesignation.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
        }

        protected void btnSaveSubTaskAttachment_Click(object sender, EventArgs e)
        {
            if (hdnSubTaskId.Value != "0" && !string.IsNullOrEmpty(hdnAttachments.Value))
            {
                UploadUserAttachements(null, Convert.ToInt64(hdnSubTaskId.Value), hdnAttachments.Value, JGConstant.TaskFileDestination.SubTask);

                FillSubtaskAttachments(Convert.ToInt32(hdnSubTaskId.Value));

                hdnAttachments.Value = string.Empty;
                upAttachmentsData.Update();
            }

            //ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);

            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "sliddownsubtaskbelowrespectivetask", String.Concat("showSubTaskEditView('#", divSubTask.ClientID, "',", hdnCurrentEditingRow.Value, ");"), true);
        }

        protected void btnSaveSubTask_Click(object sender, EventArgs e)
        {
            SaveSubTask();
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slidupsubtaskbelowrespectivetask", String.Concat("hideSubTaskEditView('#", divSubTask.ClientID, "',", hdnCurrentEditingRow.Value, ");"), true);
        }

        #endregion

        #region '--Methods--'

        private void SetTaskDesignationDetails(DataTable dtTaskDesignationDetails)
        {
            String firstDesignation = string.Empty;
            if (this.IsAdminMode)
            {
                foreach (DataRow row in dtTaskDesignationDetails.Rows)
                {
                    ListItem item = ddlUserDesignation.Items.FindByText(row["Designation"].ToString());

                    if (item != null)
                    {
                        item.Selected = true;

                        if (string.IsNullOrEmpty(firstDesignation))
                        {
                            firstDesignation = item.Text;
                        }
                    }
                }

                ddlUserDesignation.Texts.SelectBoxCaption = firstDesignation;

                //LoadUsersByDesgination();
            }
            else
            {
                StringBuilder designations = new StringBuilder(string.Empty);

                foreach (DataRow row in dtTaskDesignationDetails.Rows)
                {
                    designations.Append(String.Concat(row["Designation"].ToString(), ","));
                }

                //ltlTUDesig.Text = string.IsNullOrEmpty(designations.ToString()) == true ? string.Empty : designations.ToString().Substring(0, designations.ToString().Length - 1);
            }
        }

        private string GetSelectedDesignationsString()
        {
            //String returnVal = string.Empty;
            //StringBuilder sbDesignations = new StringBuilder();

            //foreach (ListItem item in ddlUserDesignation.Items)
            //{
            //    if (item.Selected)
            //    {
            //        sbDesignations.Append(String.Concat(item.Value, ","));
            //    }
            //}

            //if (sbDesignations.Length > 0)
            //{
            //    returnVal = sbDesignations.ToString().Substring(0, sbDesignations.ToString().Length - 1);
            //}

            //return returnVal;
            return this.SubTaskDesignations;
        }

        private bool ValidateTaskStatus(DropDownList ddlTaskStatus, ListBox ddlAssignedUser, Int32 intTaskId)
        {
            bool blResult = true;

            string strStatus = string.Empty;
            string strMessage = string.Empty;

            if (this.IsAdminMode)
            {
                strStatus = ddlTaskStatus.SelectedValue;

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
                if (strStatus == Convert.ToByte(JGConstant.TaskStatus.Assigned).ToString())
                {
                    blResult = false;
                    strMessage = "Task must be assigned to one or more users, to change status to assigned.";

                    foreach (ListItem objItem in ddlAssignedUser.Items)
                    {
                        if (objItem.Selected)
                        {
                            blResult = true;
                            break;
                        }
                    }
                }

                if (!blResult)
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, strMessage);
                }
            }

            return blResult;
        }

        private void SaveAssignedTaskUsers(ListBox ddcbAssigned, JGConstant.TaskStatus objTaskStatus, Int32 intTaskId)
        {
            //if task id is available to save its note and attachement.
            if (intTaskId != 0)
            {
                string strUsersIds = string.Empty;

                foreach (ListItem item in ddcbAssigned.Items)
                {
                    if (item.Selected)
                    {
                        strUsersIds = strUsersIds + (item.Value + ",");
                    }
                }

                // removes any extra comma "," from the end of the string.
                strUsersIds = strUsersIds.TrimEnd(',');

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
                    string strUserIDs = "";

                    foreach (ListItem item in ddcbAssigned.Items)
                    {
                        strUserIDs += string.Concat(item.Value, ",");
                    }

                    SendEmailToAssignedUsers(intTaskId, strUserIDs.TrimEnd(','));
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
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}://{1}/sr_app/TaskGenerator.aspx?TaskId={2}", Request.Url.Scheme, Request.Url.Host.ToString(), intTaskId));

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
                Console.WriteLine("{0} Exception caught.", ex);
            }
        }

        private string getSingleValueFromCommaSeperatedString(string commaSeperatedString)
        {
            String strReturnVal;

            if (commaSeperatedString.Contains(","))
            {
                strReturnVal = String.Concat(commaSeperatedString.Substring(0, commaSeperatedString.IndexOf(",")), "..");
            }
            else
            {
                strReturnVal = commaSeperatedString;
            }

            return strReturnVal;
        }

        private void SetTaskAssignedUsers(String strAssignedUser, ListBox taskUsers)
        {
            String firstAssignedUser = String.Empty;
            String[] users = strAssignedUser.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string user in users)
            {

                ListItem item = taskUsers.Items.FindByText(user.Trim());

                if (item != null)
                {
                    item.Selected = true;

                    if (string.IsNullOrEmpty(firstAssignedUser))
                    {
                        firstAssignedUser = item.Text;
                    }
                }
            }

            if (!String.IsNullOrEmpty(firstAssignedUser))
            {
                //taskUsers.Texts.SelectBoxCaption = firstAssignedUser;
            }

        }

        public void ShowAddNewSubTaskSection(bool IsOnPageLoad)
        {
            ClearSubTaskData();
            string[] subtaskListIDSuggestion = CommonFunction.getSubtaskSequencing(this.LastSubTaskSequence);
            if (subtaskListIDSuggestion.Length > 0)
            {
                if (subtaskListIDSuggestion.Length > 1)
                {
                    if (String.IsNullOrEmpty(subtaskListIDSuggestion[1]))
                    {
                        txtTaskListID.Text = subtaskListIDSuggestion[0];

                    }
                    else
                    {
                        txtTaskListID.Text = subtaskListIDSuggestion[1];
                        listIDOpt.Text = subtaskListIDSuggestion[0];

                    }

                }
                else
                {
                    txtTaskListID.Text = subtaskListIDSuggestion[0];
                    //listIDOpt.Text = subtaskListIDSuggestion[0];
                }
            }

            int numbersequence;
            if (ExtensionMethods.TryRomanParse(txtTaskListID.Text, out numbersequence))
            {
                rfvTitle.Enabled =
                rfvUrl.Enabled = true;
            }
            else
            {
                rfvTitle.Enabled =
                rfvUrl.Enabled = false;
            }

            string strScript = string.Format(
                                                "ShowAddNewSubTaskSection('#{0}');",
                                                divSubTask.ClientID
                                            );

            if (IsOnPageLoad)
            {
                strScript = "$(document).ready(function(){" + strScript + "});";
            }

            ScriptManager.RegisterStartupScript(
                                                    this.Page,
                                                    this.GetType(),
                                                    "ShowSubTaskSection",
                                                    strScript,
                                                    true
                                              );
        }

        private void UploadUserAttachements(int? taskUpdateId, string attachments)
        {
            //User has attached file than save it to database.
            if (!string.IsNullOrEmpty(attachments))
            {
                TaskUser taskUserFiles = new TaskUser();

                string[] files = attachments.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (String attachment in files)
                {
                    String[] attachements = attachment.Split('@');
                    string fileExtension = Path.GetExtension(attachment);


                    if (
                        fileExtension.ToLower() == ".mpeg" ||
                        fileExtension.ToLower() == ".mp4" ||
                        fileExtension.ToLower() == ".3gpp" ||
                        fileExtension.ToLower() == ".wmv" ||
                        fileExtension.ToLower() == ".mkv"
                       )
                    {

                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Video);
                    }
                    else if (
                         fileExtension.ToLower() == ".mp3" ||
                         fileExtension.ToLower() == ".mp4" ||
                         fileExtension.ToLower() == ".wma"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Audio);
                    }
                    else if (
                         fileExtension.ToLower() == ".jpg" ||
                         fileExtension.ToLower() == ".jpeg" ||
                         fileExtension.ToLower() == ".png"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Images);
                    }
                    else if (
                         fileExtension.ToLower() == ".doc" ||
                         fileExtension.ToLower() == ".docx" ||
                         fileExtension.ToLower() == ".xlx" ||
                         fileExtension.ToLower() == ".xlsx" ||
                         fileExtension.ToLower() == ".pdf" ||
                         fileExtension.ToLower() == ".txt" ||
                         fileExtension.ToLower() == ".csv"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Docu);
                    }
                    taskUserFiles.Attachment = attachements[0];
                    taskUserFiles.OriginalFileName = attachements[1];
                    taskUserFiles.Mode = 0; // insert data.
                    taskUserFiles.TaskId = TaskId;
                    taskUserFiles.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    taskUserFiles.TaskUpdateId = taskUpdateId;
                    taskUserFiles.UserType = JGSession.IsInstallUser ?? false;
                    TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                }
            }
        }

        protected string SetFreezeColumnUI(TextBox objTextBox, CheckBox chkAdmin, CheckBox chkITLead, CheckBox chkUser)
        {
            string strPlaceholder = string.Empty;
            if (Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
            {
                strPlaceholder = "Admin Password";
                chkITLead.Enabled =
                chkUser.Enabled = false;
            }
            else if (Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
            {
                strPlaceholder = "IT Lead Password";
                chkAdmin.Enabled =
                chkUser.Enabled = false;
            }
            else
            {
                strPlaceholder = "User Password";
                chkAdmin.Enabled =
                chkITLead.Enabled = false;
            }

            objTextBox.Attributes.Add("placeholder", strPlaceholder);
            return strPlaceholder;
        }

        private DataTable GetSubTasks()
        {
            string strSortExpression = this.SubTaskSortExpression + " " + (this.SubTaskSortDirection == SortDirection.Ascending ? "ASC" : "DESC");

            return TaskGeneratorBLL.Instance.GetSubTasks(TaskId, CommonFunction.CheckAdminAndItLeadMode(), strSortExpression).Tables[0];
        }

        public void SetSubTaskDetails(List<Task> lstSubtasks)
        {
            // TaskId,Title, [Description], [Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager
            DataTable dtSubtasks = new DataTable();
            dtSubtasks.Columns.Add("TaskId");
            dtSubtasks.Columns.Add("Title");
            dtSubtasks.Columns.Add("Description");
            dtSubtasks.Columns.Add("Status");
            dtSubtasks.Columns.Add("DueDate");
            dtSubtasks.Columns.Add("Hours");
            dtSubtasks.Columns.Add("InstallId");
            dtSubtasks.Columns.Add("FristName");
            dtSubtasks.Columns.Add("TaskType");
            dtSubtasks.Columns.Add("attachment");
            dtSubtasks.Columns.Add("TaskPriority");
            dtSubtasks.Columns.Add("AdminStatus");
            dtSubtasks.Columns.Add("TechLeadStatus");
            dtSubtasks.Columns.Add("OtherUserStatus");

            foreach (Task objSubTask in lstSubtasks)
            {
                dtSubtasks.Rows.Add(
                                        objSubTask.TaskId,
                                        objSubTask.Title,
                                        objSubTask.Description,
                                        objSubTask.Status,
                                        objSubTask.DueDate,
                                        objSubTask.Hours,
                                        objSubTask.InstallId,
                                        string.Empty,
                                        objSubTask.TaskType,
                                        objSubTask.Attachment,
                                        objSubTask.TaskPriority,
                                        objSubTask.AdminStatus,
                                        objSubTask.TechLeadStatus,
                                        objSubTask.OtherUserStatus
                                    );
            }

            gvSubTasks.DataSource = dtSubtasks;
            gvSubTasks.DataBind();

            // do not show freezing option while adding new task.
            gvSubTasks.Columns[6].Visible = false;

            upSubTasks.Update();
        }

        public void SetSubTaskDetails()
        {
            DataTable dtSubTaskDetails = GetSubTasks();
            gvSubTasks.DataSource = dtSubTaskDetails;
            gvSubTasks.DataBind();
            upSubTasks.Update();

            if (dtSubTaskDetails.Rows.Count > 0)
            {
                DataView dv = dtSubTaskDetails.AsDataView();
                dv.Sort = "TaskId ASC";
                this.LastSubTaskSequence = dv.ToTable().Rows[dtSubTaskDetails.Rows.Count - 1]["InstallId"].ToString();
            }
            else
            {
                this.LastSubTaskSequence = String.Empty;
            }

            //rptImageGallery.DataSource = this.lstSubTaskFiles;
            //rptImageGallery.DataBind();
            //upImageGallery.Update();
        }

        private void FillInitialData()
        {
            FillDropDrowns();

            if (controlMode == "0")
            {
                gvSubTasks.DataSource = this.lstSubTasks;
                gvSubTasks.DataBind();
            }
        }

        private void FillDropDrowns()
        {
            DataSet ds = DesignationBLL.Instance.GetActiveDesignationByID(0, 1);
            ddlUserDesignation.Items.Clear();
            ddlUserDesignation.DataSource = ds.Tables[0];
            ddlUserDesignation.DataTextField = "DesignationName";
            ddlUserDesignation.DataValueField = "ID";
            ddlUserDesignation.DataBind();
            ddlUserDesignation.Texts.SelectBoxCaption = "Select";

            ddlSubTaskStatus.DataSource = CommonFunction.GetTaskStatusList();
            ddlSubTaskStatus.DataTextField = "Text";
            ddlSubTaskStatus.DataValueField = "Value";
            ddlSubTaskStatus.DataBind();
            //ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;

            ddlSubTaskPriority.DataSource = CommonFunction.GetTaskPriorityList();
            ddlSubTaskPriority.DataTextField = "Text";
            ddlSubTaskPriority.DataValueField = "Value";
            ddlSubTaskPriority.DataBind();

            ddlTaskType.DataSource = CommonFunction.GetTaskTypeList();
            ddlTaskType.DataTextField = "Text";
            ddlTaskType.DataValueField = "Value";
            ddlTaskType.DataBind();
        }

        public void SetSubTaskView()
        {
            divAddSubTask.Visible = this.IsAdminMode;
            upAddSubTask.Update();
        }

        public void SaveSubTasks(Int32 intTaskId)
        {
            if (this.lstSubTasks.Any())
            {
                foreach (Task objSubTask in this.lstSubTasks)
                {
                    objSubTask.ParentTaskId = intTaskId;
                    // save task master details to database.
                    hdnSubTaskId.Value = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objSubTask).ToString();

                    UploadUserAttachements(null, Convert.ToInt64(hdnSubTaskId.Value), objSubTask.Attachment, JGConstant.TaskFileDestination.SubTask);
                }
            }
        }

        private void SaveSubTask()
        {
            Task objTask = null;
            if (hdnSubTaskIndex.Value == "-1")
            {
                objTask = new Task();
                objTask.TaskId = Convert.ToInt32(hdnSubTaskId.Value);
            }
            else
            {
                objTask = this.lstSubTasks[Convert.ToInt32(hdnSubTaskIndex.Value)];
            }

            if (objTask.TaskId > 0)
            {
                objTask.Mode = 1;
            }
            else
            {
                objTask.Mode = 0;
            }

            objTask.Title = txtSubTaskTitle.Text;
            objTask.Url = txtUrl.Text;
            objTask.Description = txtSubTaskDescription.Text;
            objTask.Status = Convert.ToInt32(ddlSubTaskStatus.SelectedValue);
            if (ddlSubTaskPriority.SelectedValue == "0")
            {
                objTask.TaskPriority = null;
            }
            else
            {
                objTask.TaskPriority = Convert.ToByte(ddlSubTaskPriority.SelectedItem.Value);
            }
            objTask.DueDate = txtSubTaskDueDate.Text;
            objTask.Hours = txtSubTaskHours.Text;
            objTask.CreatedBy = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            //task.InstallId = GetInstallIdFromDesignation(ddlUserDesignation.SelectedItem.Text);
            objTask.InstallId = txtTaskListID.Text.Trim();
            objTask.ParentTaskId = TaskId;
            objTask.Attachment = hdnAttachments.Value;

            if (ddlTaskType.SelectedIndex > 0)
            {
                objTask.TaskType = Convert.ToInt16(ddlTaskType.SelectedValue);
            }

            //if (controlMode == "0")
            //{
            //    if (hdnSubTaskIndex.Value == "-1")
            //    {
            //        this.lstSubTasks.Add(objTask);
            //    }
            //    else
            //    {
            //        this.lstSubTasks[Convert.ToInt32(hdnSubTaskIndex.Value)] = objTask;
            //    }

            //    SetSubTaskDetails(this.lstSubTasks);

            //    if (!string.IsNullOrEmpty(txtTaskListID.Text))
            //    {
            //        this.LastSubTaskSequence = txtTaskListID.Text.Trim();
            //    }
            //}
            //else
            {
                // save task master details to database.
                if (hdnSubTaskId.Value == "0")
                {
                    hdnSubTaskId.Value = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask).ToString();
                }
                else
                {
                    TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask);
                }

                // save assgined designation.
                SaveTaskDesignations();

                UploadUserAttachements(null, Convert.ToInt64(hdnSubTaskId.Value), objTask.Attachment, JGConstant.TaskFileDestination.SubTask);

                #region Update Estimated Hours

                TaskApproval objTaskApproval = new TaskApproval();
                if (string.IsNullOrEmpty(hdnTaskApprovalId.Value))
                {
                    objTaskApproval.Id = 0;
                }
                else
                {
                    objTaskApproval.Id = Convert.ToInt64(hdnTaskApprovalId.Value);
                }
                objTaskApproval.EstimatedHours = txtEstimatedHours.Text.Trim();
                objTaskApproval.Description = string.Empty;
                objTaskApproval.TaskId = Convert.ToInt32(hdnSubTaskId.Value);
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

                SetSubTaskDetails();
            }
            hdnAttachments.Value = string.Empty;
            ClearSubTaskData();
        }

        private void SaveTaskDesignations()
        {
            //if task id is available to save its note and attachement.
            if (hdnSubTaskId.Value != "0")
            {
                String designations = GetSelectedDesignationsString();
                if (!string.IsNullOrEmpty(designations))
                {
                    int indexofComma = designations.IndexOf(',');
                    int copyTill = indexofComma > 0 ? indexofComma : designations.Length;

                    //string designationcode = GetInstallIdFromDesignation(designations.Substring(0, copyTill));
                    string designationcode = txtTaskListID.Text.Trim();

                    TaskGeneratorBLL.Instance.SaveTaskDesignations(Convert.ToUInt64(hdnSubTaskId.Value), designations, designationcode);
                }
            }
        }

        public void ClearSubTaskData()
        {
            hdnTaskApprovalId.Value = "0";
            hdnSubTaskId.Value = "0";
            hdnSubTaskIndex.Value = "-1";
            txtTaskListID.Text = string.Empty;
            txtSubTaskTitle.Text =
            txtUrl.Text =
            txtSubTaskDescription.Text =
            txtEstimatedHours.Text =
            txtSubTaskDueDate.Text =
            txtSubTaskHours.Text = string.Empty;
            ddlUserDesignation.ClearSelection();
            ddlUserDesignation.Texts.SelectBoxCaption = "Select";
            if (ddlTaskType.Items.Count > 0)
            {
                ddlTaskType.SelectedIndex = 0;
            }
            trSubTaskStatus.Visible = false;
            if (ddlSubTaskStatus.Items.Count > 0)
            {
                ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.Open).ToString()).Selected = true;
                ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()).Enabled = true;
            }
            ddlSubTaskPriority.SelectedValue = "0";
            btnSaveSubTaskAttachment.Visible = false;
            rptSubTaskAttachments.DataSource = null;
            rptSubTaskAttachments.DataBind();
            upAddSubTask.Update();
        }

        private void DownloadUserAttachment(String File, String OriginalFileName)
        {
            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition", String.Concat("attachment; filename=", OriginalFileName));
            Response.WriteFile(Server.MapPath("~/TaskAttachments/" + File));
            Response.Flush();
            Response.End();
        }

        private void SetStatusSelectedValue(DropDownList ddlStatus, string strValue)
        {
            ddlStatus.ClearSelection();

            ListItem objListItem = ddlStatus.Items.FindByValue(strValue);
            if (objListItem != null)
            {
                //if (objListItem.Value == Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString())
                //{
                //    ddlStatus.Enabled = false;
                //}
                //else
                //{
                //    ddlStatus.Enabled = true;
                //}
                objListItem.Enabled = true;
                objListItem.Selected = true;
            }
        }

        private void FillSubtaskAttachments(int SubTaskId)
        {
            DataTable dtSubtaskAttachments = null;

            if (SubTaskId > 0)
            {
                DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskUserFiles(SubTaskId, JGConstant.TaskFileDestination.SubTask, null, null);
                if (dsTaskUserFiles != null)
                {
                    dtSubtaskAttachments = dsTaskUserFiles.Tables[0];
                    //Convert.ToInt32(dsTaskUserFiles.Tables[1].Rows[0]["TotalRecordCount"]);
                }
            }

            rptSubTaskAttachments.DataSource = dtSubtaskAttachments;
            rptSubTaskAttachments.DataBind();

            upnlAttachments.Update();
        }

        private void UploadUserAttachements(int? taskUpdateId, long TaskId, string attachments, JG_Prospect.Common.JGConstant.TaskFileDestination objTaskFileDestination)
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
                        taskUserFiles.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        taskUserFiles.TaskUpdateId = taskUpdateId;
                        taskUserFiles.UserType = JGSession.IsInstallUser ?? false;
                        taskUserFiles.TaskFileDestination = objTaskFileDestination;
                        TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                    }
                }
            }
        }

        private void DeleteWorkSpecificationFile(string parameter)
        {
            // Seperate DB Id and Filename from parameter.
            string[] parameters = parameter.Split('|');

            if (parameter.Length > 0)
            {
                string id = parameters[0];
                string[] fileNames = parameters[1].Split('@');//Id

                TaskUser taskUserFiles = new TaskUser();

                //Remove file from database
                bool blnFileDeletedFromDb = TaskGeneratorBLL.Instance.DeleteTaskUserFile(Convert.ToInt64(id));  // save task files

                //if file removed from database, remove from server file system.
                if (fileNames.Length > 0 && blnFileDeletedFromDb)
                {
                    string filetodelete = fileNames[0];
                    DeletefilefromServer(filetodelete);
                }

            }

        }

        private void DeletefilefromServer(string filetodelete)
        {
            if (!String.IsNullOrEmpty(filetodelete))
            {
                var originalDirectory = new DirectoryInfo(Server.MapPath("~/TaskAttachments"));


                string pathString = System.IO.Path.Combine(originalDirectory.ToString(), filetodelete);

                bool isExists = System.IO.File.Exists(pathString);

                if (isExists)
                    File.Delete(pathString);


            }


        }

        /// <summary>
        /// Save task note and attachment added by user.
        /// </summary>
        private void SaveTaskNotesNAttachments()
        {
            //if task id is available to save its note and attachement.
            if (TaskId > 0)
            {
                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.\
                Int32 TaskUpdateId = SaveTaskNote(TaskId, null, null, string.Empty, string.Empty);

                txtSubtaskComment.Text = string.Empty;
            }
        }

        /// <summary>
        /// Save task user information.
        /// </summary>
        /// <param name="Designame"></param>
        /// <param name="ItaskId"></param>
        public Int32 SaveTaskNote(long ItaskId, Boolean? IsCreated, Int32? UserId, String UserName, String taskDescription)
        {
            Int32 TaskUpdateId = 0;

            TaskUser taskUser = new TaskUser();

            if (UserId == null)
            {
                // Take logged in user's id for logging note in database.
                taskUser.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                taskUser.UserFirstName = Session["Username"].ToString();
            }
            else
            {
                taskUser.UserId = Convert.ToInt32(UserId);
                taskUser.UserFirstName = UserName;
            }


            taskUser.Id = 0;

            if (string.IsNullOrEmpty(taskDescription))
            {
                taskUser.Notes = txtSubtaskComment.Text;
            }
            else
            {
                taskUser.Notes = taskDescription;
            }

            if (!string.IsNullOrEmpty(taskUser.Notes))
            {
                taskUser.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Notes);
            }

            // if user has just created task then send entry with iscreator= true to distinguish record from other user's log.
            if (IsCreated != null)
            {
                taskUser.IsCreatorUser = true;
            }
            else
            {
                taskUser.IsCreatorUser = false;
            }

            taskUser.TaskId = ItaskId;

            taskUser.Status = Convert.ToInt16(TaskStatus);

            taskUser.UserAcceptance = UserAcceptance;

            taskUser.TaskFileDestination = JGConstant.TaskFileDestination.SubTask;

            if (taskUser.Id == 0)
            {
                TaskGeneratorBLL.Instance.SaveOrDeleteTaskNotes(ref taskUser);
                TaskUpdateId = Convert.ToInt32(taskUser.TaskUpdateId);
            }
            else
            {
                TaskGeneratorBLL.Instance.UpadateTaskNotes(ref taskUser);
            }


            return TaskUpdateId;
        }

        public void DisableSubTaskAssignment(bool blEnabled)
        {
            for (int i = 0; i < gvSubTasks.Rows.Count; i++)
            {
                ListBox ddcbAssigned = gvSubTasks.Rows[i].FindControl("ddcbAssigned") as ListBox;
                
                ddcbAssigned.AutoPostBack = 
                ddcbAssigned.Enabled = blEnabled;
            }
            upSubTasks.Update();
        }

        #endregion
    }
}