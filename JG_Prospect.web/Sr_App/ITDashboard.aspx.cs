using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Configuration;
using System.Web;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Net.Mail;
using JG_Prospect.Common.Logger;
using JG_Prospect.Common;

using JG_Prospect.App_Code;
using System.Collections;
using JG_Prospect.DAL.Database;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System.Data.SqlClient;
using System.Data;
using System.Data.Common;
using JG_Prospect.DAL.Database;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System.Web.UI.HtmlControls;

namespace JG_Prospect.Sr_App
{
    public partial class ITDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            JG_Prospect.App_Code.CommonFunction.AuthenticateUser();

            if (!Page.IsPostBack)
            {
                //Session["AppType"] = "SrApp";
                //if ((string)Session["usertype"] == "SM" || (string)Session["usertype"] == "SSE" || (string)Session["usertype"] == "MM")
                //{
                //    li_AnnualCalender.Visible = true;
                //}
                //if ((string)Session["usertype"] == "Admin")
                //{
                //    pnlTestEmail.Visible = true;
                //}

                //----------------- Start DP ------------
                FillDesignation();
                lblFrozenCounter0.Visible = false;
                lblNewCounter0.Visible = false;

                if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
                {
                    tblInProgress.Visible = true;
                    tblClosedTask.Visible = true;
                    lblalertpopup.Visible = true;

                    txtSearchFrozen.Visible = true;
                    btnSearchFrozen.Visible = true;

                    txtSearchClosed.Visible = true;
                    btnSearchClosed.Visible = true;

                    txtSearchInPro.Visible = true;
                    btnSearchInPro.Visible = true;

                }
                else
                {
                    tblInProgress.Visible = false;
                    tblClosedTask.Visible = false;
                    lblalertpopup.Visible = false;

                    txtSearchFrozen.Visible = false;
                    btnSearchFrozen.Visible = false;

                    txtSearchClosed.Visible = false;
                    btnSearchClosed.Visible = false;

                    txtSearchInPro.Visible = false;
                    btnSearchInPro.Visible = false;

                }
                LoadFilterUsersByDesgination("", ddlInProgressAssignedUsers);
                LoadFilterUsersByDesgination("", ddlClosedAssignedUsers);
                LoadFilterUsersByDesgination("", ddlUserFrozen);
                //LoadFilterUsersByDesginationFrozen("", drpUserFrozen);
                //LoadFilterUsersByDesgination("", drpUserNew);
                BindTaskInProgressGrid();
                BindTaskClosedGrid();
                BindFrozenTasks();
                BindNewTasks();

                // ----- get NEW and FROZEN task counts for current payperiod
                DateTime firstOfThisMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                DateTime firstOfNextMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(1);
                DateTime lastOfThisMonth = firstOfNextMonth.AddDays(-1);
                //DateTime MiddleDate = Convert.ToDateTime("15-" + DateTime.Now.Month + "-" + DateTime.Now.Year);
                DateTime MiddleDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddDays(14);
                string strnew = "";
                //try
                //{
                //    SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                //    {
                //        DataSet result = new DataSet();
                //        //if (DateTime.Now.Date >= firstOfThisMonth && DateTime.Now.Date <= MiddleDate)
                //        //{
                //        //    strnew = "select count(TaskId) as cntnew from tbltask where [Status]=1 ";
                //        //    strnew = strnew + " and (CreatedOn >='" + firstOfThisMonth.ToString("dd-MMM-yyy") + "' and CreatedOn <= '" + MiddleDate.ToString("dd-MMM-yyy") + "') ";
                //        //}
                //        //else if (DateTime.Now.Date >= MiddleDate && DateTime.Now.Date <= lastOfThisMonth)
                //        //{
                //        //    strnew = "select count(TaskId) as cntnew from tbltask where [Status]=1 ";
                //        //    strnew = strnew + " and (CreatedOn >='" + MiddleDate.ToString("dd-MMM-yyy") + "' and CreatedOn <= '" + lastOfThisMonth.ToString("dd-MMM-yyy") + "') ";
                //        //}

                //        strnew = "select count(TaskId) as cntnew from tbltask where [Status]=1 ";

                //        DbCommand command = database.GetSqlStringCommand(strnew);
                //        command.CommandType = CommandType.Text;
                //        result = database.ExecuteDataSet(command);
                //        lblNewCounter.Visible = false;
                //        lblNewCounter0.Visible = true;
                //        lblNewCounter0.Text = " Non Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>0</div>";
                //        if (result.Tables[0].Rows.Count > 0)
                //        {
                //            if (result.Tables[0].Rows[0]["cntnew"].ToString() != "0")
                //            {
                //                lblNewCounter.Visible = true;
                //                lblNewCounter0.Visible = false;
                //                lblNewCounter.Text = " Non Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>" + result.Tables[0].Rows[0]["cntnew"].ToString() + "</div>";
                //            }
                //        }
                //        result.Dispose();
                //    }
                //}
                //catch (Exception ex)
                //{
                //}

                //string strfrozen = "";
                //try
                //{
                //    SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                //    {
                //        DataSet result = new DataSet();

                //        //if (DateTime.Now.Date >= firstOfThisMonth && DateTime.Now.Date <= MiddleDate)
                //        //{
                //        //    strfrozen = "select count(a.TaskId) as cntnew from tbltask as a,tbltaskapprovals as b where a.TaskId=b.TaskId  ";
                //        //    strfrozen = strfrozen + " and  (DateCreated >='" + firstOfThisMonth.ToString("dd-MMM-yyy") + "' and DateCreated <= '" + MiddleDate.ToString("dd-MMM-yyy") + "') ";
                //        //}
                //        //else if (DateTime.Now.Date >= MiddleDate && DateTime.Now.Date <= lastOfThisMonth)
                //        //{
                //        //    strfrozen = "select count(a.TaskId) as cntnew from tbltask as a,tbltaskapprovals as b where a.TaskId=b.TaskId  ";
                //        //    strfrozen = strfrozen + " and  (DateCreated >='" + MiddleDate.ToString("dd-MMM-yyy") + "' and DateCreated <= '" + lastOfThisMonth.ToString("dd-MMM-yyy") + "') ";
                //        //}

                //        strfrozen = "select count(a.TaskId) as cntnew from tbltask as a,tbltaskapprovals as b where a.TaskId=b.TaskId  ";

                //        DbCommand command = database.GetSqlStringCommand(strfrozen);
                //        command.CommandType = CommandType.Text;
                //        result = database.ExecuteDataSet(command);

                //        lblFrozenCounter.Visible = false;
                //        lblFrozenCounter0.Visible = true;
                //        lblFrozenCounter0.Text = "Partial Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>0</div>";
                //        if (result.Tables[0].Rows.Count > 0)
                //        {
                //            if (result.Tables[0].Rows[0]["cntnew"].ToString() != "0")
                //            {
                //                lblFrozenCounter.Visible = true;
                //                lblFrozenCounter0.Visible = false;
                //                lblFrozenCounter.Text = "Partial Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>" + result.Tables[0].Rows[0]["cntnew"].ToString() + "</div>";
                //            }
                //        }
                //        result.Dispose();
                //    }
                //}
                //catch (Exception ex)
                //{
                //}
                //Non Frozen Count
                lblNewCounter.Visible = false;
                lblNewCounter0.Visible = true;
                lblNewCounter0.Text = " Non Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>0</div>";
                if (grdNewTask != null)
                {
                    if (grdNewTask.DataSource != null)
                    {
                        lblNewCounter.Visible = true;
                        lblNewCounter0.Visible = false;
                        lblNewCounter.InnerHtml = " Non Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>" + grdNewTask.VirtualItemCount + "</div>";
                    }
                }

                //Partial Frozen Count
                lblFrozenCounter.Visible = false;
                lblFrozenCounter0.Visible = true;
                lblFrozenCounter0.Text = "Partial Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>0</div>";
                if (grdFrozenTask != null)
                {
                    if (grdFrozenTask.DataSource != null)
                    {
                        lblFrozenCounter.Visible = true;
                        lblFrozenCounter0.Visible = false;
                        lblFrozenCounter.InnerHtml = "Partial Frozen Tasks :<div class='badge1 badge-error' style='width:20px;'>" + grdFrozenTask.VirtualItemCount + "</div>";
                    }
                }

                //----------------- End DP ------------
            }
            lblMessage.Text = "";
        }



        protected void grdTaskPending_PreRender(object sender, EventArgs e)
        {
            GridView gv = (GridView)sender;

            if (gv.Rows.Count > 0)
            {
                gv.UseAccessibleHeader = true;
                gv.HeaderRow.TableSection = TableRowSection.TableHeader;
                gv.FooterRow.TableSection = TableRowSection.TableFooter;
            }

            if (gv.TopPagerRow != null)
            {
                gv.TopPagerRow.TableSection = TableRowSection.TableHeader;
            }
            if (gv.BottomPagerRow != null)
            {
                gv.BottomPagerRow.TableSection = TableRowSection.TableFooter;
            }
        }
        protected void grdTaskClosed_PreRender(object sender, EventArgs e)
        {
            GridView gv = (GridView)sender;

            if (gv.Rows.Count > 0)
            {
                gv.UseAccessibleHeader = true;
                gv.HeaderRow.TableSection = TableRowSection.TableHeader;
                gv.FooterRow.TableSection = TableRowSection.TableFooter;
            }

            if (gv.TopPagerRow != null)
            {
                gv.TopPagerRow.TableSection = TableRowSection.TableHeader;
            }
            if (gv.BottomPagerRow != null)
            {
                gv.BottomPagerRow.TableSection = TableRowSection.TableFooter;
            }
        }

        protected void grdFrozenTask_PreRender(object sender, EventArgs e)
        {
            GridView gv = (GridView)sender;

            if (gv.Rows.Count > 0)
            {
                gv.UseAccessibleHeader = true;
                gv.HeaderRow.TableSection = TableRowSection.TableHeader;
                gv.FooterRow.TableSection = TableRowSection.TableFooter;
            }

            if (gv.TopPagerRow != null)
            {
                gv.TopPagerRow.TableSection = TableRowSection.TableHeader;
            }
            if (gv.BottomPagerRow != null)
            {
                gv.BottomPagerRow.TableSection = TableRowSection.TableFooter;
            }
        }

        protected void grdNewTask_PreRender(object sender, EventArgs e)
        {
            GridView gv = (GridView)sender;

            if (gv.Rows.Count > 0)
            {
                gv.UseAccessibleHeader = true;
                gv.HeaderRow.TableSection = TableRowSection.TableHeader;
                gv.FooterRow.TableSection = TableRowSection.TableFooter;
            }

            if (gv.TopPagerRow != null)
            {
                gv.TopPagerRow.TableSection = TableRowSection.TableHeader;
            }
            if (gv.BottomPagerRow != null)
            {
                gv.BottomPagerRow.TableSection = TableRowSection.TableFooter;
            }
        }

        protected void lnkNewCounter_Click(object sender, EventArgs e)
        {
            txtSearchFrozen.Text = "";
            //mpNewFrozenTask.Show();
        }

        protected void lnkFrozenCounter_Click(object sender, EventArgs e)
        {
            txtSearchFrozen.Text = "";
           // mpNewFrozenTask.Show();
        }

        protected void btnCalClose_Click(object sender, EventArgs e)
        {
            //mpNewFrozenTask.Hide();
            //ScriptManager.RegisterStartupScript(this.Page, GetType(), "al1", "$('#lnkNNewCounter').click(function () {callpopupscript();   });", true);

        }
        //protected void drpDesigInProgress_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    string designation = drpDesigInProgress.SelectedValue;
        //    LoadFilterUsersByDesgination(designation, drpUsersInProgress);
        //    //SearchTasks(null);
        //    BindTaskInProgressGrid();
        //}


        //protected void drpDesigNew_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    string designation = drpDesigNew.SelectedValue;
        //    LoadFilterUsersByDesgination(designation, drpUserNew);
        //    BindNewTasks();
        //}

        protected void drpDesigFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            //string designation = drpDesigFrozen.SelectedValue;
            //LoadFilterUsersByDesginationFrozen(designation, drpUserFrozen);
            //BindFrozenTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }
        //protected void drpDesigClosed_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    string designation = drpDesigClosed.SelectedValue;
        //    LoadFilterUsersByDesgination(designation, drpUsersClosed);
        //    //SearchTasks(null);
        //    BindTaskClosedGrid();
        //}
        protected void drpUsersInProgress_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindTaskInProgressGrid();
        }

        protected void drpUsersClosed_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindTaskClosedGrid();
        }
        protected void drpUserFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindFrozenTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }
        //protected void drpDesigFrozen_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    string designation = drpDesigInProgress.SelectedValue;
        //    LoadFilterUsersByDesgination(designation, drpUserFrozen);
        //    BindFrozenTasks();
        //}
        //protected void drpDesigNew_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    string designation = drpDesigInProgress.SelectedValue;
        //    LoadFilterUsersByDesgination(designation,drpUserNew );
        //    BindNewTasks();
        //}
        protected void drpUserNew_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindNewTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }

        private void LoadFilterUsersByDesgination(string designation, ListBox drp)
        {
            DataSet dsUsers;
            // DropDownCheckBoxes ddlAssign = (FindControl("ddcbAssigned") as DropDownCheckBoxes);
            // DropDownList ddlDesignation = (DropDownList)sender;
            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designation);
            //drpUsersInProgress.Items.Clear();

            drp.Items.Clear();
            drp.DataSource = dsUsers;
            drp.DataTextField = "FristName";
            drp.DataValueField = "Id";
            drp.DataBind();
            drp.Items.Insert(0, new ListItem("--All--", "0"));
            drp.SelectedIndex = 0;

            HighlightInterviewUsers(dsUsers.Tables[0], drp, null);
        }

        private void LoadFilterUsersByDesgination(string designation, Saplin.Controls.DropDownCheckBoxes drp)
        {
            DataSet dsUsers;
            // DropDownCheckBoxes ddlAssign = (FindControl("ddcbAssigned") as DropDownCheckBoxes);
            // DropDownList ddlDesignation = (DropDownList)sender;
            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designation);
            //drpUsersInProgress.Items.Clear();

            drp.Items.Clear();
            drp.DataSource = dsUsers;
            drp.DataTextField = "FristName";
            drp.DataValueField = "Id";
            drp.DataBind();
            drp.Items.Insert(0, new ListItem("--All--", "0"));
            drp.SelectedIndex = 0;
            HighlightInterviewUsers(dsUsers.Tables[0], drp, null);
        }

        private void HighlightInterviewUsers(DataTable dtUsers, Saplin.Controls.DropDownCheckBoxes ddlUsers, DropDownList ddlFilterUsers)
        {
            #region Commented
            //if (dtUsers.Rows.Count > 0)
            //{
            //    var rows = dtUsers.AsEnumerable();

            //    //get all users comma seperated ids with interviewdate status
            //    String InterviewDateUsers = String.Join(",", (from r in rows where (r.Field<string>("Status") == "InterviewDate" || r.Field<string>("Status") == "Interview Date") select r.Field<Int32>("Id").ToString()));

            //    // for each userid find it into user dropdown list and apply red color to it.
            //    foreach (String user in InterviewDateUsers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            //    {
            //        ListItem item;

            //        if (ddlUsers != null)
            //        {
            //            item = ddlUsers.Items.FindByValue(user);
            //        }
            //        else
            //        {
            //            item = ddlFilterUsers.Items.FindByValue(user);
            //        }

            //        if (item != null)
            //        {
            //            item.Attributes.Add("style", "color:red;");
            //        }
            //    }

            //} 
            #endregion
            HyperLink lnkUserId = new HyperLink();
            ListItem lstUserId = new ListItem();

            if (dtUsers.Rows.Count > 0)
            {
                var rows = dtUsers.AsEnumerable();

                //get all users comma seperated ids with Active status
                String InterviewDateUsers = String.Join(",", (from r in rows where (r.Field<string>("Status") == "1") select r.Field<Int32>("Id").ToString()));

                // for each userid find it into user dropdown list and apply red color to it.
                foreach (String user in InterviewDateUsers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    ListItem item;

                    if (ddlUsers != null)
                    {
                        item = ddlUsers.Items.FindByValue(user);
                    }
                    else
                    {
                        item = ddlFilterUsers.Items.FindByValue(user);
                    }

                    if (item != null)
                    {
                        item.Attributes.Add("style", "color:red;");

                    }
                }

                InterviewDateUsers = string.Empty;

                //get all users comma seperated ids with interviewdate and Offer Made status
                InterviewDateUsers = String.Join(",", (from r in rows where (r.Field<string>("Status") == "5" || r.Field<string>("Status") == "6") select r.Field<Int32>("Id").ToString()));

                // for each userid find it into user dropdown list and apply blue color to it.
                foreach (String user in InterviewDateUsers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    ListItem item;

                    if (ddlUsers != null)
                    {
                        item = ddlUsers.Items.FindByValue(user);
                    }
                    else
                    {
                        item = ddlFilterUsers.Items.FindByValue(user);
                    }

                    if (item != null)
                    {
                        item.Attributes.Add("style", "color:blue;");
                    }
                }
            }
        }

        private void HighlightInterviewUsers(DataTable dtUsers, ListBox ddlUsers, DropDownList ddlFilterUsers)
        {
            #region Commented
            //if (dtUsers.Rows.Count > 0)
            //{
            //    var rows = dtUsers.AsEnumerable();

            //    //get all users comma seperated ids with interviewdate status
            //    String InterviewDateUsers = String.Join(",", (from r in rows where (r.Field<string>("Status") == "InterviewDate" || r.Field<string>("Status") == "Interview Date") select r.Field<Int32>("Id").ToString()));

            //    // for each userid find it into user dropdown list and apply red color to it.
            //    foreach (String user in InterviewDateUsers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            //    {
            //        ListItem item;

            //        if (ddlUsers != null)
            //        {
            //            item = ddlUsers.Items.FindByValue(user);
            //        }
            //        else
            //        {
            //            item = ddlFilterUsers.Items.FindByValue(user);
            //        }

            //        if (item != null)
            //        {
            //            item.Attributes.Add("style", "color:red;");
            //        }
            //    }

            //} 
            #endregion

            if (dtUsers != null && dtUsers.Rows.Count > 0)
            {
                CommonFunction.ApplyColorCodeToAssignUserDropdown(dtUsers, ddlUsers);
            }
        }

        private void LoadFilterUsersByDesginationFrozen(string designation, DropDownList drp)
        {
            DataSet dsUsers;
            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designation);

            drp.DataSource = dsUsers;
            drp.DataTextField = "FristName";
            drp.DataValueField = "Id";
            drp.DataBind();
            drp.Items.Insert(0, new ListItem("--All--", "0"));
            drp.SelectedIndex = 0;
        }

        private void FillDesignation()
        {
            DataSet dsDesignation = DesignationBLL.Instance.GetActiveDesignationByID(0, 1);
            //drpDesigInProgress .Items.Clear();

            //drpDesigInProgress.DataValueField = "Id";
            //drpDesigInProgress.DataTextField = "DesignationName";
            //drpDesigInProgress.DataSource = dsDesignation.Tables[0];
            //drpDesigInProgress.DataBind();
            //drpDesigInProgress.Items.Insert(0, new ListItem("--All--", "0"));
            //drpDesigInProgress.SelectedIndex = 0;

            //DataSet ds = DesignationBLL.Instance.GetActiveDesignationByID(0, 1);
            ddlInprogressUserDesignation.Items.Clear();
            ddlInprogressUserDesignation.DataSource = dsDesignation.Tables[0];
            ddlInprogressUserDesignation.DataTextField = "DesignationName";
            ddlInprogressUserDesignation.DataValueField = "ID";
            ddlInprogressUserDesignation.DataBind();

            ddlClosedUserDesignation.Items.Clear();
            ddlClosedUserDesignation.DataSource = dsDesignation.Tables[0];
            ddlClosedUserDesignation.DataTextField = "DesignationName";
            ddlClosedUserDesignation.DataValueField = "ID";
            ddlClosedUserDesignation.DataBind();
            
            ddlDesigFrozen.Items.Clear();
            ddlDesigFrozen.DataSource = dsDesignation.Tables[0];
            ddlDesigFrozen.DataTextField = "DesignationName";
            ddlDesigFrozen.DataValueField = "ID";
            ddlDesigFrozen.DataBind();

            //drpDesigClosed.DataValueField = "Id";
            //drpDesigClosed.DataTextField = "DesignationName";
            //drpDesigClosed.DataSource = dsDesignation.Tables[0];
            //drpDesigClosed.DataBind();
            //drpDesigClosed.Items.Insert(0, new ListItem("--All--", "0"));
            //drpDesigClosed.SelectedIndex = 0;

            //drpDesigFrozen.DataValueField = "Id";
            //drpDesigFrozen.DataTextField = "DesignationName";
            //drpDesigFrozen.DataSource = dsDesignation.Tables[0];
            //drpDesigFrozen.DataBind();
            //drpDesigFrozen.Items.Insert(0, new ListItem("--All--", "0"));
            //drpDesigFrozen.SelectedIndex = 0;

            //ddlFrozenUserDesignation.Items.Clear();
            //ddlFrozenUserDesignation.DataSource = dsDesignation.Tables[0];
            //ddlFrozenUserDesignation.DataTextField = "DesignationName";
            //ddlFrozenUserDesignation.DataValueField = "ID";
            //ddlFrozenUserDesignation.DataBind();

            //drpDesigNew.DataValueField = "Id";
            //drpDesigNew.DataTextField = "DesignationName";
            //drpDesigNew.DataSource = dsDesignation.Tables[0];
            //drpDesigNew.DataBind();
            //drpDesigNew.Items.Insert(0, new ListItem("--All--", "0"));
            //drpDesigNew.SelectedIndex = 0;
        }

        private void BindNewTasks()
        {
            DateTime firstOfThisMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime firstOfNextMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(1);
            DateTime lastOfThisMonth = firstOfNextMonth.AddDays(-1);
            //DateTime MiddleDate = Convert.ToDateTime("15-" + DateTime.Now.Month + "-" + DateTime.Now.Year);
            DateTime MiddleDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddDays(14);
            string strnew = "";
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DataSet result = new DataSet();
                    string vStartDate = "";
                    string vEndDate = "";

                    if (DateTime.Now.Date >= firstOfThisMonth && DateTime.Now.Date <= MiddleDate)
                    {
                        vStartDate = firstOfThisMonth.ToString("dd-MMM-yyy");
                        vEndDate = MiddleDate.ToString("dd-MMM-yyy");
                    }
                    else if (DateTime.Now.Date >= MiddleDate && DateTime.Now.Date <= lastOfThisMonth)
                    {
                        vStartDate = MiddleDate.ToString("dd-MMM-yyy");
                        vEndDate = lastOfThisMonth.ToString("dd-MMM-yyy");
                    }
                    DbCommand command = database.GetStoredProcCommand("GetNonFrozenTasks");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@startdate", DbType.String, vStartDate);
                    database.AddInParameter(command, "@enddate", DbType.String, vEndDate);
                    database.AddInParameter(command, "@PageIndex", DbType.Int32, grdNewTask.PageIndex);
                    database.AddInParameter(command, "@PageSize", DbType.Int32, grdNewTask.PageSize);

                    result = database.ExecuteDataSet(command);
                    /*
                     if (DateTime.Now.Date >= firstOfThisMonth && DateTime.Now.Date <= MiddleDate)
                    {
                        strnew = "select * from tbltask where [Status]=1 and (CreatedOn >='" + firstOfThisMonth.ToString("dd-MMM-yyy") + "' ";
                        strnew = strnew + " and CreatedOn <= '" + MiddleDate.ToString("dd-MMM-yyy") + "') ";
                    }
                    else if (DateTime.Now.Date >= MiddleDate && DateTime.Now.Date <= lastOfThisMonth)
                    {
                        strnew = "select * from tbltask where [Status]=1 and (CreatedOn >='" + MiddleDate.ToString("dd-MMM-yyy") + "' ";
                        strnew = strnew + " and CreatedOn <= '" + lastOfThisMonth.ToString("dd-MMM-yyy") + "') ";
                    }
                    DbCommand command = database.GetSqlStringCommand(strnew);
                    command.CommandType = CommandType.Text;
                    result = database.ExecuteDataSet(command);
                     
                     */

                    // if loggedin user is not manager then show tasks assigned to loggedin user only 

                    if (result.Tables[0].Rows.Count > 0)
                    {
                        grdNewTask.DataSource = result;
                        grdNewTask.VirtualItemCount = Convert.ToInt32(result.Tables[1].Rows[0]["TotalRecords"]);
                        grdNewTask.DataBind();
                    }
                    else
                    {
                        //lblMessage.Text = "No In-Progress Tasks Found !!!";
                        grdNewTask.DataSource = null;
                        grdNewTask.DataBind();
                    }

                    result.Dispose();
                }
            }
            catch (Exception ex)
            {
            }


        }
        private void BindFrozenTasks()
        {
            DateTime firstOfThisMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime firstOfNextMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(1);
            DateTime lastOfThisMonth = firstOfNextMonth.AddDays(-1);
            //DateTime MiddleDate = Convert.ToDateTime("15-" + DateTime.Now.Month + "-" + DateTime.Now.Year);
            DateTime MiddleDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddDays(14);
            string strfrozen = "";
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DataSet result = new DataSet();

                    //DataSet resultTask = new DataSet();
                    string userId = "0";
                    string desigID = "";
                    string strSearch = "";
                    if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
                    {
                        userId = GetSelectedDesignationsString(ddlUserFrozen);

                        //if (Convert.ToInt32(drpUserFrozen.SelectedValue) > 0)
                        //{
                        //    userId = Convert.ToInt32(drpUserFrozen.SelectedValue);
                        //}
                    }
                    else
                    {
                        userId = Convert.ToString(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    }

                    //if (Convert.ToInt32(drpDesigFrozen.SelectedValue) > 0)
                    //{
                    //    desigID = Convert.ToInt32(drpDesigFrozen.SelectedValue);
                    //}

                    if (string.IsNullOrEmpty(userId))
                        userId = "0";

                    desigID = GetSelectedDesignationsString(ddlDesigFrozen);

                    string vSearch = "";
                    string vStartDate = "";
                    string vEndDate = "";

                    if (txtSearchFrozen.Text != "")
                    {
                        vSearch = txtSearchFrozen.Text;
                    }

                    if (DateTime.Now.Date >= firstOfThisMonth && DateTime.Now.Date <= MiddleDate)
                    {
                        vStartDate = firstOfThisMonth.ToString("dd-MMM-yyy");
                        vEndDate = MiddleDate.ToString("dd-MMM-yyy");
                    }
                    else if (DateTime.Now.Date >= MiddleDate && DateTime.Now.Date <= lastOfThisMonth)
                    {
                        vStartDate = MiddleDate.ToString("dd-MMM-yyy");
                        vEndDate = lastOfThisMonth.ToString("dd-MMM-yyy");
                    }

                    DbCommand command = database.GetStoredProcCommand("GetFrozenTasks");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@search", DbType.String, vSearch);
                    database.AddInParameter(command, "@startdate", DbType.String, vStartDate);
                    database.AddInParameter(command, "@enddate", DbType.String, vEndDate);
                    database.AddInParameter(command, "@PageIndex", DbType.Int32, grdFrozenTask.PageIndex);
                    database.AddInParameter(command, "@PageSize", DbType.Int32, grdFrozenTask.PageSize);
                    database.AddInParameter(command, "@userid", DbType.String, userId);
                    database.AddInParameter(command, "@desigid", DbType.String, desigID);


                    result = database.ExecuteDataSet(command);
                    if (result.Tables[0].Rows.Count > 0)
                    {
                        grdFrozenTask.DataSource = result;
                        grdFrozenTask.VirtualItemCount = Convert.ToInt32(result.Tables[1].Rows[0]["TotalRecords"]);
                        grdFrozenTask.DataBind();
                    }
                    else
                    {
                        //lblMessage.Text = "No In-Progress Tasks Found !!!";
                        grdFrozenTask.DataSource = null;
                        grdFrozenTask.DataBind();
                    }

                    result.Dispose();
                }
            }
            catch (Exception ex)
            {
            }


        }
        private void BindTaskInProgressGrid()
        {
            DataSet ds = new DataSet();

            string userId = "0";
            string desigID = "";
            string strSearch = "";
            if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
            {
                userId = GetSelectedDesignationsString(ddlInProgressAssignedUsers);
                if (txtSearchInPro.Text != "")
                {
                    strSearch = txtSearchInPro.Text;
                }
                //else if (Convert.ToInt32(drpUsersInProgress.SelectedValue) > 0)
                //{
                //    userId = Convert.ToInt32(drpUsersInProgress.SelectedValue);
                //}
            }
            else
            {
                //userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                userId = Convert.ToString(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            }

            //if (Convert.ToInt32(drpDesigInProgress.SelectedValue) > 0)
            //{
            //    desigID = Convert.ToInt32(drpDesigInProgress.SelectedValue);
            //}

            desigID = GetSelectedDesignationsString(ddlInprogressUserDesignation);

            // if loggedin user is not manager then show tasks assigned to loggedin user only 
            ds = TaskGeneratorBLL.Instance.GetInProgressTasks(userId, desigID, strSearch, grdTaskPending.PageIndex, grdTaskPending.PageSize);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                grdTaskPending.DataSource = ds;
                grdTaskPending.VirtualItemCount = Convert.ToInt32(ds.Tables[1].Rows[0]["TotalRecords"]);
                grdTaskPending.DataBind();
            }
            else
            {
                //lblMessage.Text = "No In-Progress Tasks Found !!!";
                grdTaskPending.DataSource = null;
                grdTaskPending.DataBind();

            }

            DataSet dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, desigID);

            if (dsUsers != null && dsUsers.Tables.Count > 0)
            {
                HighlightInterviewUsers(dsUsers.Tables[0], ddlInProgressAssignedUsers, null); 
            }

        }

        private void BindTaskClosedGrid()
        {
            DataSet ds = new DataSet();

            string userId = "0";
            string desigID = "";
            string strSearch = "";
            if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
            {
                userId = GetSelectedDesignationsString(ddlClosedAssignedUsers);
                if (txtSearchInPro.Text != "")
                {
                    strSearch = txtSearchInPro.Text;
                }
                //else if (Convert.ToInt32(drpUsersClosed.SelectedValue) > 0)
                //{
                //    userId = Convert.ToInt32(drpUsersClosed.SelectedValue);
                //}
            }
            else
            {
                //userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                userId = Convert.ToString(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            }

            //if (Convert.ToInt32(drpDesigClosed.SelectedValue) > 0)
            //{
            //    desigID = Convert.ToInt32(drpDesigClosed.SelectedValue);
            //}

            desigID = GetSelectedDesignationsString(ddlClosedUserDesignation);

            // if loggedin user is not manager then show tasks assigned to loggedin user only 
            ds = TaskGeneratorBLL.Instance.GetClosedTasks(userId, desigID, strSearch, grdTaskClosed.PageIndex, grdTaskClosed.PageSize);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                grdTaskClosed.DataSource = ds;
                grdTaskClosed.VirtualItemCount = Convert.ToInt32(ds.Tables[1].Rows[0]["TotalRecords"]);
                grdTaskClosed.DataBind();
            }
            else
            {
                //lblMessage.Text = "No In-Progress Tasks Found !!!";
                grdTaskClosed.DataSource = null;
                grdTaskClosed.DataBind();

            }
        }

        protected void OnPagingTaskInProgress(object sender, GridViewPageEventArgs e)
        {
            grdTaskPending.PageIndex = e.NewPageIndex;
            BindTaskInProgressGrid();
            grdTaskPending.DataBind();
        }
        protected void OnPagingTaskClosed(object sender, GridViewPageEventArgs e)
        {
            grdTaskClosed.PageIndex = e.NewPageIndex;
            BindTaskClosedGrid();
            grdTaskClosed.DataBind();
        }
        protected void OnPaginggrdFrozenTask(object sender, GridViewPageEventArgs e)
        {
            grdFrozenTask.PageIndex = e.NewPageIndex;
            BindFrozenTasks();
            grdFrozenTask.DataBind();
        }

        protected void OnPaginggrdNewTask(object sender, GridViewPageEventArgs e)
        {
            grdNewTask.PageIndex = e.NewPageIndex;
            BindNewTasks();
            grdNewTask.DataBind();
        }

        protected void grdTaskPending_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField lblStatus = e.Row.FindControl("lblStatus") as HiddenField;
                //Label lblDueDate = e.Row.FindControl("lblDueDate") as Label;
                DropDownList drpStatusInPro = e.Row.FindControl("drpStatusInPro") as DropDownList;
                HiddenField lblTaskIdInPro = e.Row.FindControl("lblTaskIdInPro") as HiddenField;
                Label lblHoursLead = e.Row.FindControl("lblHoursLeadInPro") as Label;
                Label lblHoursDev = e.Row.FindControl("lblHoursDevInPro") as Label;
                LinkButton lnkInstallId = e.Row.FindControl("lnkInstallId") as LinkButton;
                HiddenField lblParentTaskIdInPro = e.Row.FindControl("lblParentTaskIdInPro") as HiddenField;
                HiddenField hdMainParentId = e.Row.FindControl("hdMainParentId") as HiddenField;

                //lnkInstallId.PostBackUrl = "~/Sr_App/TaskGenerator.aspx?TaskId=" + hdMainParentId.Value + "&hstid=" + lblTaskIdInPro.Value;
                lnkInstallId.PostBackUrl = "javascript:w= window.open('" + System.Configuration.ConfigurationManager.AppSettings["UrlToReplaceForTemplates"] + "Sr_App/TaskGenerator.aspx?TaskId=" + hdMainParentId.Value + "&hstid=" + lblTaskIdInPro.Value + "','JG Sales','left=20,top=20,width=1000,height=600,toolbar=0,resizable=0');";

                //if (lblDueDate.Text != "")
                //{
                //    DateTime dtDue = new DateTime();
                //    dtDue = Convert.ToDateTime(lblDueDate.Text);
                //    lblDueDate.Text = dtDue.ToString("dd-MMM-yyyy");
                //}

                if (lblStatus.Value == "4")
                {
                    //lblStatus.Value = "In Progress";
                    e.Row.BackColor = System.Drawing.Color.Orange;
                }
                else if (lblStatus.Value == "3")
                {
                    //lblStatus.Value = "Assigned";
                    //lblStatus.ForeColor = System.Drawing.Color.LawnGreen;
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else if (lblStatus.Value == "2")
                {
                    //lblStatus.Value = "Requested";
                    //lblStatus.ForeColor = System.Drawing.Color.Red;
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else
                {
                    ////lblStatus.Value = "Open";
                    System.Drawing.Color clr = System.Drawing.ColorTranslator.FromHtml("#f6f1f3");
                    e.Row.BackColor = clr;
                    //e.Row.BorderColor = System.Drawing.Color.Black;
                    //foreach (TableCell cell in e.Row.Cells)
                    //{
                    //    cell.BorderColor = System.Drawing.Color.Black;
                    //}
                }

                try
                {
                    int vTaskId = Convert.ToInt32(lblTaskIdInPro.Value);
                    SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                    {
                        DataSet result = new DataSet();
                        DbCommand command = database.GetSqlStringCommand("select a.* ,b.Designation from tbltaskapprovals as a,tblInstallusers as b where a.UserId=b.Id and  a.TaskId=" + vTaskId);
                        command.CommandType = CommandType.Text;
                        result = database.ExecuteDataSet(command);
                        if (result.Tables[0].Rows.Count > 0)
                        {
                            for (int i = 0; i < result.Tables[0].Rows.Count; i++)
                            {
                                if (result.Tables[0].Rows[i]["EstimatedHours"] != null && result.Tables[0].Rows[i]["EstimatedHours"] != "")
                                {
                                    if (result.Tables[0].Rows[i]["Designation"].ToString() == "ITLead" || result.Tables[0].Rows[i]["Designation"].ToString() == "Admin")
                                    {
                                        lblHoursLead.Text = "ITLead : " + result.Tables[0].Rows[i]["EstimatedHours"].ToString() + " Hrs";
                                    }
                                    else
                                    {
                                        lblHoursDev.Text = "Developer : " + result.Tables[0].Rows[i]["EstimatedHours"].ToString() + " Hrs";
                                    }
                                }
                            }
                        }
                        result.Dispose();
                    }
                    lblHoursDev.Visible = false;
                    lblHoursLead.Visible = false;
                }

                catch (Exception ex)
                {
                    // return 0;
                    //LogManager.Instance.WriteToFlatFile(ex);
                }

                // fill status dropdowns
                //----- If manager level then show all statuses
                if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
                {
                    drpStatusInPro.DataSource = CommonFunction.GetTaskStatusList();
                    //string[] arrStatus = new string[] { JGConstant.TaskStatus.Open.ToString(),JGConstant.TaskStatus.Requested.ToString(), 
                    //    JGConstant.TaskStatus.Assigned.ToString(), JGConstant.TaskStatus.InProgress.ToString(),
                    //    JGConstant.TaskStatus.Pending.ToString(),  JGConstant.TaskStatus.ReOpened.ToString(),
                    //    JGConstant.TaskStatus.Closed.ToString() ,JGConstant.TaskStatus.SpecsInProgress.ToString(),
                    //    JGConstant.TaskStatus.Deleted.ToString(),JGConstant.TaskStatus.Finished.ToString(),
                    //    JGConstant.TaskStatus.Test.ToString(),JGConstant.TaskStatus.Live.ToString(),JGConstant.TaskStatus.Billed.ToString(),
                    //};
                    //drpStatusInPro.DataSource = FillStatusDropDowns(arrStatus); 
                    drpStatusInPro.DataTextField = "Text";
                    drpStatusInPro.DataValueField = "Value";
                    drpStatusInPro.DataBind();
                    drpStatusInPro.Items.Insert(0, new ListItem("--All--", "0"));

                    for (int i = 0; i < drpStatusInPro.Items.Count; i++)
                    {
                        if (drpStatusInPro.Items[i].Text == "Assigned")
                        {
                            drpStatusInPro.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusInPro.Items[i].Text == "Requested")
                        {
                            drpStatusInPro.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusInPro.Items[i].Value)
                        {
                            drpStatusInPro.SelectedIndex = i;
                        }

                    }

                }
                else
                {
                    //----- If user level then show Test,Live,Finished statuses
                    string[] arrStatus = new string[] { JGConstant.TaskStatus.Requested.ToString(), JGConstant.TaskStatus.Assigned.ToString(), JGConstant.TaskStatus.Open.ToString(), JGConstant.TaskStatus.InProgress.ToString(), JGConstant.TaskStatus.Test.ToString(), JGConstant.TaskStatus.Finished.ToString() };
                    drpStatusInPro.DataSource = FillStatusDropDowns(arrStatus);  //objListItemCollection;
                    drpStatusInPro.DataTextField = "Text";
                    drpStatusInPro.DataValueField = "Value";
                    drpStatusInPro.DataBind();
                    drpStatusInPro.Items.Insert(0, new ListItem("--All--", "0"));
                    for (int i = 0; i < drpStatusInPro.Items.Count; i++)
                    {
                        if (drpStatusInPro.Items[i].Text == "Assigned")
                        {
                            drpStatusInPro.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusInPro.Items[i].Text == "Requested")
                        {
                            drpStatusInPro.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusInPro.Items[i].Value)
                        {
                            drpStatusInPro.SelectedIndex = i;
                        }
                    }
                }
            }
        }
        protected void grdTaskClosed_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField lblStatus = e.Row.FindControl("lblStatus") as HiddenField;
                //Label lblDueDate = e.Row.FindControl("lblDueDate") as Label;
                DropDownList drpStatusClosed = e.Row.FindControl("drpStatusClosed") as DropDownList;
                HiddenField lblTaskIdClosed = e.Row.FindControl("lblTaskIdClosed") as HiddenField;
                HiddenField hdnMainParentId = e.Row.FindControl("hdnMainParentId") as HiddenField;

                LinkButton lnkInstallId = e.Row.FindControl("lnkInstallId") as LinkButton;
                HiddenField lblParentTaskIdClosed = e.Row.FindControl("lblParentTaskIdClosed") as HiddenField;

                //lnkInstallId.PostBackUrl = "~/Sr_App/TaskGenerator.aspx?TaskId=" + hdnMainParentId.Value + "&hstid=" + lblTaskIdClosed.Value;
                lnkInstallId.PostBackUrl = "javascript:w= window.open('" + System.Configuration.ConfigurationManager.AppSettings["UrlToReplaceForTemplates"] + "Sr_App/TaskGenerator.aspx?TaskId=" + hdnMainParentId.Value + "&hstid=" + lblTaskIdClosed.Value + "','JG Sales','left=20,top=20,width=1000,height=600,toolbar=0,resizable=0');";
                //if (lblDueDate.Text != "")
                //{
                //    DateTime dtDue = new DateTime();
                //    dtDue = Convert.ToDateTime(lblDueDate.Text);
                //    lblDueDate.Text = dtDue.ToString("dd-MMM-yyyy");
                //}

                if (lblStatus.Value == "7")
                {
                    //lblStatus.Value = "In Progress"
                    e.Row.BackColor = System.Drawing.Color.LightGray;
                }
                else if (lblStatus.Value == "13")
                {
                    //lblStatus.Value = "Assigned";
                    //lblStatus.ForeColor = System.Drawing.Color.LawnGreen;
                    e.Row.BackColor = System.Drawing.Color.Green;
                }
                else if (lblStatus.Value == "9")
                {
                    //lblStatus.Value = "Requested";
                    //lblStatus.ForeColor = System.Drawing.Color.Red;
                    e.Row.BackColor = System.Drawing.Color.Gray;
                }
                else
                {
                    System.Drawing.Color clr = System.Drawing.ColorTranslator.FromHtml("#f6f1f3");
                    e.Row.BackColor = clr;
                }

                int vTaskId = Convert.ToInt32(lblTaskIdClosed.Value);

                // fill status dropdowns
                //----- If manager level then show all statuses

                string[] arrStatus;
                if ((string)Session["DesigNew"] == "Admin")
                {
                    drpStatusClosed.DataSource = CommonFunction.GetTaskStatusList();
                }
                else if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Office Manager")
                {
                    arrStatus = new string[] { JGConstant.TaskStatus.Open.ToString(),JGConstant.TaskStatus.Requested.ToString(), 
                        JGConstant.TaskStatus.Assigned.ToString(), JGConstant.TaskStatus.InProgress.ToString(),
                        JGConstant.TaskStatus.Pending.ToString(),  JGConstant.TaskStatus.ReOpened.ToString(),
                        JGConstant.TaskStatus.SpecsInProgress.ToString(),
                        JGConstant.TaskStatus.Finished.ToString(),
                        JGConstant.TaskStatus.Test.ToString(),JGConstant.TaskStatus.Live.ToString()
                    };
                    drpStatusClosed.DataSource = FillStatusDropDowns(arrStatus);
                }
                else
                {
                    //----- If user level then show Test,Live,Finished statuses
                    arrStatus = new string[] { JGConstant.TaskStatus.Test.ToString(), JGConstant.TaskStatus.Live.ToString() };
                    drpStatusClosed.DataSource = FillStatusDropDowns(arrStatus);
                }


                drpStatusClosed.DataTextField = "Text";
                drpStatusClosed.DataValueField = "Value";
                drpStatusClosed.DataBind();
                drpStatusClosed.Items.Insert(0, new ListItem("--All--", "0"));
                for (int i = 0; i < drpStatusClosed.Items.Count; i++)
                {

                    if (lblStatus.Value == drpStatusClosed.Items[i].Value)
                    {
                        drpStatusClosed.SelectedIndex = i;
                    }
                }

            }
        }

        protected void grdFrozenTask_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField lblStatus = e.Row.FindControl("lblStatus") as HiddenField;
                //Label lblDueDate = e.Row.FindControl("lblDueDate") as Label;
                DropDownList drpStatusFrozen = e.Row.FindControl("drpStatusFrozen") as DropDownList;
                HiddenField lblTaskIdInPro = e.Row.FindControl("lblTaskIdInPro") as HiddenField;
                HiddenField frozenMainParentId = e.Row.FindControl("frozenMainParentId") as HiddenField;
                Label lblHoursLead = e.Row.FindControl("lblHoursLeadInPro") as Label;
                Label lblHoursDev = e.Row.FindControl("lblHoursDevInPro") as Label;
                LinkButton lnkInstallId = e.Row.FindControl("lnkInstallId") as LinkButton;
                HiddenField lblParentTaskIdInPro = e.Row.FindControl("lblParentTaskIdInPro") as HiddenField;
                HtmlGenericControl divAdmin = (HtmlGenericControl)e.Row.FindControl("divAdmin");
                HtmlGenericControl divITLead = (HtmlGenericControl)e.Row.FindControl("divITLead");
                HtmlGenericControl divUser = (HtmlGenericControl)e.Row.FindControl("divUser");

                //lnkInstallId.PostBackUrl = "~/Sr_App/TaskGenerator.aspx?TaskId=" + lblParentTaskIdInPro.Value + "&hstid=" + lblTaskIdInPro.Value;
                lnkInstallId.PostBackUrl = "javascript:w= window.open('" + System.Configuration.ConfigurationManager.AppSettings["UrlToReplaceForTemplates"] + "Sr_App/TaskGenerator.aspx?TaskId=" + frozenMainParentId.Value + "&hstid=" + lblTaskIdInPro.Value + "','JG Sales','left=20,top=20,width=1000,height=600,toolbar=0,resizable=0');";

                //if (lblDueDate.Text != "")
                //{
                //    DateTime dtDue = new DateTime();
                //    dtDue = Convert.ToDateTime(lblDueDate.Text);
                //    lblDueDate.Text = dtDue.ToString("dd-MMM-yyyy");
                //}

                bool blAdminStatus = false, blTechLeadStatus = false, blOtherUserStatus = false;

                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "AdminStatus").ToString()))
                {
                    blAdminStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "AdminStatus"));
                }
                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TechLeadStatus").ToString()))
                {
                    blTechLeadStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "TechLeadStatus"));
                }
                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "OtherUserStatus").ToString()))
                {
                    blOtherUserStatus = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "OtherUserStatus"));
                }

                if (blAdminStatus || blTechLeadStatus)
                {
                    lblHoursLead.Text = "Admin: " + Convert.ToString(DataBinder.Eval(e.Row.DataItem, "AdminOrITLeadEstimatedHours"));
                }
                if (blOtherUserStatus)
                {
                    lblHoursDev.Text = "Dev: " + Convert.ToString(DataBinder.Eval(e.Row.DataItem, "UserEstimatedHours"));
                }


                if (lblStatus.Value == "4")
                {
                    //lblStatus.Value = "In Progress";
                    e.Row.BackColor = System.Drawing.Color.Orange;
                }
                else if (lblStatus.Value == "3")
                {
                    //lblStatus.Value = "Assigned";
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else if (lblStatus.Value == "2")
                {
                    //lblStatus.Value = "Requested";
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else
                {
                    ////lblStatus.Value = "Open";
                    System.Drawing.Color clr = System.Drawing.ColorTranslator.FromHtml("#f6f1f3");
                    e.Row.BackColor = clr;
                }

                

                // fill status dropdowns
                //----- If manager level then show all statuses
                if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
                {
                    drpStatusFrozen.DataSource = CommonFunction.GetTaskStatusList();
                    drpStatusFrozen.DataTextField = "Text";
                    drpStatusFrozen.DataValueField = "Value";
                    drpStatusFrozen.DataBind();
                    drpStatusFrozen.Items.Insert(0, new ListItem("--All--", "0"));

                    for (int i = 0; i < drpStatusFrozen.Items.Count; i++)
                    {
                        if (drpStatusFrozen.Items[i].Text == "Assigned")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusFrozen.Items[i].Text == "Requested")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusFrozen.Items[i].Value)
                        {
                            drpStatusFrozen.SelectedIndex = i;
                        }

                    }

                }
                else
                {
                    //----- If user level then show Test,Live,Finished statuses
                    string[] arrStatus = new string[] { JGConstant.TaskStatus.Requested.ToString(), JGConstant.TaskStatus.Assigned.ToString(), JGConstant.TaskStatus.Open.ToString(), JGConstant.TaskStatus.InProgress.ToString(), JGConstant.TaskStatus.Test.ToString(), JGConstant.TaskStatus.Finished.ToString() };
                    drpStatusFrozen.DataSource = FillStatusDropDowns(arrStatus);  //objListItemCollection;
                    drpStatusFrozen.DataTextField = "Text";
                    drpStatusFrozen.DataValueField = "Value";
                    drpStatusFrozen.DataBind();
                    drpStatusFrozen.Items.Insert(0, new ListItem("--All--", "0"));
                    for (int i = 0; i < drpStatusFrozen.Items.Count; i++)
                    {
                        if (drpStatusFrozen.Items[i].Text == "Assigned")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusFrozen.Items[i].Text == "Requested")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusFrozen.Items[i].Value)
                        {
                            drpStatusFrozen.SelectedIndex = i;
                        }
                    }
                }

                drpStatusFrozen.Attributes.Add("data-task-id", lblTaskIdInPro.Value);
            }
        }

        protected void grdNewTask_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField lblStatus = e.Row.FindControl("lblStatus") as HiddenField;
                //Label lblDueDate = e.Row.FindControl("lblDueDate") as Label;
                DropDownList drpStatusInPro = e.Row.FindControl("drpStatusInPro") as DropDownList;
                DropDownList drpStatusFrozen = e.Row.FindControl("drpStatusFrozen") as DropDownList;
                HiddenField lblTaskIdInPro = e.Row.FindControl("lblTaskIdInPro") as HiddenField;
                HiddenField nonfrozenMainParentId = e.Row.FindControl("nonfrozenMainParentId") as HiddenField;
                Label lblHoursLead = e.Row.FindControl("lblHoursLeadInPro") as Label;
                Label lblHoursDev = e.Row.FindControl("lblHoursDevInPro") as Label;
                LinkButton lnkInstallId = e.Row.FindControl("lnkInstallId") as LinkButton;
                HiddenField lblParentTaskIdInPro = e.Row.FindControl("lblParentTaskIdInPro") as HiddenField;

                //lnkInstallId.PostBackUrl = "~/Sr_App/TaskGenerator.aspx?TaskId=" + lblParentTaskIdInPro.Value + "&hstid=" + lblTaskIdInPro.Value;
                lnkInstallId.PostBackUrl = "javascript:w= window.open('" + System.Configuration.ConfigurationManager.AppSettings["UrlToReplaceForTemplates"] + "Sr_App/TaskGenerator.aspx?TaskId=" + nonfrozenMainParentId.Value + "&hstid=" + lblTaskIdInPro.Value + "','JG Sales','left=20,top=20,width=1000,height=600,toolbar=0,resizable=0');";

                //if (lblDueDate.Text != "")
                //{
                //    DateTime dtDue = new DateTime();
                //    dtDue = Convert.ToDateTime(lblDueDate.Text);
                //    lblDueDate.Text = dtDue.ToString("dd-MMM-yyyy");
                //}

                if (lblStatus.Value == "4")
                {
                    //lblStatus.Value = "In Progress";
                    e.Row.BackColor = System.Drawing.Color.Orange;
                }
                else if (lblStatus.Value == "3")
                {
                    //lblStatus.Value = "Assigned";
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else if (lblStatus.Value == "2")
                {
                    //lblStatus.Value = "Requested";
                    e.Row.BackColor = System.Drawing.Color.Yellow;
                }
                else
                {
                    ////lblStatus.Value = "Open";
                    System.Drawing.Color clr = System.Drawing.ColorTranslator.FromHtml("#f6f1f3");
                    e.Row.BackColor = clr;
                }



                // fill status dropdowns
                //----- If manager level then show all statuses
                if ((string)Session["DesigNew"] == "ITLead" || (string)Session["DesigNew"] == "Admin" || (string)Session["DesigNew"] == "Office Manager")
                {
                    drpStatusFrozen.DataSource = CommonFunction.GetTaskStatusList();
                    drpStatusFrozen.DataTextField = "Text";
                    drpStatusFrozen.DataValueField = "Value";
                    drpStatusFrozen.DataBind();
                    drpStatusFrozen.Items.Insert(0, new ListItem("--All--", "0"));

                    for (int i = 0; i < drpStatusFrozen.Items.Count; i++)
                    {
                        if (drpStatusFrozen.Items[i].Text == "Assigned")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusFrozen.Items[i].Text == "Requested")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusFrozen.Items[i].Value)
                        {
                            drpStatusFrozen.SelectedIndex = i;
                        }

                    }

                }
                else
                {
                    //----- If user level then show Test,Live,Finished statuses
                    string[] arrStatus = new string[] { JGConstant.TaskStatus.Requested.ToString(), JGConstant.TaskStatus.Assigned.ToString(), JGConstant.TaskStatus.Open.ToString(), JGConstant.TaskStatus.InProgress.ToString(), JGConstant.TaskStatus.Test.ToString(), JGConstant.TaskStatus.Finished.ToString() };
                    drpStatusFrozen.DataSource = FillStatusDropDowns(arrStatus);  //objListItemCollection;
                    drpStatusFrozen.DataTextField = "Text";
                    drpStatusFrozen.DataValueField = "Value";
                    drpStatusFrozen.DataBind();
                    drpStatusFrozen.Items.Insert(0, new ListItem("--All--", "0"));
                    for (int i = 0; i < drpStatusFrozen.Items.Count; i++)
                    {
                        if (drpStatusFrozen.Items[i].Text == "Assigned")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "LawnGreen");
                        }
                        if (drpStatusFrozen.Items[i].Text == "Requested")
                        {
                            drpStatusFrozen.Items[i].Attributes.CssStyle.Add("color", "Red");
                        }

                        if (lblStatus.Value == drpStatusFrozen.Items[i].Value)
                        {
                            drpStatusFrozen.SelectedIndex = i;
                        }
                    }
                }

                drpStatusFrozen.Attributes.Add("data-task-id", lblTaskIdInPro.Value);
            }
        }

        protected void gv_drpStatusFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl_status = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl_status.Parent.Parent;
            int idx = row.RowIndex;

            //Retrieve bookid and studentid from Gridview and status(dropdownlist)
            int vTaskId = Convert.ToInt32(((HiddenField)row.Cells[0].FindControl("lblTaskIdInPro")).Value);

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetSqlStringCommand("update  tblTask set [status]=" + ddl_status.SelectedValue + " where TaskId=" + vTaskId);
                    command.CommandType = CommandType.Text;
                    database.ExecuteNonQuery(command);
                }

                BindFrozenTasks();
                BindNewTasks();
            }
            catch (Exception ex)
            {

            }
        }

        protected void drpStatusInPro_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl_status = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl_status.Parent.Parent;
            int idx = row.RowIndex;


            //Retrieve bookid and studentid from Gridview and status(dropdownlist)
            int vTaskId = Convert.ToInt32(((HiddenField)row.Cells[0].FindControl("lblTaskIdInPro")).Value);

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetSqlStringCommand("update  tblTask set [status]=" + ddl_status.SelectedValue + " where TaskId=" + vTaskId);
                    command.CommandType = CommandType.Text;
                    database.ExecuteNonQuery(command);
                }

                BindTaskInProgressGrid();
                BindTaskClosedGrid();
            }
            catch (Exception ex)
            {
                // return 0;
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }

        protected void drpStatusClosed_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl_status = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl_status.Parent.Parent;
            int idx = row.RowIndex;

            //Retrieve bookid and studentid from Gridview and status(dropdownlist)
            int vTaskId = Convert.ToInt32(((HiddenField)row.Cells[0].FindControl("lblTaskIdClosed")).Value);

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetSqlStringCommand("update  tblTask set [status]=" + ddl_status.SelectedValue + " where TaskId=" + vTaskId);
                    command.CommandType = CommandType.Text;
                    database.ExecuteNonQuery(command);
                }

                BindTaskClosedGrid();
            }
            catch (Exception ex)
            {
                // return 0;
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }

        protected void drpPageSizeInpro_SelectedIndexChanged(object sender, EventArgs e)
        {
            grdTaskPending.PageSize = Convert.ToInt32(drpPageSizeInpro.SelectedValue);
            grdTaskPending.PageIndex = 0;
            BindTaskInProgressGrid();
        }

        protected void btnSearchInPro_Click(object sender, EventArgs e)
        {
            BindTaskInProgressGrid();
        }

        protected void drpPageSizeClosed_SelectedIndexChanged(object sender, EventArgs e)
        {
            grdTaskClosed.PageSize = Convert.ToInt32(drpPageSizeClosed.SelectedValue);
            grdTaskClosed.PageIndex = 0;
            BindTaskClosedGrid();
        }

        protected void btnSearchClosed_Click(object sender, EventArgs e)
        {
            BindTaskClosedGrid();
        }

        protected void drpPageSizeNew_SelectedIndexChanged(object sender, EventArgs e)
        {
            grdNewTask.PageSize = Convert.ToInt32(drpPageSizeNew.SelectedValue);
            grdNewTask.PageIndex = 0;
            BindNewTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }

        protected void drpPageSizeFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            grdFrozenTask.PageSize = Convert.ToInt32(drpPageSizeFrozen.SelectedValue);
            grdFrozenTask.PageIndex = 0;
            BindFrozenTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }

        protected void btnSearchFrozen_Click(object sender, EventArgs e)
        {
            BindFrozenTasks();
            //upAlerts.Update();
            //mpNewFrozenTask.Show();
        }

        protected void ddlInprogressUserDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            string designations = GetSelectedDesignationsString(ddlInprogressUserDesignation);

            LoadFilterUsersByDesgination(designations, ddlInProgressAssignedUsers);
            
            BindTaskInProgressGrid();

            ddlInProgressAssignedUsers_SelectedIndexChanged(sender, e);

            ddlInprogressUserDesignation.Texts.SelectBoxCaption = "Select";
            foreach (ListItem item in ddlInprogressUserDesignation.Items)
            {
                if (item.Selected)
                {
                    ddlInprogressUserDesignation.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void ddlDesigFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            string designations = GetSelectedDesignationsString(ddlDesigFrozen);

            LoadFilterUsersByDesgination(designations, ddlUserFrozen);

            BindFrozenTasks();
            BindNewTasks();

            gv_ddlUserFrozen_SelectedIndexChanged(sender, e);

            ddlDesigFrozen.Texts.SelectBoxCaption = "Select";
            foreach (ListItem item in ddlDesigFrozen.Items)
            {
                if (item.Selected)
                {
                    ddlDesigFrozen.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void gv_ddlUserFrozen_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindFrozenTasks();
            BindNewTasks();

            ddlUserFrozen.Texts.SelectBoxCaption = "--All--";

            foreach (ListItem item in ddlUserFrozen.Items)
            {
                if (item.Selected)
                {
                    ddlUserFrozen.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void ddlClosedUserDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            string designations = GetSelectedDesignationsString(ddlClosedUserDesignation);

            LoadFilterUsersByDesgination(designations, ddlClosedAssignedUsers);
            
            BindTaskClosedGrid();

            ddlClosedUserDesignation.Texts.SelectBoxCaption = "Select";
            foreach (ListItem item in ddlClosedUserDesignation.Items)
            {
                if (item.Selected)
                {
                    ddlClosedUserDesignation.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void ddlInProgressAssignedUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindTaskInProgressGrid();

            //ddlInProgressAssignedUsers.Texts.SelectBoxCaption = "--All--";

            //foreach (ListItem item in ddlInProgressAssignedUsers.Items)
            //{
            //    if (item.Selected)
            //    {
            //        ddlInProgressAssignedUsers.Texts.SelectBoxCaption = item.Text;
            //        break;
            //    }
            //}
        }

        protected void ddlClosedAssignedUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindTaskClosedGrid();

            ddlClosedAssignedUsers.Texts.SelectBoxCaption = "--All--";

            foreach (ListItem item in ddlClosedAssignedUsers.Items)
            {
                if (item.Selected)
                {
                    ddlClosedAssignedUsers.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        private string GetSelectedDesignationsString(ListBox drpChkBoxes)
        {
            String returnVal = string.Empty;
            StringBuilder sbDesignations = new StringBuilder();

            foreach (ListItem item in drpChkBoxes.Items)
            {
                if (item.Selected)
                {
                    sbDesignations.Append(String.Concat(item.Value, ","));
                }
            }

            if (sbDesignations.Length > 0)
            {
                returnVal = sbDesignations.ToString().Substring(0, sbDesignations.ToString().Length - 1);
            }

            return returnVal;
        }


        private string GetSelectedDesignationsString(Saplin.Controls.DropDownCheckBoxes drpChkBoxes)
        {
            String returnVal = string.Empty;
            StringBuilder sbDesignations = new StringBuilder();

            foreach (ListItem item in drpChkBoxes.Items)
            {
                if (item.Selected)
                {
                    sbDesignations.Append(String.Concat(item.Value, ","));
                }
            }

            if (sbDesignations.Length > 0)
            {
                returnVal = sbDesignations.ToString().Substring(0, sbDesignations.ToString().Length - 1);
            }

            return returnVal;
        }

        private System.Web.UI.WebControls.ListItemCollection FillStatusDropDowns(string[] lst)
        {
            ListItemCollection objListItemCollection = new ListItemCollection();
            int enumlen = Enum.GetNames(typeof(JGConstant.TaskStatus)).Length;

            foreach (var item in Enum.GetNames(typeof(JGConstant.TaskStatus)))
            {
                for (int j = 0; j < lst.Length; j++)
                {
                    if (lst[j] == item)
                    {
                        int enumval = (int)Enum.Parse(typeof(JGConstant.TaskStatus), item);
                        objListItemCollection.Add(new ListItem(item, enumval.ToString()));

                        break;
                    }
                }
            }
            return objListItemCollection;
        }
        
        protected void searchUsers_Click(object sender, EventArgs e)
        {
            BindTaskInProgressGrid();
        }

    }

}