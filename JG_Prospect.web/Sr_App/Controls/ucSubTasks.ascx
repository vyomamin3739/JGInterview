<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucSubTasks.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.ucSubTasks" %>

<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="~/Controls/CustomPager.ascx" TagPrefix="uc" TagName="CustomPager" %>

<link rel="stylesheet" type="text/css" href="../css/lightslider.css">
<script type="text/javascript" src="../js/lightslider.js"></script>
<style type="text/css">
    .installidright {
        text-align: right;
        width: 80px;
        display: block;
        padding-right: 5px;
    }

    .installidcenter {
        text-align: center;
        width: 80px;
        display: block;
        padding-right: 5px;
    }

    .installidleft {
        text-align: left;
        width: 80px;
        display: block;
    }


    .taskdesc a {
        text-decoration: underline;
        color: blue;
    }

    .taskdesc * {
        max-width: 100%;
    }

    .taskdesc .TitleEdit, .taskdesc .UrlEdit, .taskdesc .DescEdit {
        min-width: 200px;
        display: inline-block;
        height: 15px;
    }

    .modalBackground {
        background-color: #333333;
        filter: alpha(opacity=70);
        opacity: 0.7;
        z-index: 100 !important;
    }


    /*poup css starts*/
    .Descoverlay {
        position: fixed;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        background: rgba(0, 0, 0, 0.7);
        transition: opacity 500ms;
        visibility: hidden;
        opacity: 0;
    }

        .Descoverlay:target {
            visibility: visible;
            opacity: 1;
        }

    .Descpopup {
        margin: 70px auto;
        padding: 20px;
        background: #fff;
        border-radius: 5px;
        width: 70%;
        position: relative;
        transition: all 5s ease-in-out;
    }

        .Descpopup h2 {
            margin-top: 0;
            color: #333;
            font-family: Tahoma, Arial, sans-serif;
        }

        .Descpopup .close {
            position: absolute;
            top: 20px;
            right: 30px;
            transition: all 200ms;
            font-size: 30px;
            font-weight: bold;
            text-decoration: none;
            color: #333;
        }

            .Descpopup .close:hover {
                color: #06D85F;
            }

        .Descpopup .content {
            max-height: 30%;
            overflow: auto;
            overflow-x: hidden;
        }

            .Descpopup .content img {
                width: 100%;
            }

    @media screen and (max-width: 700px) {
        .Descpopup {
            width: 70%;
        }
    }
    /*poup css ends*/

    /*.modalPopup { 
            background-color:#FFFFFF; 
            border-width:1px; 
            border-style:solid; 
            border-color:#CCCCCC; 
            padding:1px; 
            width:100%; 
            Height:450px; 
            
        }*/

    /*.lSGallery 
   {
       width:400px;
       background-color:aqua;
       overflow:hidden;
   }
    .lSGallery li
   {
       width:40px!important;
   }*/
    .form_panel_custom ul {
        margin: 0px !important;
    }

    .dropzonetbl td {
        border: none !important;
        border-right: none !important;
    }

    .sub-task-attachments-list {
        height: 270px !important;
    }
</style>

