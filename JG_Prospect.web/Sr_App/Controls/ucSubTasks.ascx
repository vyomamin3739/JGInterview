<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucSubTasks.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.ucSubTasks" %>

<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>

<link rel="stylesheet" type="text/css" href="../css/lightslider.css">
<script type="text/javascript" src="../js/lightslider.js"></script>
<fieldset class="tasklistfieldset">
    <legend>Task List</legend>
    <asp:UpdatePanel ID="upSubTasks" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="divSubTaskGrid">
                <asp:GridView ID="gvSubTasks" runat="server" ShowHeaderWhenEmpty="true" AllowSorting="true" EmptyDataRowStyle-HorizontalAlign="Center"
                    HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                    EmptyDataText="No sub task available!" CssClass="table edit-subtask" Width="100%" CellSpacing="0" CellPadding="0"
                    AutoGenerateColumns="False" EnableSorting="true" GridLines="Vertical" DataKeyNames="TaskId,InstallId"
                    OnRowDataBound="gvSubTasks_RowDataBound"
                    OnRowCommand="gvSubTasks_RowCommand"
                    OnSorting="gvSubTasks_Sorting">
                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle CssClass="trHeader " />
                    <RowStyle CssClass="FirstRow" />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <Columns>
                        <asp:TemplateField HeaderText="List ID" HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="60"
                            SortExpression="InstallId">
                            <ItemTemplate>
                                <asp:Literal ID="ltrlInstallId" runat="server" Text='<%# Eval("InstallId") %>' />
                                <h5>
                                    <asp:LinkButton ID="lbtnInstallId" CssClass="context-menu" data-highlighter='<%# Eval("TaskId")%>' ForeColor="Blue" runat="server" Text='<%# Eval("InstallId") %>' CommandName="edit-sub-task"
                                        CommandArgument='<%# Container.DataItemIndex  %>' /></h5>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Task Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Left"
                            SortExpression="Description">
                            <ItemTemplate>
                                <div style="background-color: white; border-bottom: 1px solid silver; padding: 3px; max-width: 400px;">
                                    <div style="padding-bottom: 5px;">
                                        <h5>Title:&nbsp;<%# String.IsNullOrEmpty(Eval("Title").ToString())== true ? "N.A." : Eval("Title").ToString() %></h5>
                                    </div>
                                    <div style="padding-bottom: 5px;">
                                        <h5>Url:&nbsp;<a target="_blank" class="bluetext"
                                            href='<%# string.IsNullOrEmpty(Eval("Url").ToString()) == true ? 
                                                                        "javascript:void(0);" : 
                                                                        Eval("Url").ToString()%>'>
                                            <%# String.IsNullOrEmpty(Eval("Url").ToString())== true ? 
                                                                "N.A." : 
                                                                Eval("Url").ToString()%> 
                                        </a>
                                        </h5>
                                    </div>
                                    <div style="padding-bottom: 5px;">
                                        <h5>Description:&nbsp;</h5>
                                        <%# Eval("Description")%>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--<asp:TemplateField HeaderText="Task Details" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="105"
                            SortExpression="Status">
                            <ItemTemplate>
                                <div style="padding: 3px;">
                                    <table>
                                        <tr>
                                            <td class="noborder">
                                                <h5>Status</h5>
                                            </td>

                                        </tr>
                                        <tr>
                                            <td class="noborder">
                                                <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlStatus_SelectedIndexChanged" /></td>
                                        </tr>
                                    </table>
                                    <hr />
                                    <table>
                                        <tr>
                                            <td class="noborder">
                                                <h5>Priority</h5>
                                            </td>
                                            <td class="noborder">
                                                <h5>Type</h5>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="noborder">
                                                <asp:DropDownList ID="ddlTaskPriority" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlTaskPriority_SelectedIndexChanged" /></td>
                                            <td class="noborder">
                                                <asp:Literal ID="ltrlTaskType" runat="server" Text="N.A." /></td>
                                        </tr>
                                    </table>
                                    <hr />
                                    <table>
                                        <tr>
                                            <td class="noborder" colspan="2">
                                                <h5>Estimated Hours</h5>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="noborder">ITLead
                                            </td>
                                            <td class="noborder">
                                                <%# this.IsAdminMode ? (String.IsNullOrEmpty(Eval("AdminOrITLeadEstimatedHours").ToString())== true? "N.A." : Eval("AdminOrITLeadEstimatedHours").ToString() +" Hour(s)" ): "" %>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="noborder">User</td>
                                            <td class="noborder"><%# (String.IsNullOrEmpty(Eval("UserEstimatedHours").ToString())==true? "N.A." : Eval("UserEstimatedHours").ToString() + " Hour(s)") %></td>
                                        </tr>
                                    </table>
                                    <hr />
                                    <table>
                                        <tr>
                                            <td colspan="3" class="noborder">
                                                <h5>Freeze Task</h5>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="redtext haligncenter noborder">
                                                <b>Admin</b>
                                            </td>
                                            <td class="noborder">
                                                <b>Tech Lead</b>
                                            </td>
                                            <td class="bluetext haligncenter noborder">
                                                <b>User</b>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="haligncenter noborder">
                                                <asp:CheckBox ID="chkAdmin" runat="server" CssClass="fz fz-admin" ToolTip="Admin" /></td>
                                            <td class="haligncenter noborder">
                                                <asp:CheckBox ID="chkITLead" runat="server" CssClass="fz fz-techlead" ToolTip="IT Lead" /></td>
                                            <td class="haligncenter noborder">
                                                <asp:CheckBox ID="chkUser" runat="server" CssClass="fz fz-user" ToolTip="User" /></td>
                                        </tr>
                                        <tr style="display: none;">
                                            <td colspan="3">

                                                <asp:HiddenField ID="hdnTaskApprovalId" runat="server" Value='<%# Eval("TaskApprovalId") %>' />
                                                <asp:TextBox ID="txtEstimatedHours" runat="server" data-id="txtEstimatedHours" CssClass="textbox" Width="110"
                                                    placeholder="Estimate" Text='<%# Eval("TaskApprovalEstimatedHours") %>' />
                                                <asp:TextBox ID="txtPasswordToFreezeSubTask" runat="server" TextMode="Password" data-id="txtPasswordToFreezeSubTask"
                                                    AutoPostBack="true" CssClass="textbox" Width="110" OnTextChanged="gvSubTasks_txtPasswordToFreezeSubTask_TextChanged" />


                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" class="noborder" align="center">
                                                <asp:LinkButton ID="lbtlFeedback" runat="server" Text="Comment" CommandName="sub-task-feedback"
                                                    CommandArgument='<%# Container.DataItemIndex  %>' /></td>
                                        </tr>
                                    </table>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                        <%-- <asp:TemplateField HeaderText="Estimated hours" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="88">
                            <ItemTemplate>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                        <asp:TemplateField HeaderText="Assigned" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <table>
                                    <tr>
                                        <td class="noborder">
                                            <h5>Priority</h5>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <asp:DropDownList ID="ddlTaskPriority" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlTaskPriority_SelectedIndexChanged" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <h5>Assigned</h5>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <%--<asp:DropDownCheckBoxes ID="ddcbAssigned" runat="server" UseSelectAllNode="false"
                                                AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddcbAssigned_SelectedIndexChanged">
                                                <Style SelectBoxWidth="100" DropDownBoxBoxWidth="100" DropDownBoxBoxHeight="150" />
                                                <Texts SelectBoxCaption="--Open--" />
                                            </asp:DropDownCheckBoxes>--%>
                                            <asp:ListBox ID="ddcbAssigned" runat="server" Width="150" SelectionMode="Multiple"
                                                CssClass="chosen-select" data-placeholder="Select"
                                                AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddcbAssigned_SelectedIndexChanged"></asp:ListBox>
                                            <asp:Label ID="lblAssigned" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <h5>Status</h5>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlStatus_SelectedIndexChanged" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <h5>Type</h5>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="noborder">
                                            <asp:Literal ID="ltrlTaskType" runat="server" Text="N.A." /></td>
                                    </tr>

                                </table>
                                <table>
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

                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Attachments" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left"
                            ItemStyle-VerticalAlign="Top" ItemStyle-Width="20%">
                            <ItemTemplate>
                                <asp:Repeater ID="rptAttachment" OnItemCommand="rptAttachment_ItemCommand" OnItemDataBound="rptAttachment_ItemDataBound" runat="server">
                                    <HeaderTemplate>
                                        <div class="lSSlideOuter sub-task-attachments" style="max-width: 250px;">
                                            <div class="lSSlideWrapper usingCss">
                                                <ul class="gallery list-unstyled cS-hidden sub-task-attachments-list">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <li id="liImage" runat="server" class="noborder" style="overflow: inherit !important;">

                                            <img id="imgIcon" class="gallery-ele" style="width: 100% !important;" runat="server" src="javascript:void(0);" />
                                            <br />
                                            <h5>
                                                <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue" CommandName="DownloadFile" /></h5>
                                            <h5>
                                                <asp:Literal ID="ltlUpdateTime" runat="server"></asp:Literal></h5>
                                            <h5>
                                                <asp:Literal ID="ltlCreatedUser" runat="server"></asp:Literal></h5>
                                            <div>
                                                <asp:LinkButton ID="lbtnDelete" runat="server" ClientIDMode="AutoID" ForeColor="Blue" Text="Delete"
                                                    CommandName="delete-attachment" />
                                            </div>
                                        </li>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </ul>
                                            </div>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                                <asp:CheckBox ID="chkUiRequested" runat="server" Text="Ui Requested?" Checked='<%# Convert.ToBoolean(Eval("IsUiRequested")) %>' AutoPostBack="true" OnCheckedChanged="gvSubTasks_chkUiRequested_CheckedChanged" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="88">
                            <ItemTemplate>
                                <table>
                                    <tr>
                                        <td colspan="3" class="noborder" align="center">
                                            <asp:LinkButton ID="lbtlFeedback" runat="server" Text="Comment" CommandName="sub-task-feedback"
                                                CommandArgument='<%# Container.DataItemIndex  %>' /></td>
                                    </tr>
                                    <tr>
                                        <td class="haligncenter noborder">
                                            <asp:CheckBox ID="chkAdmin" runat="server" CssClass="fz fz-admin" ToolTip="Admin" />
                                            <div id="divAdmin" runat="server" visible="false">
                                                <asp:HyperLink ForeColor="Red" runat="server" NavigateUrl='<%# Eval("AdminUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                    <%# 
                                                        string.Concat(
                                                                        string.IsNullOrEmpty(Eval("AdminUserInstallId").ToString())?
                                                                            Eval("AdminUserId") : 
                                                                            Eval("AdminUserInstallId"),
                                                                        "<br/>",
                                                                        string.IsNullOrEmpty(Eval("AdminUserFirstName").ToString())== true? 
                                                                            Eval("AdminUserFirstName").ToString() : 
                                                                            Eval("AdminUserFirstName").ToString(),
                                                                        " ", 
                                                                        Eval("AdminUserLastName").ToString()
                                                                    )
                                                    %>
                                                </asp:HyperLink>
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("AdminStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("AdminStatusUpdated"))%></span>&nbsp<span>(EST)</span>
                                            </div>
                                        </td>
                                        <td class="haligncenter noborder">
                                            <asp:CheckBox ID="chkITLead" runat="server" CssClass="fz fz-techlead" ToolTip="IT Lead" />
                                            <div id="divITLead" runat="server" visible="false">
                                                <asp:HyperLink ForeColor="Black" runat="server" NavigateUrl='<%# Eval("TechLeadUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                    <%# 
                                                        string.Concat(
                                                                        string.IsNullOrEmpty(Eval("TechLeadUserInstallId").ToString())?
                                                                            Eval("TechLeadUserId") : 
                                                                            Eval("TechLeadUserInstallId"),
                                                                        "<br/>",
                                                                        string.IsNullOrEmpty(Eval("TechLeadUserFirstName").ToString())== true? 
                                                                            Eval("TechLeadUserFirstName").ToString() : 
                                                                            Eval("TechLeadUserFirstName").ToString(),
                                                                        " ", 
                                                                        Eval("TechLeadUserLastName").ToString()
                                                                    )
                                                    %>
                                                </asp:HyperLink>
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("TechLeadStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("TechLeadStatusUpdated"))%></span>&nbsp<span>(EST)</span>
                                            </div>
                                        </td>
                                        <td class="haligncenter noborder">
                                            <asp:CheckBox ID="chkUser" runat="server" CssClass="fz fz-user" ToolTip="User" />
                                            <div id="divUser" runat="server" visible="false">
                                                <asp:HyperLink ForeColor="Blue" runat="server" NavigateUrl='<%# Eval("TechLeadUserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                    <%# 
                                                        string.Concat(
                                                                        string.IsNullOrEmpty(Eval("OtherUserInstallId").ToString())?
                                                                            Eval("OtherUserId") : 
                                                                            Eval("OtherUserInstallId"),
                                                                        "<br/>",
                                                                        string.IsNullOrEmpty(Eval("OtherUserFirstName").ToString())== true? 
                                                                            Eval("OtherUserFirstName").ToString() : 
                                                                            Eval("OtherUserFirstName").ToString(),
                                                                        " ", 
                                                                        Eval("OtherUserLastName").ToString()
                                                                    )
                                                    %>
                                                </asp:HyperLink>
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("OtherUserStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("OtherUserStatusUpdated"))%></span>&nbsp<span>(EST)</span>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr style="display: none;">
                                        <td colspan="3">
                                            <asp:HiddenField ID="hdnTaskApprovalId" runat="server" Value='<%# Eval("TaskApprovalId") %>' />
                                            <asp:TextBox ID="txtEstimatedHours" runat="server" data-id="txtEstimatedHours" CssClass="textbox" Width="110"
                                                placeholder="Estimate" Text='<%# Eval("TaskApprovalEstimatedHours") %>' />
                                            <asp:TextBox ID="txtPasswordToFreezeSubTask" runat="server" TextMode="Password" data-id="txtPasswordToFreezeSubTask"
                                                AutoPostBack="true" CssClass="textbox" Width="110" OnTextChanged="gvSubTasks_txtPasswordToFreezeSubTask_TextChanged" />
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <br />
    <asp:UpdatePanel ID="upAddSubTask" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="divAddSubTask" runat="server">
                <asp:LinkButton ID="lbtnAddNewSubTask" runat="server" Text="Add New Task" ValidationGroup="Submit" OnClick="lbtnAddNewSubTask_Click" />
                <br />
                <asp:ValidationSummary ID="vsSubTask" runat="server" ValidationGroup="vgSubTask" ShowSummary="False" ShowMessageBox="True" />
                <div id="divSubTask" runat="server" class="tasklistfieldset" style="display: none;">
                    <asp:HiddenField ID="hdnTaskApprovalId" runat="server" Value="0" />
                    <asp:HiddenField ID="hdnSubTaskId" runat="server" Value="0" />
                    <asp:HiddenField ID="hdnSubTaskIndex" runat="server" Value="-1" />
                    <table class="tablealign fullwidth">
                        <tr>
                            <td>ListID:
                                <asp:TextBox ID="txtTaskListID" runat="server" Enabled="false" />
                                &nbsp;
                                <small>
                                    <a href="javascript:void(0);" style="color: #06c;" onclick="copytoListID(this);">
                                        <asp:Literal ID="listIDOpt" runat="server" />
                                    </a>
                                </small>
                            </td>
                            <td>Type:
                                <asp:DropDownList ID="ddlTaskType" runat="server" />
                                &nbsp;&nbsp;Priority:
                                <asp:DropDownList ID="ddlSubTaskPriority" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>Title <span style="color: red;"></span>:
                                <br />
                                <asp:TextBox ID="txtSubTaskTitle" Text="" runat="server" Width="98%" CssClass="textbox" TextMode="SingleLine" />
                                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" Display="None" ValidationGroup="vgSubTask"
                                    ControlToValidate="txtSubTaskTitle" ErrorMessage="Please enter Task Title." />
                            </td>
                            <td>Url <span style="color: red;"></span>:
                                <br />
                                <asp:TextBox ID="txtUrl" Text="" runat="server" Width="98%" CssClass="textbox" />
                                <asp:RequiredFieldValidator ID="rfvUrl" runat="server" Display="None" ValidationGroup="vgSubTask"
                                    ControlToValidate="txtUrl" ErrorMessage="Please enter Task Url." />
                            </td>
                        </tr>
                        <tr runat="server" visible="false">
                            <td>
                                <asp:UpdatePanel ID="upnlDesignation" runat="server" RenderMode="Inline">
                                    <ContentTemplate>
                                        Designation <span style="color: red;">*</span>:
                                        <asp:DropDownCheckBoxes ID="ddlUserDesignation" runat="server" UseSelectAllNode="false"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlUserDesignation_SelectedIndexChanged">
                                            <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                        </asp:DropDownCheckBoxes>
                                        <asp:CustomValidator ID="cvDesignations" runat="server" ValidationGroup="vgSubTask" ErrorMessage="Please Select Designation" Display="None"
                                            ClientValidationFunction="SubTasks_checkDesignations"></asp:CustomValidator>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">Attachment(s):
                                <div style="max-height: 300px; clear: both; background-color: white; overflow-y: auto; overflow-x: hidden;">
                                    <asp:UpdatePanel ID="upnlAttachments" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:Repeater ID="rptSubTaskAttachments" runat="server"
                                                OnItemDataBound="rptSubTaskAttachments_ItemDataBound"
                                                OnItemCommand="rptSubTaskAttachments_ItemCommand">
                                                <HeaderTemplate>
                                                    <ul style="width: 100%; list-style-type: none; margin: 0px; padding: 0px;">
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <li style="margin: 10px; text-align: center; float: left; width: 100px;">
                                                        <asp:LinkButton ID="lbtnDelete" runat="server" ClientIDMode="AutoID" ForeColor="Blue" Text="Delete" CommandArgument='<%#Eval("Id").ToString()+ "|" + Eval("attachment").ToString() %>' CommandName="delete-attachment" />
                                                        <br />
                                                        <img id="imgIcon" class="gallery-ele" runat="server" height="100" width="100" src="javascript:void(0);" />
                                                        <br />
                                                        <small>
                                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue" CommandName="download-attachment" />
                                                            <br />
                                                            <small><%# Convert.ToDateTime(Eval("UpdatedOn")).ToString("MM/dd/yyyy hh:mm tt") %></small>
                                                        </small>
                                                    </li>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    </ul>
                                                                       
                                                </FooterTemplate>
                                            </asp:Repeater>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
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
                        <tr>
                            <td>Attachment(s):<br>
                                <asp:UpdatePanel ID="upAttachmentsData" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <input id="hdnAttachments" runat="server" type="hidden" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
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
                        <tr>
                            <td colspan="2">Estimated Hours:
                                <asp:TextBox ID="txtEstimatedHours" runat="server" CssClass="textbox" Width="110" placeholder="Estimate" />
                                <asp:RegularExpressionValidator ID="revEstimatedHours" runat="server" ControlToValidate="txtEstimatedHours" Display="None"
                                    ErrorMessage="Please enter decimal numbers for estimated hours of task." ValidationGroup="vgSubTask"
                                    ValidationExpression="(\d+\.\d{1,2})?\d*" />
                            </td>
                        </tr>
                        <tr id="trDateHours">
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
                                    <asp:Button ID="btnSaveSubTask" runat="server" Text="Save Sub Task" CssClass="ui-button" ValidationGroup="vgSubTask"
                                        OnClientClick="javascript:return OnSaveSubTaskClick();" OnClick="btnSaveSubTask_Click" />
                                    <asp:HiddenField ID="hdnCurrentEditingRow" runat="server" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
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


<%--Popup Ends--%>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/chosen.jquery.js")%>"></script>

<script type="text/javascript">
    Dropzone.autoDiscover = false;

    $(function () {
        ucSubTasks_Initialize();
    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {
        console.log('end req.');
        ucSubTasks_Initialize();
    });

    prmTaskGenerator.add_beginRequest(function () {
        console.log('begin req.');
        DestroyGallery();
        DestroyDropzones();
        DestroyCKEditors();
    });

    function ucSubTasks_Initialize() {

        ChosenDropDown();

        ApplySubtaskLinkContextMenu();
        //ApplyImageGallery();

        LoadImageGallery('.sub-task-attachments-list');

        var controlmode = $('#<%=hdnAdminMode.ClientID%>').val().toLowerCase();

        // alert(controlmode);

        if (controlmode == "true") {
            ucSubTasks_ApplyDropZone();
            SetCKEditor('<%=txtSubTaskDescription.ClientID%>', txtSubTaskDescription_Blur);
        }

        implementTaskPriorityRule();

    }


    function implementTaskPriorityRule() {
        $('#trDateHours').hide();

        $('#<%=ddlTaskType.ClientID%>').change(function () {
            var type = $(this).val();
            if (type == "3") {
                $('#trDateHours').show();
            }
            else {
                $('#trDateHours').hide();
            }
        });
    }

    function txtSubTaskDescription_Blur(editor) {
        <%--if ($('#<%=hdnSubTaskId.ClientID%>').val() != '0') {
            if (Page_ClientValidate('vgSubTask') && confirm('Do you wish to save description?')) {
                $('#<%=btnSaveSubTask.ClientID%>').click();
            }
        }--%>
    }

    function OnSaveSubTaskClick() {
        return Page_ClientValidate('vgSubTask');
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

        if ($(".yellowthickborder").length > 0) {
            $('html, body').animate({
                scrollTop: $(".yellowthickborder").offset().top
            }, 2000);
        }

        $(".yellowthickborder").bind("click", function () {
            $(this).removeClass("yellowthickborder");
        });
    }

    // check if user has selected any designations or not.
    function SubTasks_checkDesignations(oSrc, args) {
        args.IsValid = ($("#<%= ddlUserDesignation.ClientID%> input:checked").length > 0);
    }

    function showSubTaskEditView(divid, rowindex) {

        var html = $('<tr>').append($('<td colspan="5">').append($(divid)));

        $('.edit-subtask > tbody > tr').eq(rowindex + 1).after(html);

        $(divid).slideDown('slow');

        $('html, body').animate({
            scrollTop: $(divid).offset().top - 100
        }, 2000);


    }
    function hideSubTaskEditView(divid, rowindex) {

        $('#<%=hdnCurrentEditingRow.ClientID%>').val('');
       // $('.edit-subtask > tbody > tr').eq(rowindex + 2).remove();
        // $(divid).slideUp('slow');
        
        var row = $('.edit-subtask').find('tr').eq(rowindex + 2);

        //alert(row);

        if (row.length) {
            $('html, body').animate({
                scrollTop: row.offset().top - 100
            }, 2000);

        }
        

    }

    function ShowAddNewSubTaskSection(divid) {
       
        $(divid).slideDown('slow');

        $('html, body').animate({
            scrollTop: $(divid).offset().top - 200
        }, 2000);

    }
    
</script>