<fieldset class="tasklistfieldset">
    <legend>Task List</legend>

    <%-- <asp:UpdatePanel ID="upAddSubTask" runat="server" UpdateMode="Conditional">
        <ContentTemplate>--%>
    <div id="divAddSubTask" runat="server">
        <asp:ValidationSummary ID="ValidationSummary2" runat="server" ValidationGroup="SubmitSubTask" ShowSummary="False" ShowMessageBox="True" />
        <%--<asp:LinkButton ID="lbtnAddNewSubTask" runat="server" Text="Add New Task" ValidationGroup="Submit" OnClick="lbtnAddNewSubTask_Click" />--%>
        <asp:HiddenField ID="hdndesignations" runat="server" Value="" />
        <asp:HiddenField ID="hdnLastSubTaskSequence" runat="server" Value="" />
        <asp:HiddenField ID="hdnTaskListId" runat="server" Value="" />
        <button type="button" id="lbtnAddNewSubTask1" onclick="shownewsubtask()" style="color: Blue; text-decoration: underline; cursor: pointer; background: none;">Add New Task</button>
        <br />
        <asp:ValidationSummary ID="vsSubTask" runat="server" ValidationGroup="vgSubTask" ShowSummary="False" ShowMessageBox="True" />
        <div id="divNEWSubTask" runat="server" class="tasklistfieldset" style="display: none;">
            <asp:HiddenField ID="hdnTaskApprovalId" runat="server" Value="0" />
            <asp:HiddenField ID="hdnSubTaskId" runat="server" Value="0" />
            <asp:HiddenField ID="hdnSubTaskIndex" runat="server" Value="-1" />
            <table class="tablealign fullwidth">
                <tr>
                    <td>ListID:
                               
                               

                               



                        <asp:TextBox ID="txtTaskListID" runat="server" Enabled="false" />
                        &nbsp;
                               
                               

                               



                        <small>
                            <a href="javascript:void(0);" style="color: #06c;" id="lnkidopt" onclick="copytoListID(this);">
                                <asp:Literal ID="listIDOpt" runat="server" />
                            </a>
                        </small>
                        <asp:CheckBox ID="chkTechTask" runat="server" Text=" Tech Task?" Checked="false" />
                    </td>
                    <td>Type <span style="color: red;">*</span>:
                               
                               

                               



                        <asp:DropDownList ID="ddlTaskType" AutoPostBack="false" runat="server" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" Display="None" ValidationGroup="vgSubTask"
                            ControlToValidate="ddlTaskType" ErrorMessage="Please enter Task Type." />
                        &nbsp;&nbsp;Priority <span style="color: red;">*</span>:
                               
                               

                               



                        <asp:DropDownList ID="ddlSubTaskPriority" runat="server" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" Display="None" ValidationGroup="vgSubTask"
                            ControlToValidate="ddlSubTaskPriority" ErrorMessage="Please enter Task Priority." />
                    </td>
                </tr>
                <tr>
                    <td>Title <span style="color: red;">*</span>:
                               
                               

                               



                        <br />
                        <asp:TextBox ID="txtSubTaskTitle" Text="" runat="server" Width="98%" CssClass="textbox" TextMode="SingleLine" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" Display="None" ValidationGroup="vgSubTask"
                            ControlToValidate="txtSubTaskTitle" ErrorMessage="Please enter Task Title." />
                    </td>
                    <td>Url <span style="color: red;">*</span>:
                               
                               

                               



                        <br />
                        <asp:TextBox ID="txtUrl" Text="" runat="server" Width="98%" CssClass="textbox" />
                        <asp:RequiredFieldValidator ID="rfvUrl" runat="server" Display="None" ValidationGroup="vgSubTask"
                            ControlToValidate="txtUrl" ErrorMessage="Please enter Task Url." />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ListBox ID="lstbUsersMaster" runat="server" Visible="false"></asp:ListBox>
                    </td>
                </tr>
                <%--as per discussion attachemnt field should be removed.--%>
                <tr>
                    <td colspan="2">Attachment(s):                      
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Description <span style="color: red;">*</span>:
                                        <br />
                        <asp:TextBox ID="txtSubTaskDescription" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="5" Width="98%" />
                        <asp:RequiredFieldValidator ID="rfvSubTaskDescription" ValidationGroup="vgSubTask"
                            runat="server" ControlToValidate="txtSubTaskDescription" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None" />
                    </td>
                </tr>
                <%--as per discussion attachemnt field should be removed.--%>
                <tr runat="server" visible="false">
                    <td>Attachment(s):<br>
                        <%--<asp:UpdatePanel ID="upAttachmentsData" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>--%>
                        <asp:HiddenField ID="hdnAttachments" runat="server" />

                        <%--                                    </ContentTemplate>
                                </asp:UpdatePanel>--%>
                        <div id="divSubTaskDropzone" runat="server" class="dropzone">
                            <div class="fallback">
                                <input name="file" type="file" multiple />
                                <input type="submit" value="Upload" />
                            </div>
                        </div>
                    </td>
                    <td>
                        <div id="divSubTaskDropzonePreview" runat="server" class="dropzone-previews">
                        </div>
                        <asp:Button ID="btnSaveSubTaskAttachment" runat="server" OnClick="btnSaveSubTaskAttachment_Click" Style="display: none;" Text="Save Attachement" />
                    </td>
                </tr>
                <%--as per discussion, estimated hours and task hour fields should be removed.--%>
                <tr runat="server" visible="false">
                    <td colspan="2">Estimated Hours:
                       
                        <asp:TextBox ID="txtEstimatedHours" runat="server" CssClass="textbox" Width="110" placeholder="Estimate" />
                        <asp:RegularExpressionValidator ID="revEstimatedHours" runat="server" ControlToValidate="txtEstimatedHours" Display="None"
                            ErrorMessage="Please enter decimal numbers for estimated hours of task." ValidationGroup="vgSubTask"
                            ValidationExpression="(\d+\.\d{1,2})?\d*" />
                    </td>
                </tr>
                <%--as per discussion, estimated hours and task hour fields should be removed.--%>
                <tr id="trDateHours" runat="server" visible="false" style="display: none;">
                    <td>Due Date:<asp:TextBox ID="txtSubTaskDueDate" runat="server" CssClass="textbox datepicker" />
                    </td>
                    <td>Hrs of Task:
                       
                        <asp:TextBox ID="txtSubTaskHours" runat="server" CssClass="textbox" />
                        <asp:RegularExpressionValidator ID="revSubTaskHours" runat="server" ControlToValidate="txtSubTaskHours" Display="None"
                            ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="vgSubTask"
                            ValidationExpression="(\d+\.\d{1,2})?\d*" />
                    </td>
                </tr>
                <tr id="trSubTaskStatus" runat="server" visible="false">
                    <td>Status:
                       
                        <asp:DropDownList ID="ddlSubTaskStatus" runat="server" />
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div class="btn_sec">
                            <%--<asp:Button ID="btnSaveSubTask" runat="server" Text="Save Sub Task" CssClass="ui-button" ValidationGroup="vgSubTask"
                                        OnClientClick="javascript:return OnSaveSubTaskClick();" OnClick="btnSaveSubTask_Click" />--%>
                            <asp:Button ID="btnSaveSubTask" runat="server" Text="Save Sub Task" CssClass="ui-button" ValidationGroup="vgSubTask"
                                OnClientClick="javascript:return OnSaveSubTaskClick();" />

                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <%--</ContentTemplate>
    </asp:UpdatePanel>--%>
    <asp:UpdatePanel ID="upSubTasks" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="divSubTaskGrid">
                <asp:HiddenField ID="hdnGridAttachment" runat="server" />
                <div style="float: left; margin-top: 15px;">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="textbox" placeholder="search users" MaxLength="15" />
                    <asp:Button ID="btnSearch" runat="server" Text="Search" Style="display: none;" class="btnSearc" OnClick="btnSearch_Click" />

                    Number of Records: 
                         
                    <asp:DropDownList ID="drpPageSize" runat="server" AutoPostBack="true"
                        OnSelectedIndexChanged="drpPageSize_SelectedIndexChanged">
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="15" Value="15" />
                        <asp:ListItem Text="20" Value="20" />
                        <asp:ListItem Text="25" Value="25" />
                    </asp:DropDownList>
                </div>

                <div id="divSubTasks_List" runat="server">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="table edit-subtask">
                        <thead>
                            <tr class="trHeader">
                                <th width="10%" class="subtask-actionid">Action-ID#</th>
                                <th width="45%" class="subtask-taskdetails">Task Details</th>
                                <th width="15%" class="subtask-assign">Assigned</th>
                                <th width="30%" class="subtask-attchments">Attachments, IMGs, Docs, Videos & Recordings</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="table edit-subtask">
                        <tbody>
                            <asp:Repeater ID="repSubTasks" runat="server" OnItemDataBound="repSubTasks_ItemDataBound">
                                <ItemTemplate>
                                    <tr id="trItem" runat="server">
                                        <td style="padding: 0px;">
                                            <asp:HiddenField ID="hdnTaskId" runat="server" Value='<%# Eval("TaskId") %>' ClientIDMode="AutoID" />
                                            <asp:HiddenField ID="hdnInstallId" runat="server" Value='<%# Eval("InstallId") %>' ClientIDMode="AutoID" />

                                            <!-- Sub Task Nested Grid STARTS -->
                                            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="subtasklevel">
                                                <tbody>
                                                    <asp:Repeater ID="repSubTasksNested" runat="server" ClientIDMode="AutoID" OnItemDataBound="repSubTasksNested_ItemDataBound">

                                                        <ItemTemplate>
                                                            <tr id="trSubTask" data-task-level='<%#Eval("NestLevel")%>' runat="server" data-taskid='<%# Eval("TaskId")%>' data-parent-taskid='<%# Eval("ParentTaskId")%>'>
                                                                <td width="10%" class='<%# "sbtlevel"+Eval("NestLevel").ToString()%>'>
                                                                    <asp:HiddenField ID="hdTitle" runat="server" Value='<%# Eval("Title")%>' ClientIDMode="AutoID" />
                                                                    <asp:HiddenField ID="hdURL" runat="server" Value='<%# Eval("URL")%>' ClientIDMode="AutoID" />
                                                                    <asp:HiddenField ID="hdTaskLevel" runat="server" Value='<%# Eval("TaskLevel")%>' ClientIDMode="AutoID" />
                                                                    <asp:HiddenField ID="hdTaskId" runat="server" Value='<%# Eval("TaskId")%>' ClientIDMode="AutoID" />

                                                                    <h5 class='<%#Eval("NestLevel").ToString() == "3"? "hide":"" %>'>
                                                                        <input type="checkbox" name="bulkaction" />
                                                                        <asp:LinkButton ID="lbtnInstallId" Style="display: inline;" data-highlighter='<%# Eval("TaskId")%>' CssClass="context-menu"
                                                                            ForeColor="Blue" runat="server" Text='<%# Eval("InstallId") %>' OnClientClick="javascript:return false;"
                                                                            ClientIDMode="AutoID" /><%--OnClick="EditSubTask_Click"--%>
                                                                        <asp:LinkButton ID="lbtnInstallIdRemove" data-highlighter='<%# Eval("TaskId")%>' CssClass="context-menu"
                                                                            ForeColor="Blue" runat="server" Text='<%# Eval("InstallId") %>' OnClientClick="javascript:return false;" Visible="false"
                                                                            ClientIDMode="AutoID" /><%--OnClick="RemoveClick"--%>
                                                                        <asp:Button ID="btnshowdivsub" CssClass='<%#Eval("NestLevel").ToString() == "2" ? "hide" : "showsubtaskDIV" %>' runat="server" Text="+" data-parent-taskid='<%# Eval("TaskId")%>'
                                                                            Style="color: Blue; text-decoration: underline; cursor: pointer; background: none;" OnClientClick="return false;" />
                                                                    </h5>

                                                                    <!-- Freezingn Task Part Starts -->
                                                                    <div class="approvalBoxes">
                                                                        <asp:CheckBox ID="chkAdmin" runat="server" CssClass="fz fz-admin" ToolTip="Admin" ClientIDMode="AutoID" />
                                                                        <asp:CheckBox ID="chkUser" runat="server" CssClass="fz fz-user" ToolTip="User" ClientIDMode="AutoID" />
                                                                        <asp:CheckBox ID="chkITLead" runat="server" CssClass="fz fz-techlead" ToolTip="IT Lead" ClientIDMode="AutoID" />
                                                                    </div>
                                                                    <div data-taskid='<%# Eval("TaskId")%>' class="approvepopup">

                                                                        <div id="divAdmin" runat="server" style="margin-bottom: 15px; font-size: x-small;">
                                                                            <div style="width: 10%;" class="display_inline">Admin: </div>
                                                                            <div style="width: 30%;" class="display_inline"></div>
                                                                            <div class='<%# String.IsNullOrEmpty( Eval("AdminStatusUpdated").ToString()) == true ? "hide" : "display_inline"  %>'>
                                                                                <asp:HyperLink ForeColor="Red" runat="server" NavigateUrl='<%# Eval("AdminUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                <%# 
                                    string.Concat(
                                                    string.IsNullOrEmpty(Eval("AdminUserInstallId").ToString())?
                                                        Eval("AdminUserId") : 
                                                        Eval("AdminUserInstallId"),
                                                    " - ",
                                                    string.IsNullOrEmpty(Eval("AdminUserFirstName").ToString())== true? 
                                                        Eval("AdminUserFirstName").ToString() : 
                                                        Eval("AdminUserFirstName").ToString(),
                                                    " ", 
                                                    Eval("AdminUserLastName").ToString()
                                                )
                                %>
                                                                                </asp:HyperLink><br />
                                                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("AdminStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("AdminStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("AdminStatusUpdated").ToString())== true?"":"(EST)" %></span></div>
                                                                            <div class='<%# String.IsNullOrEmpty( Eval("AdminStatusUpdated").ToString()) == true ? "display_inline" : "hide"  %>'>
                                                                                <input type="text" style="width: 100px;" placeholder="Admin password" onchange="javascript:FreezeTask(this);"
                                                                                    data-id="txtAdminPassword" data-hours-id="txtAdminEstimatedHours" data-taskid='<%# Eval("TaskId")%>' />
                                                                            </div>
                                                                        </div>
                                                                        <div id="divITLead" runat="server" style="margin-bottom: 15px; font-size: x-small;">
                                                                            <div style="width: 10%;" class="display_inline">ITLead: </div>
                                                                            <!-- ITLead Hours section -->
                                                                            <div style="width: 30%;" class='<%# String.IsNullOrEmpty( Eval("TechLeadStatusUpdated").ToString()) == true ? "hide": "display_inline" %>'>
                                                                                <span>
                                                                                    <asp:Label ID="lblHoursLeadInPro" runat="server"></asp:Label>
                                                                                    Hour(s)
                                                                                </span>
                                                                            </div>
                                                                            <div style="width: 30%;" class='<%# String.IsNullOrEmpty( Eval("TechLeadStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                                                <input type="text" style="width: 55px;" placeholder="Est. Hours" data-id="txtITLeadEstimatedHours" />
                                                                            </div>
                                                                            <!-- ITLead password section -->
                                                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("TechLeadStatusUpdated").ToString()) == true ? "hide" : "display_inline"  %>'>
                                                                                <asp:HyperLink ForeColor="Black" runat="server" NavigateUrl='<%# Eval("TechLeadUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                    <%# 
                                        string.Concat(
                                                        string.IsNullOrEmpty(Eval("TechLeadUserInstallId").ToString())?
                                                            Eval("TechLeadUserId") : 
                                                            Eval("TechLeadUserInstallId"),
                                                        " - ",
                                                        string.IsNullOrEmpty(Eval("TechLeadUserFirstName").ToString())== true? 
                                                            Eval("TechLeadUserFirstName").ToString() : 
                                                            Eval("TechLeadUserFirstName").ToString(),
                                                        "", 
                                                        Eval("TechLeadUserLastName").ToString()
                                                    )
                                    %>
                                                                                </asp:HyperLink><br />
                                                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("TechLeadStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("TechLeadStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("TechLeadStatusUpdated").ToString())== true?"":"(EST)" %></span></div>
                                                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("TechLeadStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                                                <input type="password" style="width: 100px;" placeholder="ITLead Password" onchange="javascript:FreezeTask(this);"
                                                                                    data-id="txtITLeadPassword" data-hours-id="txtITLeadEstimatedHours" data-taskid='<%# Eval("TaskId")%>' />
                                                                            </div>
                                                                        </div>
                                                                        <div id="divUser" runat="server" style="margin-bottom: 15px; font-size: x-small;">
                                                                            <div style="width: 10%;" class="display_inline">User: </div>
                                                                            <!-- UserHours section -->
                                                                            <div style="width: 30%;" class='<%# String.IsNullOrEmpty( Eval("OtherUserStatusUpdated").ToString()) == true ? "hide": "display_inline" %>'>
                                                                                <span>
                                                                                    <asp:Label ID="lblHoursDevInPro" runat="server"></asp:Label>
                                                                                    Hour(s)</span>
                                                                            </div>
                                                                            <div style="width: 30%;" class='<%# String.IsNullOrEmpty( Eval("OtherUserStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                                                <input type="text" style="width: 55px;" placeholder="Est. Hours" data-id="txtUserEstimatedHours" />
                                                                            </div>
                                                                            <!-- User password section -->
                                                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("OtherUserStatusUpdated").ToString()) == true ? "hide" : "display_inline"  %>'>
                                                                                <asp:HyperLink ForeColor="Blue" runat="server" NavigateUrl='<%# Eval("TechLeadUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                <%# 
                                    string.Concat(
                                                    string.IsNullOrEmpty(Eval("OtherUserInstallId").ToString())?
                                                        Eval("OtherUserId") : 
                                                        Eval("OtherUserInstallId"),
                                                    " - ",
                                                    string.IsNullOrEmpty(Eval("OtherUserFirstName").ToString())== true? 
                                                        Eval("OtherUserFirstName").ToString() : 
                                                        Eval("OtherUserFirstName").ToString(),
                                                    " ", 
                                                    Eval("OtherUserLastName").ToString()
                                                )
                                %>
                                                                                </asp:HyperLink><br />
                                                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("OtherUserStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("OtherUserStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("OtherUserStatusUpdated").ToString())== true?"":"(EST)" %></span></div>
                                                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("OtherUserStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                                                <input type="password" style="width: 100px;" placeholder="User Password" onchange="javascript:FreezeTask(this);"
                                                                                    data-id="txtUserPassword" data-hours-id="txtUserEstimatedHours" data-taskid='<%# Eval("TaskId")%>' />
                                                                            </div>

                                                                        </div>
                                                                        <asp:HiddenField ID="hdnTaskApprovalId" runat="server" Value='<%# Eval("TaskApprovalId") %>' ClientIDMode="AutoID" />
                                                                    </div>
                                                                    <div style="display: none;">
                                                                        <asp:TextBox ID="txtEstimatedHours" runat="server" data-id="txtEstimatedHours" CssClass="textbox" Width="80"
                                                                            placeholder="Estimate" Text='<%# Eval("TaskApprovalEstimatedHours") %>' ClientIDMode="AutoID" />
                                                                        <br />
                                                                        <asp:TextBox ID="txtPasswordToFreezeSubTask" runat="server" TextMode="Password"
                                                                            data-id="txtPasswordToFreezeSubTask" data-hours-id="txtEstimatedHours" data-taskid='<%# Eval("TaskId")%>'
                                                                            AutoPostBack="false" CssClass="textbox" Width="80" onchange="javascript:FreezeTask(this)" ClientIDMode="AutoID" /><%--OnTextChanged="repSubTasksNested_txtPasswordToFreezeSubTask_TextChanged"--%>
                                                                    </div>
                                                                    <!-- Freezingn Task Part Ends -->
                                                                </td>
                                                                <td width="45%">
                                                                    <div class='<%#Eval("NestLevel").ToString() == "3"? "left":"hide" %>' style="border-right: 0px solid #FFF; padding-right: 5px; width: 30px;">
                                                                        <input type="checkbox" name="bulkaction" />
                                                                        <a href="javascript:void(0);" data-highlighter='<%# Eval("TaskId")%>' class="context-menu" style="color: blue;"><%# Eval("InstallId")%></a>
                                                                    </div>
                                                                    <div class="divtdetails left" style="background-color: white; border-bottom: 1px solid silver; padding: 3px; max-width: 380px; width: 380px; overflow: auto;">
                                                                        <div class="taskdesc" style="padding-bottom: 5px; width: 98%; color: black!important;">
                                                                            <div class="right">
                                                                                <asp:HyperLink ForeColor="Blue" runat="server" NavigateUrl='<%# Eval("TaskCreatorId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                                                    <%# 
                                                                                        string.Concat(
                                                                                                        string.IsNullOrEmpty(Eval("TaskCreatorInstallId").ToString())?
                                                                                                            Eval("TaskCreatorId") : 
                                                                                                            Eval("TaskCreatorInstallId"),
                                                                                                        "# ",
                                                                                                        string.IsNullOrEmpty(Eval("TaskCreatorFirstName").ToString())== true? 
                                                                                                            Eval("TaskCreatorFirstName").ToString() : 
                                                                                                            Eval("TaskCreatorFirstName").ToString(),
                                                                                                        " ", 
                                                                                                        Eval("TaskCreatorLastName").ToString()
                                                                                                    )
                                                                                    %>
                                                                                </asp:HyperLink><br />
                                                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("CreatedOn"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("CreatedOn"))%></span>&nbsp<span>(EST)</span>
                                                                            </div>
                                                                            <asp:Literal ID="ltrlDescription" runat="server" Text='<%# Server.HtmlDecode(Eval("Description").ToString())%>' />
                                                                        </div>
                                                                        <button type="button" id="btnsubtasksave" class="btnsubtask" style="display: none;">Save</button>
                                                                    </div>
                                                                    <div class="clr" style="height: 1px;"></div>
                                                                    <%--<asp:LinkButton ID="lnkAddMoreSubTask" Style="display: inline;" runat="server" ClientIDMode="AutoID" CssClass="showsubtaskDIV"
                                                                         >+</asp:LinkButton>--%><%--OnClick="lnkAddMoreSubTask_Click"--%>
                                                                    <asp:Button ID="btnshowdivsub1" CssClass='<%#Eval("NestLevel").ToString() == "2" ? "showsubtaskDIV" : "hide" %>' runat="server" Text="+" data-parent-taskid='<%# Eval("TaskId")%>'
                                                                        Style="text-decoration: underline; cursor: pointer; background: none;" OnClientClick="return false;" />
                                                                    &nbsp;
                                                                    <a href="javascript:void(0);" data-id="hypViewInitialComments" data-taskid='<%# Eval("TaskId")%>'
                                                                        data-parent-commentid="0" data-startindex="0" data-pagesize="2" class="hide"
                                                                        onclick="javascript:SubTaskCommentScript.GetTaskComments(this);">View Replies</a>
                                                                    <h5 class="taskCommentTitle">Comments/Feedback</h5>
                                                                    <div data-id="divSubTaskCommentPlaceHolder" data-taskid='<%# Eval("TaskId")%>' data-parent-commentid="0" class="taskComments">
                                                                    </div>
                                                                    <a href="javascript:void(0);" data-taskid='<%# Eval("TaskId")%>' data-parent-commentid="0" onclick="javascript:SubTaskCommentScript.AddTaskComment(this);">Comment +</a>
                                                                </td>
                                                                <td width="15%">
                                                                    <ul class='<%#Eval("NestLevel").ToString() == "3"? "hide":"stulli" %>'>
                                                                        <li>
                                                                            <asp:CheckBox ID="chkTechTask" runat="server" Text=" Tech Task?" ClientIDMode="AutoID"
                                                                                Checked='<%# String.IsNullOrEmpty(Eval("IsTechTask").ToString())==true? false: Convert.ToBoolean(Eval("IsTechTask")) %>'
                                                                                AutoPostBack="true" OnCheckedChanged="repSubTasksNested_chkTechTask_CheckedChanged" />
                                                                        </li>
                                                                        <li></li>
                                                                        <li>Priority
                                                                        </li>
                                                                        <li>
                                                                            <asp:DropDownList ID="ddlTaskPriority" CssClass="clsTaskPriority textbox" runat="server"
                                                                                ClientIDMode="AutoID" AutoPostBack="false" />
                                                                        </li>

                                                                        <li>Status
                                                                        </li>
                                                                        <li>
                                                                            <asp:DropDownList ID="ddlStatus" runat="server" ClientIDMode="AutoID" AutoPostBack="true"
                                                                                CssClass="textbox" OnSelectedIndexChanged="repSubTasksNested_ddlStatus_SelectedIndexChanged" />
                                                                        </li>
                                                                        <li style="display: none;">Type
                                                                        </li>
                                                                        <li style="display: none;">
                                                                            <asp:Literal ID="ltrlTaskType" runat="server" Text="N.A." />
                                                                        </li>

                                                                    </ul>
                                                                    <div class='<%#Eval("NestLevel").ToString() == "3"? "hide":"" %>'>
                                                                        <span>Assigned
                                                                        </span>
                                                                        <asp:ListBox ID="ddcbAssigned" runat="server" Width="150" ClientIDMode="AutoID" SelectionMode="Multiple"
                                                                            CssClass="chosen-select" data-placeholder="Select"
                                                                            AutoPostBack="false" />
                                                                        <%--OnSelectedIndexChanged="repSubTasksNested_ddcbAssigned_SelectedIndexChanged"--%>
                                                                        <asp:Label ID="lblAssigned" runat="server" />

                                                                    </div>
                                                                    <table style="display: none;">
                                                                        <tr>
                                                                            <td class="noborder" colspan="2">
                                                                                <h5>Estimated Hours</h5>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="noborder" width="30%"><b>ITLead</b>
                                                                            </td>
                                                                            <td class="noborder">
                                                                                <%# this.IsAdminMode ? (String.IsNullOrEmpty(Eval("AdminOrITLeadEstimatedHours").ToString())== true? "N.A." : Eval("AdminOrITLeadEstimatedHours").ToString() +" Hour(s)" ): "" %>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="noborder"><b>User</b></td>
                                                                            <td class="noborder"><%# (String.IsNullOrEmpty(Eval("UserEstimatedHours").ToString())==true? "N.A." : Eval("UserEstimatedHours").ToString() + " Hour(s)") %></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td width="30%">
                                                                    <table border="0" class='<%#Eval("NestLevel").ToString() == "3"? "hide":"dropzonetbl" %>' style="width: 100%;">
                                                                        <tr>
                                                                            <td>
                                                                                <asp:UpdatePanel ID="upAttachmentsData1" runat="server" UpdateMode="Conditional" ClientIDMode="AutoID">
                                                                                    <ContentTemplate>
                                                                                        <input id="hdnAttachments1" runat="server" type="hidden" clientidmode="AutoID" />
                                                                                    </ContentTemplate>
                                                                                </asp:UpdatePanel>
                                                                                <div id="divSubTaskDropzone1" style="width: 200px;" data-taskid='<%# Eval("TaskId")%>' onclick="javascript:SetHiddenTaskId('<%# Eval("TaskId")%>');"
                                                                                    class="dropzone dropzonetask dropzonJgStyle">
                                                                                    <div class="fallback">
                                                                                        <input name="file" type="file" multiple />
                                                                                        <%-- <input type="submit" value="Upload"     />--%>
                                                                                    </div>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div id="divSubTaskDropzonePreview1" runat="server" class="dropzone-previews">
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <table border="0" class="dropzonetbl" style="width: 100%;">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:CheckBox ID="chkUiRequested" runat="server" Text="Ui Requested?" ClientIDMode="AutoID"
                                                                                                Checked='<%# Convert.ToBoolean(Eval("IsUiRequested")) %>'
                                                                                                AutoPostBack="true" OnCheckedChanged="repSubTasksNested_chkUiRequested_CheckedChanged" />
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:Repeater ID="rptAttachment" OnItemCommand="rptAttachment_ItemCommand" OnItemDataBound="rptAttachment_ItemDataBound"
                                                                                                runat="server" ClientIDMode="AutoID">
                                                                                                <HeaderTemplate>
                                                                                                    <div class="lSSlideOuter sub-task-attachments" style="max-width: 250px;">

                                                                                                        <div class="lSSlideWrapper usingCss">
                                                                                                            <ul class="gallery list-unstyled sub-task-attachments-list">
                                                                                                </HeaderTemplate>
                                                                                                <ItemTemplate>
                                                                                                    <li id="liImage" runat="server" class="noborder" style="overflow: inherit !important; width: 247px; margin-right: 0px;">
                                                                                                        <h5>
                                                                                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue" CommandName="DownloadFile" ClientIDMode="AutoID" /></h5>
                                                                                                        <h5>
                                                                                                            <asp:Literal ID="ltlUpdateTime" runat="server"></asp:Literal></h5>
                                                                                                        <h5>
                                                                                                            <asp:Literal ID="ltlCreatedUser" runat="server"></asp:Literal></h5>
                                                                                                        <div>
                                                                                                            <asp:LinkButton ID="lbtnDelete" runat="server" ClientIDMode="AutoID" ForeColor="Blue" Text="Delete"
                                                                                                                CommandName="delete-attachment" />
                                                                                                        </div>
                                                                                                        <br />
                                                                                                        <img id="imgIcon" class="gallery-ele" style="width: 100% !important;" runat="server" src="javascript:void(0);" />


                                                                                                    </li>
                                                                                                </ItemTemplate>
                                                                                                <FooterTemplate>
                                                                                                    </ul>
                                                                                            </div>
                                        
                                                                                        </div>
                                                                           
                                                                                       
                                                                                               
                                                                                                </FooterTemplate>
                                                                                            </asp:Repeater>

                                                                                            <img id="defaultimgIcon" class="gallery-ele" width="247" height="185" runat="server" src="javascript:void(0);" />

                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>

                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                            <%-- Sub Task Nested Grid ENDS --%>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                        <tfoot>
                            <tr class="pagination-ys">
                                <td>
                                    <uc:CustomPager ID="repSubTasks_CustomPager" runat="server" PagerSize="5" />
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <div id="divSubTasks_Empty" runat="server">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="table edit-subtask">
                        <tr>
                            <td align="center" valign="middle" style="color: black;">No sub task available!
                            </td>
                        </tr>
                    </table>
                </div>

                <asp:Button ID="btnSaveGridAttachment" runat="server"
                    OnClick="btnSaveGridAttachment_Click" Style="display: none;" Text="Save Attachement" />
                <asp:HiddenField ID="hdDropZoneTaskId" runat="server" />
            </div>
            <asp:HiddenField ID="hdnCurrentEditingRow" runat="server" />
            <asp:LinkButton ID="lnkFake" runat="server"></asp:LinkButton>
            <asp:Button ID="btnUpdateRepeater" runat="server" OnClick="btnUpdateRepeater_Click" Style="display: none;" Text="Button" />
            <%-- <cc1:ModalPopupExtender ID="mpSubTask" runat="server" PopupControlID="pnlCalendar" TargetControlID="lnkFake"
                    BackgroundCssClass="modalBackground">
                    </cc1:ModalPopupExtender>--%>
        </ContentTemplate>
    </asp:UpdatePanel>
    <%--<asp:UpdatePanel ID="upEditSubTask" runat="server" UpdateMode="Conditional">
                <ContentTemplate>--%>
    <div id="pnlCalendar" runat="server" align="center" class="tasklistfieldset" style="display: none; background-color: white;">
        <table border="1" cellspacing="5" cellpadding="5" width="100%">
            <tr>
                <td>ListID:
                
                                   

                    y: none; background-color: white;">
        <table border="1" cellspacing="5" cellpadding="5" width="100%">
            <tr>
                <td>ListID:
                
                                   

                    <asp:TextBox ID="txtInstallId" runat="server"></asp:TextBox>
                </td>

                <td>Sub Title <span style="color: red;">*</span>:
                                   
                                   

                                   



                    <asp:TextBox ID="txtSubSubTitle" runat="server"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="SubmitSubTask"
                        runat="server" ControlToValidate="txtSubSubTitle" ForeColor="Red"
                        ErrorMessage="Please Enter Task Title" Display="None"> </asp:RequiredFieldValidator>
                </td>

                <td>Priority <span style="color: red;">*</span>:
                                   
                                   

                                   



                    <asp:DropDownList ID="drpSubTaskPriority" runat="server" />
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" Display="None" ValidationGroup="SubmitSubTask"
                        ControlToValidate="drpSubTaskPriority" ErrorMessage="Please enter Task Priority." />
                </td>

                <td>Type <span style="color: red;">*</span>: 
                                   
                                   

                    <asp:DropDownList ID="drpSubTaskType" runat="server" />
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" Display="None" ValidationGroup="SubmitSubTask"
                        ControlToValidate="drpSubTaskType" ErrorMessage="Please enter Task Type." />
                </td>
            </tr>
            <tr>
                <td>Task Description <span style="color: red;">*</span>:
                                   
                    <br />
                    <asp:TextBox ID="txtTaskDesc" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="5" Width="98%" />
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="SubmitSubTask"
                        runat="server" ControlToValidate="txtTaskDesc" ForeColor="Red"
                        ErrorMessage="Please Enter Task Description" Display="None"> </asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:HiddenField ID="txtMode" runat="server" />
                    <asp:HiddenField ID="hdParentTaskId" runat="server" />
                    <asp:HiddenField ID="hdMainParentId" runat="server" />
                    <asp:HiddenField ID="hdTaskLvl" runat="server" />
                    <asp:HiddenField ID="hdTaskId" runat="server" />
                    <div class="btn_sec">
                        <%--<asp:Button ID="btnAddMoreSubtask" runat="server" OnClientClick="javascript:return OnAddMoreSubtaskClick();"
                            TabIndex="5" Text="Submit" CssClass="ui-button"
                            OnClick="btnAddMoreSubtask_Click" ValidationGroup="SubmitSubTask" />--%>
                        <asp:Button ID="btnAddMoreSubtask" runat="server" OnClientClick="javascript:return OnAddMoreSubtaskClick();"
                            TabIndex="5" Text="Submit" CssClass="ui-button" ValidationGroup="SubmitSubTask" />
                    </div>
                    <%-- <asp:Button ID="btnCalClose" runat="server" Height="30px" Width="70px" TabIndex="6"
                                                     OnClick="btnCalClose_Click" Text="Close" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" />--%>
                </td>
            </tr>
        </table>
    </div>
    <%--    </ContentTemplate>
    </asp:UpdatePanel>--%>

    <asp:HiddenField ID="hdnAdminMode" runat="server" />
</fieldset>

<%--Popup Stars--%>
<div class="hide">

    <%--Sub Task Feedback Popup--%>
    <div id="divSubTaskFeedbackPopup" runat="server" title="Sub Task Feedback">
        <asp:UpdatePanel ID="upSubTaskFeedbackPopup" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <fieldset>
                    <legend>
                        <asp:Literal ID="ltrlSubTaskFeedbackTitle" runat="server" /></legend>
                    <%--<table cellspacing="3" cellpadding="3" width="100%">
                        <tr>
                            <td>
                                <table class="table" cellspacing="0" cellpadding="0" rules="cols" border="1"
                                    style="background-color: White; width: 100%; border-collapse: collapse;">
                                    <tbody>
                                        <tr class="trHeader " style="color: White; background-color: Black;">
                                            <th align="left" scope="col">Description</th>
                                            <th align="center" scope="col" style="width: 15%;">Attachments</th>
                                        </tr>
                                        <tr class="FirstRow">
                                            <td align="left">Feedback for sub task with install Id I.
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </table>--%>
                    <table id="tblAddEditSubTaskFeedback" runat="server" cellspacing="3" cellpadding="3" width="100%">
                        <tr>
                            <td colspan="2">&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="90" align="right" valign="top">Description:
                            </td>
                            <td>
                                <asp:TextBox ID="txtSubtaskComment" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="4" Width="90%" />
                                <asp:RequiredFieldValidator ID="rfvComment" ValidationGroup="comment"
                                    runat="server" ControlToValidate="txtSubtaskComment" ForeColor="Red" ErrorMessage="Please comment" Display="None" />
                                <asp:ValidationSummary ID="vsComment" runat="server" ValidationGroup="comment" ShowSummary="False" ShowMessageBox="True" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right" valign="top">Files:
                            </td>
                            <td>
                                <input id="hdnSubTaskNoteAttachments" runat="server" type="hidden" />
                                <input id="hdnSubTaskNoteFileType" runat="server" type="hidden" />
                                <div id="divSubTaskNoteDropzone" runat="server" class="dropzone work-file-Note">
                                    <div class="fallback">
                                        <input name="file" type="file" multiple />
                                        <input type="submit" value="Upload" />
                                    </div>
                                </div>
                                <div id="divSubTaskNoteDropzonePreview" runat="server" class="dropzone-previews work-file-previews-note">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="btn_sec">
                                    <asp:Button ID="btnSaveSubTaskFeedback" runat="server" ValidationGroup="comment" OnClick="btnSaveSubTaskFeedback_Click" CssClass="ui-button" Text="Save" />
                                    <asp:Button ID="btnSaveCommentAttachment" runat="server" OnClick="btnSaveCommentAttachment_Click" Style="display: none;" Text="Save Attachement" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>



</div>

<div id="descimgpopup1" class="Descoverlay">
    <div class="Descpopup">
        <a class="close" href="#" id="closebtn">&times;</a>
        <div class="content">
            <img src="" id="imgDesc" />
        </div>
    </div>
</div>
<%--Popup Ends--%>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/chosen.jquery.js")%>"></script>

<script type="text/template" class="hide" data-id="divSubTaskCommentTemplate">
    <table width="100%">
        <tbody data-parent-commentid="{ParentCommentId}">
        </tbody>
        <tfoot data-parent-commentid="{ParentCommentId}">
            <tr>
                <td class="noborder">
                    <a href="javascript:void(0);" data-id="hypViewComments" data-taskid="{TaskId}"
                        data-parent-commentid="{ParentCommentId}" data-startindex="0" data-pagesize="0"
                        onclick="javascript:SubTaskCommentScript.GetTaskComments(this);">View {RemainingRecords} more comments</a>
                    <a href="javascript:void(0);" data-taskid="{TaskId}" data-parent-commentid="{ParentCommentId}" class="hide"
                        onclick="javascript:SubTaskCommentScript.AddTaskComment(this);">Comment +</a>
                </td>
            </tr>
            <tr data-id="trAddComment" style="display: none;">
                <td class="noborder">
                    <div>
                        <textarea data-id="txtComment" class="textbox" style="width: 90%; height: 50px;"></textarea>
                    </div>
                    <a href="javascript:void(0);" data-id="hypSaveComment" data-comment-id="0" data-taskid="{TaskId}" data-parent-commentid="{ParentCommentId}"
                        onclick="javascript:SubTaskCommentScript.SaveTaskComment(this);">Save</a>
                    <a href="javascript:void(0);" data-id="hypCancelComment" data-taskid="{TaskId}" data-parent-commentid="{ParentCommentId}"
                        onclick="javascript:SubTaskCommentScript.CancelTaskComment(this);">Cancel</a>
                </td>
            </tr>
        </tfoot>
    </table>
</script>

<script type="text/template" class="hide" data-id="divSubTaskCommentRowTemplate">
    <tr data-commentid="{Id}">
        <td class="noborder">
            <div class="taskComment">
                {Comment}               
              
                    <div class="ctimestmap">
                        <a href='<%=Page.ResolveUrl("CreateSalesUser.aspx?id={UserId}")%>' target="_blank">{UserInstallId} - {UserFirstName} {UserLastName}
                        </a>
                        <br />
                        <span>{DateCreated_MDYYYY}</span>&nbsp<span style="color: red">{TimeCreated_HHMMSSTT}</span>&nbsp;<span>(EST)</span>
                    </div>


            </div>
            <a href="javascript:void(0);" data-id="hypViewReplies" data-taskid="{TaskId}" data-parent-commentid="{Id}" class="hide"
                data-startindex="0" data-pagesize="0" style="margin-left: 10px;"
                onclick="javascript:SubTaskCommentScript.GetTaskComments(this);">View {TotalChildRecords} Replies&nbsp;</a>
            <a href="javascript:void(0);" data-id="hypAddReply" data-taskid="{TaskId}" data-parent-commentid="{Id}"
                data-startindex="0" data-pagesize="0" onclick="javascript:SubTaskCommentScript.AddTaskComment(this);">Reply</a>
            <div data-id="divSubTaskCommentPlaceHolder" data-taskid="{TaskId}" data-parent-commentid="{Id}" class="taskdesc"
                style="margin-left: 10px;">
            </div>
            <div id="replyComment" class="hide replycomment" data-parent-commentid="{ParentCommentId}">
                <div>
                    <textarea data-id="txtComment" class="textbox" style="width: 90%; height: 50px;"></textarea>
                </div>
                <a href="javascript:void(0);" data-id="hypSaveComment" data-comment-id="0" data-taskid="{TaskId}" data-parent-commentid="{Id}"
                    onclick="javascript:SubTaskCommentScript.SaveTaskComment(this);">Save</a>
                <a href="javascript:void(0);" data-id="hypCancelComment" data-taskid="{TaskId}" data-parent-commentid="{ParentCommentId}"
                    onclick="javascript:SubTaskCommentScript.CancelTaskComment(this);">Cancel</a>
            </div>
        </td>
    </tr>
</script>

<script type="text/javascript" data-id="divSubTaskCommentScript">
    var SubTaskCommentScript = {};

    SubTaskCommentScript.Initialize = function () {
        $('a[data-id="hypViewInitialComments"]').click();
    };

    SubTaskCommentScript.GetTaskComments = function (sender) {

        var viewlink = $(sender);
        var strTaskId = viewlink.attr('data-taskid');

        var strParentCommentId = viewlink.attr('data-parent-commentid');
        var strStartIndex = viewlink.attr('data-startindex');
        var strPageSize = viewlink.attr('data-pagesize');

        if (strPageSize == "0") {
            strPageSize = null;
        }

        var postData = {
            "intTaskId": strTaskId,
            "intParentCommentId": strParentCommentId,
            "intStartIndex": strStartIndex,
            "intPageSize": strPageSize
        };

        CallJGWebService('GetTaskComments', postData, function (data) { OnGetTaskCommentsSuccess(data, sender) });

        function OnGetTaskCommentsSuccess(data, sender) {

            //debugger;
            if (data.d.Success) {
                var viewlink = $(sender);
                var strTaskId = viewlink.attr('data-taskid');
                var strParentCommentId = viewlink.attr('data-parent-commentid');
                var strStartIndex = viewlink.attr('data-startindex');
                var strPageSize = viewlink.attr('data-pagesize');

                var strSubTaskCommentTemplate = $('script[data-id="divSubTaskCommentTemplate"]').html();
                strSubTaskCommentTemplate = strSubTaskCommentTemplate.replace(/{ParentCommentId}/gi, strParentCommentId);
                strSubTaskCommentTemplate = strSubTaskCommentTemplate.replace(/{TaskId}/gi, strTaskId);
                strSubTaskCommentTemplate = strSubTaskCommentTemplate.replace(/{RemainingRecords}/gi, data.d.RemainingRecords.toString());
                strSubTaskCommentTemplate = strSubTaskCommentTemplate.replace(/{TotalRecords}/gi, data.d.TotalRecords.toString());

                var $SubTaskCommentTemplate = $(strSubTaskCommentTemplate);

                if (data.d.RemainingRecords <= 0) {
                    //$SubTaskCommentTemplate.find('a[data-id="hypViewComments"]').html('View More Replies');
                    $SubTaskCommentTemplate.find('a[data-id="hypViewComments"]').hide();
                }

                for (var i = 0; i < data.d.TaskComments.length; i++) {

                    var objTaskComment = data.d.TaskComments[i];

                    var strSubTaskCommentRowTemplate = $('script[data-id="divSubTaskCommentRowTemplate"]').html();
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{Id}/gi, objTaskComment.Id.toString());
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{Comment}/gi, objTaskComment.Comment);
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{ParentCommentId}/gi, objTaskComment.ParentCommentId.toString());
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{TaskId}/gi, objTaskComment.TaskId.toString());
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserId}/gi, objTaskComment.UserId.toString());

                    var intDateCreated = parseInt(objTaskComment.DateCreated.replace(/\//gi, '').replace('Date', '').replace(/[(]/gi, '').replace(/[)]/gi, ''));

                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{DateCreated_MDYYYY}/gi, SubTaskCommentScript.GetDate_MDYYYY(intDateCreated));
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{TimeCreated_HHMMSSTT}/gi, SubTaskCommentScript.GetTime_HHMMSSTT(intDateCreated));
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{TotalChildRecords}/gi, objTaskComment.TotalChildRecords.toString());
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserName}/gi, objTaskComment.UserName);
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserFirstName}/gi, objTaskComment.UserFirstName);
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserLastName}/gi, objTaskComment.UserLastName);
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserInstallId}/gi, objTaskComment.UserInstallId);
                    strSubTaskCommentRowTemplate = strSubTaskCommentRowTemplate.replace(/{UserEmail}/gi, objTaskComment.UserEmail);

                    $SubTaskCommentRowTemplate = $(strSubTaskCommentRowTemplate);

                    if (objTaskComment.ParentCommentId != 0) {
                        //$SubTaskCommentRowTemplate.find('a[data-id="hypAddReply"]').hide();
                        $SubTaskCommentRowTemplate.find('a[data-id="hypViewReplies"]').hide();
                    }
                    else {
                        //$SubTaskCommentRowTemplate.find('a[data-id="hypAddReply"]').show();
                    }

                    //console.log(objTaskComment.TotalChildRecords);

                    if (objTaskComment.TotalChildRecords != 0) {

                        $SubTaskCommentRowTemplate.find('a[data-id="hypViewReplies"]').removeClass('hide');
                    }

                    $SubTaskCommentTemplate.append($SubTaskCommentRowTemplate);
                }
                $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]').html('');
                $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]').append($SubTaskCommentTemplate);

                //$SubTaskCommentTemplate.find('a[data-id="hypViewReplies"]').click();
            }
        }
    };

    SubTaskCommentScript.SaveTaskComment = function (sender) {
        var $sender = $(sender);
        var strId = $sender.attr('data-comment-id');
        var strTaskId = $sender.attr('data-taskid');
        var strParentCommentId = $sender.attr('data-parent-commentid');
        var $divSubTaskCommentPlaceHolder = $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]');
        var $tfoot;

        if ($sender.parent().attr('id') == "replyComment") {
            $tfoot = $sender.parent();
        }
        else {
            $tfoot = $divSubTaskCommentPlaceHolder.find('tfoot[data-parent-commentid="' + strParentCommentId + '"]');
        }

        var strComment = $tfoot.find('textarea[data-id="txtComment"]').val();

        if (strComment != '') {
            var postData = {
                strId: strId,
                strComment: strComment,
                strParentCommentId: strParentCommentId,
                strTaskId: strTaskId
            };

            CallJGWebService('SaveTaskComment', postData, function (data) { OnSaveTaskCommentSuccess(data, sender) });

            function OnSaveTaskCommentSuccess(data, sender) {
                if (data.d.Success) {
                    console.log(data.d);

                    var $sender = $(sender);
                    var strTaskId = $sender.attr('data-taskid');
                    var strParentCommentId = $sender.attr('data-parent-commentid');
                    var $divSubTaskCommentPlaceHolder = $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]');
                    var $tfoot;

                    if ($sender.parent().attr('id') == "replyComment") {
                        $tfoot = $sender.parent();
                        $tfoot.addClass('hide');
                    }
                    else {
                        $tfoot = $divSubTaskCommentPlaceHolder.find('tfoot[data-parent-commentid="' + strParentCommentId + '"]');
                        $tfoot.find('tr[data-id="trAddComment"]').hide();
                    }

                    //$tfoot.find('a[data-id="hypViewComments"]').click();
                    $('a[data-id="hypViewInitialComments"]').click();
                }
            }
        }
    };

    SubTaskCommentScript.CancelTaskComment = function (sender) {
        var $sender = $(sender);
        var strTaskId = $sender.attr('data-taskid');
        var strParentCommentId = $sender.attr('data-parent-commentid');
        var $divSubTaskCommentPlaceHolder = $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]');
        var $tfoot;

        if ($sender.parent().attr('id') == "replyComment") {
            $tfoot = $sender.parent();
            $tfoot.find('textarea[data-id="txtComment"]').val('');
            $tfoot.addClass('hide');
        }
        else {
            $tfoot = $divSubTaskCommentPlaceHolder.find('tfoot[data-parent-commentid="' + strParentCommentId + '"]');
            $tfoot.find('textarea[data-id="txtComment"]').val('');
            $tfoot.find('tr[data-id="trAddComment"]').hide();
        }


    };

    SubTaskCommentScript.AddTaskComment = function (sender) {
        var $sender = $(sender);
        var strTaskId = $sender.attr('data-taskid');
        var strParentCommentId = $sender.attr('data-parent-commentid');

        var $divSubTaskCommentPlaceHolder = $('div[data-id="divSubTaskCommentPlaceHolder"][data-taskid="' + strTaskId + '"][data-parent-commentid="' + strParentCommentId + '"]');
        var $tfoot;

        if ($sender.html() == "Reply") {
            $tfoot = $sender.siblings('div[id="replyComment"]');
            console.log($tfoot.html());
            $tfoot.removeClass('hide');
        }
        else {
            $tfoot = $divSubTaskCommentPlaceHolder.find('tfoot[data-parent-commentid="' + strParentCommentId + '"]');
        }


        $tfoot.find('textarea[data-id="txtComment"]').val('');
        $tfoot.find('tr[data-id="trAddComment"]').show();
    };

    SubTaskCommentScript.GetDate_MDYYYY = function (date) {
        console.log(date);
        var objDate = new Date(date);

        var dd = objDate.getDate();
        var mm = objDate.getMonth() + 1; //January is 0! 
        var yyyy = objDate.getFullYear();

        //if (dd < 10) { dd = '0' + dd; } if (mm < 10) { mm = '0' + mm; }

        return (dd + '/' + mm + '/' + yyyy);
    }

    SubTaskCommentScript.GetTime_HHMMSSTT = function (date) {
        var objDate = new Date(date);

        var hh = objDate.getHours();
        var mm = objDate.getMinutes();
        var ss = objDate.getSeconds();

        //if (dd < 10) { dd = '0' + dd; } if (mm < 10) { mm = '0' + mm; }

        return (hh + ':' + mm + ':' + ss);
    }
</script>

<script type="text/javascript">
    Dropzone.autoDiscover = false;

    $(function () {
        ucSubTasks_Initialize();
    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {
        console.log('end req.');
        ucSubTasks_Initialize();

        SetUserAutoSuggestion();
        SetUserAutoSuggestionUI();
    });

    prmTaskGenerator.add_beginRequest(function () {
        console.log('begin req.');
        DestroyGallery();
        DestroyDropzones();
        DestroyCKEditors();
    });


    $(document).ready(function () {
        SetUserAutoSuggestion();
        SetUserAutoSuggestionUI();

        $('#<%=ddlTaskType.ClientID%>').change(function () {
            if ($("#<%=ddlTaskType.ClientID%>").val() == 3) {
                // as per discussion, estimated hours and task hour fields should be removed.
                //$("#<%=trDateHours.ClientID%>").css({ 'display': "block" });
            }
            else {
                // as per discussion, estimated hours and task hour fields should be removed.
                //$("#<%=trDateHours.ClientID%>").css({ 'display': "none" });
            }
            return false;
        })
    });

    var maintask = true;

    function shownewsubtask() {
        maintask = true;
        $('#<%=hdTaskLvl.ClientID%>').val("1");
        $('#<%=txtTaskListID.ClientID%>').val($('#<%=hdnTaskListId.ClientID%>').val());
        $('#<%=chkTechTask.ClientID%>').prop('checked', false)
        $("#<%=divNEWSubTask.ClientID%>").css({ 'display': "block" });
        return false;
    }

    var control;
    var isadded = false;
    var idAttachments = false;

    function pageLoad(sender, args) {
        $('#closebtn').bind("click", function () {
            $('#descimgpopup1').css({ 'visibility': "hidden" });
            $('#descimgpopup1').css({ 'opacity': "0" });
            return false;
        });
        $(".DescEdit img").each(function (index) {
            $(this).unbind('click').click(function () {
            });
            $(this).bind("click", function () {
                var imgPath = $(this).attr("src");
                $('#imgDesc').attr("src", imgPath);
                $('#descimgpopup1').css({ 'visibility': "visible" });
                $('#descimgpopup1').css({ 'opacity': "1" });
                return false;
            });
        });

        //For Title
        $(".TitleEdit").each(function (index) {
            // This section is available to admin only.
            <% if (this.IsAdminMode)
    {
               %>
            $(this).bind("click", function () {
                if (!isadded) {
                    var tid = $(this).attr("data-taskid");
                    var titledetail = $(this).html();
                    var fName = $("<input id=\"txtedittitle\" type=\"text\" value=\"" + titledetail + "\" class=\"editedTitle\" />");
                    $(this).html(fName);
                    $('#txtedittitle').focus();

                    isadded = true;
                }
            }).bind('focusout', function () {
                var tid = $(this).attr("data-taskid");
                var tdetail = $('#txtedittitle').val();
                $(this).html(tdetail);
                EditTask(tid, tdetail)
                isadded = false;
            });
            <% } %>
        });

        //For Url
        $(".UrlEdit").each(function (index) {
            // This section is available to admin only.
            <% if (this.IsAdminMode)
    {
               %>
            $(this).bind("click", function () {
                if (!isadded) {
                    var tid = $(this).attr("data-taskid");
                    var titledetail = $(this).html();
                    var fName = $("<input id=\"txtedittitle\" type=\"text\" value=\"" + titledetail + "\" class=\"editedTitle\" />");
                    $(this).html(fName);
                    $('#txtedittitle').focus();

                    isadded = true;
                }
                return false;
            }).bind('focusout', function () {
                var tid = $(this).attr("data-taskid");
                var tdetail = $('#txtedittitle').val();

                $(this).html(tdetail);
                EditUrl(tid, tdetail);
                isadded = false;
                return false;
            });
            <% } %>
        });

        //For Description
        $(".DescEdit").each(function (index) {
            // This section is available to admin only.
            <% if (this.IsAdminMode)
    {
               %>
            $(this).bind("click", function () {
                if (!isadded) {
                    var tid = $(this).attr("data-taskid");
                    var titledetail = $(this).html();
                    var fName = $("<textarea id=\"txtedittitle\" style=\"width:100%;\" class=\"editedTitle\" rows=\"10\" >" + titledetail + "</textarea>");
                    $(this).html(fName);
                    $('#<%= hdDropZoneTaskId.ClientID %>').val(tid);
                    SetCKEditorForSubTask('txtedittitle');
                    $('#txtedittitle').focus();
                    control = $(this);

                    isadded = true;

                    var otherInput = $(this).closest('.divtdetails').find('.btnsubtask');
                    $(otherInput).css({ 'display': "block" });
                    $(otherInput).bind("click", function () {
                        updateDesc(GetCKEditorContent('txtedittitle'));
                        $(this).css({ 'display': "none" });
                    });
                }
                return false;
            });
            <% } %>
        });

        //For Add Task Button
        $(".showsubtaskDIV").each(function (index) {
            // This section is available to admin only.
            <% if (this.IsAdminMode)
    {
               %>
            $(this).unbind('click').bind("click", function () {
                var commandName = $(this).attr("data-val-commandName");
                var CommandArgument = $(this).attr("data-val-CommandArgument");
                var TaskLevel = $(this).attr("data-val-taskLVL");
                var strInstallId = $(this).attr('data-installid');
                var parentTaskId = $(this).attr('data-parent-taskid');

                $("#<%=divAddSubTask.ClientID%>").hide();
                $("#<%=pnlCalendar.ClientID%>").hide();

                var objAddSubTask = null;
                if (TaskLevel == "1") {
                    objAddSubTask = $("#<%=divAddSubTask.ClientID%>");
                    shownewsubtask();
                    maintask = false;
                }
                else if (TaskLevel == "2") {
                    objAddSubTask = $("#<%=pnlCalendar.ClientID%>");

                        var $tr = $('<tr><td colspan="4"></td></tr>');
                        $tr.find('td').append(objAddSubTask);

                        var $appendAfter = $('tr[data-parent-taskid="' + parentTaskId + '"]:last');
                        if ($appendAfter.length == 0) {
                            $appendAfter = $('tr[data-taskid="' + parentTaskId + '"]:last');
                        }
                        $appendAfter.after($tr);
                    }

                if (objAddSubTask != null) {
                    objAddSubTask.show();
                    ScrollTo(objAddSubTask);
                    SetTaskDetailsForNew(CommandArgument, commandName, TaskLevel, strInstallId);
                }

                return false;
            });

            <% } %>
        });

        // For Drodown Task Priority
        $(".clsTaskPriority").each(function (index) {
            $(this).bind("change", function (e) {
                var datavaltaskid = $(this).attr("data-val-taskid");
                var ddlValue = $(this).val();
                updatePriority(datavaltaskid, ddlValue);
            });
        });

    }

    function updatePriority(id, value) {
        ShowAjaxLoader();
        var postData = {
            taskid: id,
            priority: value
        };

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/SetTaskPriority',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify(postData),
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    alert('Priority Updated successfully.');
                },
                error: function (a, b, c) {
                    HideAjaxLoader();
                }
            }
        );
    }

    function updateDesc(htmldata) {
        if (isadded) {
            control.html(htmldata);
            EditDesc(control.attr("data-taskid"), htmldata);
            isadded = false;
        }
    }

    function ShowAjaxLoader() {
        $('.loading').show();
    }

    function HideAjaxLoader() {
        $('.loading').hide();
    }

    function FreezeTask(sender) {
        var $sender = $(sender);
        var strTaskId = $sender.attr('data-taskid');
        var strHoursId = $sender.attr('data-hours-id');
        var strPasswordId = $sender.attr('data-id');

        var $tr = $('div.approvepopup[data-taskid="' + strTaskId + '"]');

        var postData = {
            strEstimatedHours: $tr.find('input[data-id="' + strHoursId + '"]').val(),
            strTaskApprovalId: $tr.find('input[id*="hdnTaskApprovalId"]').val(),
            strTaskId: strTaskId,
            strPassword: $tr.find('input[data-id="' + strPasswordId + '"]').val()
        };

        CallJGWebService('FreezeTask', postData, OnFreezeTaskSuccess);

        function OnFreezeTaskSuccess(data) {
            if (data.d.Success) {
                alert(data.d.Message);
                HidePopup('.approvepopup')
                $('#<%=hdTaskId.ClientID%>').val(data.d.TaskId.toString());
                $('#<%=btnUpdateRepeater.ClientID%>').click();
            }
            else {
                alert(data.d.Message);
            }
        }
    }

    function EditTask(tid, tdetail) {
        ShowAjaxLoader();
        var postData = {
            tid: tid,
            title: tdetail
        };

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/UpdateTaskTitleById',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify(postData),
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    alert('Title saved successfully.');
                },
                error: function (a, b, c) {
                    HideAjaxLoader();
                }
            }
        );
    }
    function EditUrl(tid, tdetail) {
        ShowAjaxLoader();
        var postData = {
            tid: tid,
            URL: tdetail
        };

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/UpdateTaskURLById',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify(postData),
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    alert('Url saved successfully.');
                },
                error: function (a, b, c) {
                    HideAjaxLoader();
                }
            }
        );
    }
    function EditDesc(tid, tdetail) {
        ShowAjaxLoader();
        var postData = {
            tid: tid,
            Description: tdetail
        };

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/UpdateTaskDescriptionById',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify(postData),
                asynch: false,
                success: function (data) {
                    if (idAttachments) {
                        $('#<%=btnSaveGridAttachment.ClientID%>').click();
                    }
                    else {
                        HideAjaxLoader();
                    }
                    alert('Description saved successfully.');
                },
                error: function (a, b, c) {
                    HideAjaxLoader();
                }
            }
        );
        }
        function EditAssignedTaskUsers(sender) {
            ShowAjaxLoader();

            var $sender = $(sender);
            var intTaskID = parseInt($sender.attr('data-taskid'));
            var intTaskStatus = parseInt($sender.attr('data-taskstatus'));
            var arrAssignedUsers = [];
            var arrDesignationUsers = [];

            $sender.find('option').each(function (index, item) {
                var intUserId = parseInt($(item).attr('value'));
                if (intUserId > 0) {
                    arrDesignationUsers.push(intUserId);

                    if ($.inArray(intUserId.toString(), $sender.val()) != -1) {
                        arrAssignedUsers.push(intUserId);
                    }
                    //if ($sender.val() == intUserId.toString()) {
                    //    arrAssignedUsers.push(intUserId);
                    //}
                }
            });

            var postData = {
                intTaskId: intTaskID,
                intTaskStatus: intTaskStatus,
                arrAssignedUsers: arrAssignedUsers
            };

            CallJGWebService('ValidateTaskStatus', postData, OnValidateTaskStatusSuccess);

            function OnValidateTaskStatusSuccess(response) {
                if (!response.d.IsValid) {
                    alert(response.d.Message);
                }
                else {
                    SaveAssignedTaskUsers();
                }
            }

            function OnValidateTaskStatusError() {
                alert('Task status cannot be validated. Please try again.');
            }

            // private function (so, it is defined in a function) to save task assigned users only after validating task status.
            function SaveAssignedTaskUsers() {
                ShowAjaxLoader();

                var postData = {
                    intTaskId: intTaskID,
                    intTaskStatus: intTaskStatus,
                    arrAssignedUsers: arrAssignedUsers,
                    arrDesignationUsers: arrDesignationUsers
                };
                CallJGWebService('SaveAssignedTaskUsers', postData, OnSaveAssignedTaskUsersSuccess, OnSaveAssignedTaskUsersError);

                function OnSaveAssignedTaskUsersSuccess(response) {
                    console.log(response);
                    if (response) {
                        alert('Task assignment saved successfully.');
                        $('#<%=hdTaskId.ClientID%>').val(intTaskID.toString());
                        $('#<%=btnUpdateRepeater.ClientID%>').click();
                    }
                    else {
                        OnSaveAssignedTaskUsersError();
                    }
                }

                function OnSaveAssignedTaskUsersError(err) {
                    //alert(JSON.stringify(err));
                    alert('Task assignment cannot be updated. Please try again.');
                }
            }
        }

        function SetTaskDetailsForNew(cmdArg, cName, TaskLevel, strInstallId) {
            ShowAjaxLoader();
            var postData = {
                CommandArgument: cmdArg,
                CommandName: cName
            };

            $.ajax
            (
                {
                    url: '../WebServices/JGWebService.asmx/GetSubTaskId',
                    contentType: 'application/json; charset=utf-8;',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify(postData),
                    asynch: false,
                    success: function (data) {
                        HideAjaxLoader();

                        if (TaskLevel == "2") {
                            var taskid = GetParameterValues('TaskId');
                            //$('#<%=txtInstallId.ClientID%>').val(data.d.txtInstallId);
                            $('#<%=txtInstallId.ClientID%>').val(strInstallId);
                            $('#<%=hdParentTaskId.ClientID%>').val(data.d.hdParentTaskId);
                            $('#<%=hdMainParentId.ClientID%>').val(taskid);
                            $('#<%=hdTaskLvl.ClientID%>').val(data.d.hdTaskLvl);
                            $('#<%=hdTaskId.ClientID%>').val(cmdArg);
                        }
                        else {
                            //$('#<%=txtTaskListID.ClientID%>').val(data.d.txtInstallId);
                            $('#<%=txtTaskListID.ClientID%>').val(strInstallId);
                            $('#<%=hdParentTaskId.ClientID%>').val(data.d.hdParentTaskId);
                            $('#<%=hdTaskLvl.ClientID%>').val(data.d.hdTaskLvl);
                            $('#<%=hdTaskId.ClientID%>').val(cmdArg);
                        }
                    },
                    error: function (a, b, c) {
                        HideAjaxLoader();
                    }
                }
        );
            }

            function OnAddMoreSubtaskClick() {
                $('#<%=txtTaskDesc.ClientID%>').val(GetCKEditorContent('<%=txtTaskDesc.ClientID%>'));
                if (Page_ClientValidate('SubmitSubTask')) {
                    ShowAjaxLoader();
                    var hdParentTaskId = $('#<%=hdParentTaskId.ClientID%>').val();
                var listID = $('#<%=txtInstallId.ClientID%>').val();
                var txtSubSubTitle = $('#<%=txtSubSubTitle.ClientID%>').val();
                var Priority = $('#<%= drpSubTaskPriority.ClientID %>').val();
                var type = $('#<%= drpSubTaskType.ClientID %>').val();
                var desc = GetCKEditorContent('<%= txtTaskDesc.ClientID %>');
                var designations = $('#<%= hdndesignations.ClientID %>').val();
                var TaskLvl = $('#<%= hdTaskLvl.ClientID %>').val();

                var postData = {
                    ParentTaskId: hdParentTaskId,
                    Title: txtSubSubTitle,
                    URL: "",
                    Desc: desc,
                    Status: "1",
                    Priority: Priority,
                    DueDate: "",
                    TaskHours: "",
                    InstallID: listID,
                    Attachments: "",
                    TaskType: type,
                    TaskDesignations: designations,
                    TaskLvl: TaskLvl,
                    blTechTask: false
                };

                CallJGWebService('AddNewSubTask', postData, OnAddNewSubTaskSuccess, OnAddNewSubTaskError);

                function OnAddNewSubTaskSuccess(data) {
                    if (data.d.Success) {
                        alert('Task saved successfully.');
                        $('#<%=hdTaskId.ClientID%>').val(data.d.TaskId.toString());
                        $('#<%=btnUpdateRepeater.ClientID%>').click();
                    }
                    else {
                        alert('Task cannot be saved. Please try again.');
                    }
                }

                function OnAddNewSubTaskError(err) {
                    alert('Task cannot be saved. Please try again.');
                }

                return false;
            }
        }

        function SetUserAutoSuggestion() {
            $("#<%=txtSearch.ClientID%>").catcomplete({
                delay: 500,
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: "ajaxcalls.aspx/GetTaskUsers",
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        data: JSON.stringify({ searchterm: request.term }),
                        success: function (data) {
                            // Handle 'no match' indicated by [ "" ] response
                            if (data.d) {

                                response(data.length === 1 && data[0].length === 0 ? [] : JSON.parse(data.d));
                            }
                            // remove loading spinner image.                                
                            $("#<%=txtSearch.ClientID%>").removeClass("ui-autocomplete-loading");
                        }
                    });
                },
                minLength: 2,
                select: function (event, ui) {
                    $("#<%=btnSearch.ClientID%>").val(ui.item.value);
                    //TriggerSearch();
                    $('#<%=btnSearch.ClientID%>').click();
                }
            });
        }

        function SetUserAutoSuggestionUI() {

            $.widget("custom.catcomplete", $.ui.autocomplete, {
                _create: function () {
                    this._super();
                    this.widget().menu("option", "items", "> :not(.ui-autocomplete-category)");
                },
                _renderMenu: function (ul, items) {
                    var that = this,
                      currentCategory = "";
                    $.each(items, function (index, item) {
                        var li;
                        if (item.Category != currentCategory) {
                            ul.append("<li class='ui-autocomplete-category'> Search " + item.Category + "</li>");
                            currentCategory = item.Category;
                        }
                        li = that._renderItemData(ul, item);
                        if (item.Category) {
                            li.attr("aria-label", item.Category + " : " + item.label);
                        }
                    });

                }
            });
        }

        function SetApprovalUI() {

            $('.approvalBoxes').each(function () {
                var approvaldialog = $($(this).next('.approvepopup'));
                approvaldialog.dialog({
                    width: 400,
                    show: 'slide',
                    hide: 'slide',
                    autoOpen: false
                });

                $(this).click(function () {
                    approvaldialog.dialog('open');
                });
            });
        }

        function ucSubTasks_Initialize() {

            SubTaskCommentScript.Initialize();

            ChosenDropDown();

            // Choosen selected option with hyperlink to profile.
            setSelectedUsersLink();

            ApplySubtaskLinkContextMenu();
            //ApplyImageGallery();

            LoadImageGallery('.sub-task-attachments-list');

            //----------- start DP -----
            GridDropZone();
            //----------- end DP -----

            SetApprovalUI();

            var controlmode = $('#<%=hdnAdminMode.ClientID%>').val().toLowerCase();

            if (controlmode == "true") {
                ucSubTasks_ApplyDropZone();
                SetCKEditor('<%=txtSubTaskDescription.ClientID%>', txtSubTaskDescription_Blur);
                UpdateTaskDescBeforeSubmit('<%=txtSubTaskDescription.ClientID%>', '#<%=btnSaveSubTask.ClientID%>');


                SetCKEditor('<%=txtTaskDesc.ClientID%>', txtTaskDesc_Blur);
                UpdateTaskDescBeforeSubmit('<%=txtTaskDesc.ClientID%>', '#<%=btnAddMoreSubtask.ClientID%>');


                $('#<%=txtInstallId.ClientID%>').bind('keypress', function (e) {
                    return false;
                });

                $('#<%=txtInstallId.ClientID%>').bind('keydown', function (e) {
                    if (e.keyCode === 8 || e.which === 8) {
                        return false;
                    }
                });

            }

            pageLoad(null, null);
        }

        function txtSubTaskDescription_Blur(editor) {
            if ($('#<%=hdnSubTaskId.ClientID%>').val() != '0') {
                if (Page_ClientValidate('vgSubTask') && confirm('Do you wish to save description?')) {
                    $('#<%=btnSaveSubTask.ClientID%>').click();
                }
            }
        }

        function OnSaveSubTaskClick() {
            if (Page_ClientValidate('vgSubTask')) {
                ShowAjaxLoader();
                var taskid = '';
                if (maintask) {
                    taskid = GetParameterValues('TaskId');
                }
                else {
                    taskid = $('#<%=hdParentTaskId.ClientID%>').val();
                }

                var title = $('#<%= txtSubTaskTitle.ClientID %>').val();
                var url = $('#<%= txtUrl.ClientID %>').val();
                var desc = GetCKEditorContent('<%= txtSubTaskDescription.ClientID %>');
                var status = "<%=Convert.ToByte(JG_Prospect.Common.JGConstant.TaskStatus.Open)%>";
                var Priority = $('#<%= ddlSubTaskPriority.ClientID %>').val();
                var DueDate = ''; //$('#<%= txtSubTaskDueDate.ClientID %>').val();
                var tHours = ''; //$('#<%= txtSubTaskHours.ClientID %>').val();
                var installID = $('#<%= txtTaskListID.ClientID %>').val();
                var Attachments = ''; //$('#<%= hdnAttachments.ClientID %>').val();
                var type = $('#<%= ddlTaskType.ClientID %>').val();
                var designaions = $('#<%= hdndesignations.ClientID %>').val();
                var TaskLvl = $('#<%= hdTaskLvl.ClientID %>').val();
                var blTechTask = $('#<%=chkTechTask.ClientID%>').prop('checked');

                var postData = {
                    ParentTaskId: taskid,
                    Title: title,
                    URL: url,
                    Desc: desc,
                    Status: status,
                    Priority: Priority,
                    DueDate: DueDate,
                    TaskHours: tHours,
                    InstallID: installID,
                    Attachments: Attachments,
                    TaskType: type,
                    TaskDesignations: designaions,
                    TaskLvl: TaskLvl,
                    blTechTask: blTechTask
                };

                CallJGWebService('AddNewSubTask', postData, OnAddNewSubTaskSuccess, OnAddNewSubTaskError);

                function OnAddNewSubTaskSuccess(data) {
                    if (data.d.Success) {
                        alert('Task saved successfully.');
                        $('#<%=hdTaskId.ClientID%>').val(data.d.TaskId.toString());
                        $('#<%=btnUpdateRepeater.ClientID%>').click();
                    }
                    else {
                        alert('Task cannot be saved. Please try again.');
                    }
                }

                function OnAddNewSubTaskError(err) {
                    alert('Task cannot be saved. Please try again.');
                }
                return false;
            }
        }
        function GetParameterValues(param) {
            var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for (var i = 0; i < url.length; i++) {
                var urlparam = url[i].split('=');
                if (urlparam[0] == param) {
                    return urlparam[1];
                }
            }
        }

        function copytoListID(sender) {
            var strListID = $.trim($(sender).text());
            if (strListID.length > 0) {
                $('#<%= txtTaskListID.ClientID %>').val(strListID);
                ValidatorEnable(document.getElementById('<%=rfvTitle.ClientID%>'), true)
                ValidatorEnable(document.getElementById('<%=rfvUrl.ClientID%>'), true)
            }
        }

        var objSubTaskDropzone, objSubtaskNoteDropzone;

        function ucSubTasks_ApplyDropZone() {
            //remove already attached dropzone.
            if (objSubTaskDropzone) {
                objSubTaskDropzone.destroy();
                objSubTaskDropzone = null;
            }
            if ($("#<%=divSubTaskDropzone.ClientID%>").length > 0) {
                objSubTaskDropzone = new Dropzone("#<%=divSubTaskDropzone.ClientID%>", {
                    maxFiles: 5,
                    url: "taskattachmentupload.aspx",
                    thumbnailWidth: 90,
                    thumbnailHeight: 90,
                    previewsContainer: 'div#<%=divSubTaskDropzonePreview.ClientID%>',
                    init: function () {
                        this.on("maxfilesexceeded", function (data) {
                            alert('you are reached maximum attachment upload limit.');
                        });

                        // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                        this.on("success", function (file, response) {
                            var filename = response.split("^");
                            $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                            AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnAttachments.ClientID %>');

                            if ($('#<%=btnSaveSubTaskAttachment.ClientID%>').length > 0) {
                                // saves attachment.
                                $('#<%=btnSaveSubTaskAttachment.ClientID%>').click();
                                   //this.removeFile(file);
                               }
                        });
                    }
                });
               }

            //Apply dropzone for comment section.
               if (objSubtaskNoteDropzone) {
                   objSubtaskNoteDropzone.destroy();
                   objSubTaskNoteDropzone = null;
               }

               objSubTaskNoteDropzone = GetWorkFileDropzone("#<%=divSubTaskNoteDropzone.ClientID%>", '#<%=divSubTaskNoteDropzonePreview.ClientID%>', '#<%= hdnSubTaskNoteAttachments.ClientID %>', '#<%=btnSaveCommentAttachment.ClientID%>');
    }

    function ucSubTasks_OnApprovalCheckBoxChanged(sender) {
        var sender = $(sender);
        if (sender.prop('checked')) {
            sender.closest('tr').next('tr').show();
        }
        else {
            sender.closest('tr').next('tr').hide();
        }
    }

    function ApplySubtaskLinkContextMenu() {

        $(".context-menu").bind("contextmenu", function () {
            var urltoCopy = updateQueryStringParameter(window.location.href, "hstid", $(this).attr('data-highlighter'));
            copyToClipboard(urltoCopy);
            return false;
        });

        ScrollTo($(".yellowthickborder"));

        $(".yellowthickborder").bind("click", function () {
            $(this).removeClass("yellowthickborder");
        });
    }

    // check if user has selected any designations or not.
    function SubTasks_checkDesignations(oSrc, args) {
        //args.IsValid = ($("# input:checked").length > 0);
    }


    //  Created By : Yogesh K
    // To updat element underlying CKEditor before work submited to server.
    function UpdateTaskDescBeforeSubmit(CKEditorId, ButtonId) {
        $(ButtonId).bind('click', function () {
            var editor = CKEDITOR.instances[CKEditorId];

            if (editor) {
                editor.updateElement();
            }
        });
    }


    //----------- Start DP ---------

    function SetHiddenTaskId(vId) {
        $('#<%=hdDropZoneTaskId.ClientID%>').val(vId);
           }


           $('#<%=pnlCalendar.ClientID%>').hide();
  <%--  $('#<%=divSubTask.ClientID%>').hide();--%>

    function txtTaskDesc_Blur(editor) {
        //if ($('#<%=hdnSubTaskId.ClientID%>').val() != '0') {
        <%--if (confirm('Do you wish to save description?')) {
            $('#<%=btnAddMoreSubtask.ClientID%>').click();
        }--%>
        // }
    }

    function showSubTaskEditView(divid, rowindex) {

        var html = $('<tr>').append($('<td colspan="5">').append($(divid)));

        $('.edit-subtask > tbody > tr').eq(rowindex + 1).after(html);

        $(divid).slideDown('slow');

        ScrollTo($(divid));
    }
    function hideSubTaskEditView(divid, rowindex) {

        //$('#<%=hdnCurrentEditingRow.ClientID%>').val('');
        // $('.edit-subtask > tbody > tr').eq(rowindex + 2).remove();
        // $(divid).slideUp('slow');
        $('#<%=pnlCalendar.ClientID%>').hide();
        var row = $('.edit-subtask').find('tr').eq(rowindex + 2);

        //alert(row);

        ScrollTo(row);
    }


    function attachImagesByCKEditor(filename, name) {
        AddAttachmenttoViewState(name + '@' + name, '#<%= hdnGridAttachment.ClientID %>');
        idAttachments = true;
    }

    function GridDropZone() {
        Dropzone.autoDiscover = false;

        $(".dropzonetask").each(function () {
            // debugger;
            var objSubTaskDropzone1;
            var taskId = $(this).attr('data-taskid');
            //alert(taskId);
            $(this).dropzone({
                maxFiles: 5,
                url: "taskattachmentupload.aspx",
                thumbnailWidth: 90,
                thumbnailHeight: 90,
                init: function () {
                    dzClosure = this;

                    this.on("maxfilesexceeded", function (data) {
                        alert('you are reached maximum attachment upload limit.');
                    });

                    this.on("drop", function (data) {
                        //alert(taskId);
                        $('#<%=hdDropZoneTaskId.ClientID%>').val(taskId);
                    });

                    // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                    this.on("success", function (file, response) {
                        // Success coding goes here

                        var filename = response.split("^");
                        $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                        AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnGridAttachment.ClientID %>');

                        if ($('#<%=btnSaveGridAttachment.ClientID%>').length > 0) {
                            // saves attachment.
                            $('#<%=btnSaveGridAttachment.ClientID%>').click();
                            //this.removeFile(file);
                        }
                    });
                }
            });
        });
    }
    function setSelectedUsersLink() {

        $('.search-choice').each(function () {
            var itemIndex = $(this).children('.search-choice-close').attr('data-option-array-index');
            console.log(itemIndex);
            if (itemIndex) {
                //console.log($(this).parent('.chosen-choices').parent('.chosen-container'));
                var selectoptionid = '#' + $(this).parent('.chosen-choices').parent('.chosen-container').attr('id').replace("_chosen","") + ' option';
                
                 console.log($(selectoptionid)[itemIndex].value);
                 var chspan = $(this).children('span');
                 if (chspan) {
                     chspan.html('<a style="color:blue;" href="/Sr_App/ViewSalesUser.aspx?id=' + $(selectoptionid)[itemIndex].value + '">' + chspan.text() + '</a>');
                    chspan.bind("click", "a", function () {
                         window.open($(this).children("a").attr("href"), "_blank", "", false);
                     });
                 }
            }
        });
    }
    //--------------- End DP ---------------

</script>
