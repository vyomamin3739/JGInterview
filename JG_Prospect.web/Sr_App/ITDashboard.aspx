<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="ITDashboard.aspx.cs" Inherits="JG_Prospect.Sr_App.ITDashboard" %>

<%@ Register Src="~/Sr_App/LeftPanel.ascx" TagName="LeftPanel" TagPrefix="uc2" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .clsTestMail {
            padding: 20px;
            font-size: 14px;
        }

            .clsTestMail input[type='text'] {
                padding: 5px;
            }

            .clsTestMail input[type='submit'] {
                background: #000;
                color: #fff;
                padding: 5px 7px;
                border: 1px solid #808080;
            }

                .clsTestMail input[type='submit']:hover {
                    background: #fff;
                    color: #000;
                    cursor: pointer;
                }

        .table tr {
            border: solid 1px #fff;
        }

        .modalBackground {
            background-color: #333333;
            filter: alpha(opacity=70);
            opacity: 0.7;
            z-index: 100 !important;
        }

        .modalPopup {
            background-color: #FFFFFF;
            border-width: 1px;
            border-style: solid;
            border-color: #CCCCCC;
            padding: 1px;
            width: 900px;
            Height: 550px;
            overflow-y: auto;
        }

        .badge1 {
            padding: 1px 5px 2px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
            color: #ffffff;
            background-color: #e55456;
            -webkit-border-radius: 9px;
            -moz-border-radius: 9px;
            border-radius: 8px;
            display: inline;
        }

        .ui-autocomplete {
            z-index: 999999999 !important;
            max-height: 250px;
            overflow-y: auto;
            overflow-x: hidden;
        }

        .pagination-ys {
            padding-left: 0;
            margin: 5px 0;
            border-radius: 4px;
            align-content: flex-end;
            line-height: none !important;
        }

            .pagination-ys td {
                border: none !important;
            }

            .pagination-ys table > tbody {
                height: unset !important;
            }

                .pagination-ys table > tbody > tr > td {
                    display: inline !important;
                    background: none;
                    border: none !important;
                }

                    .pagination-ys table > tbody > tr > td > a,
                    .pagination-ys table > tbody > tr > td > span {
                        position: relative;
                        float: left;
                        padding: 8px 12px;
                        line-height: 1.42857143;
                        text-decoration: none;
                        color: #dd4814;
                        background-color: #ffffff;
                        border: 1px solid #dddddd;
                        margin-left: -1px;
                    }

                    .pagination-ys table > tbody > tr > td > span {
                        position: relative;
                        float: left;
                        padding: 8px 12px;
                        line-height: 1.42857143;
                        text-decoration: none;
                        margin-left: -1px;
                        z-index: 2;
                        color: #aea79f;
                        background-color: #f5f5f5;
                        border-color: #dddddd;
                        cursor: default;
                    }

                    .pagination-ys table > tbody > tr > td:first-child > a,
                    .pagination-ys table > tbody > tr > td:first-child > span {
                        margin-left: 0;
                        border-bottom-left-radius: 4px;
                        border-top-left-radius: 4px;
                    }

                    .pagination-ys table > tbody > tr > td:last-child > a,
                    .pagination-ys table > tbody > tr > td:last-child > span {
                        border-bottom-right-radius: 4px;
                        border-top-right-radius: 4px;
                    }

                    .pagination-ys table > tbody > tr > td > a:hover,
                    .pagination-ys table > tbody > tr > td > span:hover,
                    .pagination-ys table > tbody > tr > td > a:focus,
                    .pagination-ys table > tbody > tr > td > span:focus {
                        color: #97310e;
                        background-color: #eeeeee;
                        border-color: #dddddd;
                    }

        /*.dashboard tr {
        display: flex;
    }

   .pagination-ys td {
        border-spacing: 0px !important;
        flex: 1 auto;
        word-wrap: break-word;
        background: none !important;
        line-height: none !important;
    }

    .dashboard thead tr:after {
        content:'';
        overflow-y: scroll;
        visibility: hidden;
        height: 0;
    }
 
    .dashboard thead th {
        flex: 1 auto;
        display: block;
        background-color: #000 !important;
    }

    .dashboard tbody {
        display: block;
        width: 100%;
        overflow-y: auto;
        height: 370px;
    }*/

        table.table tr.trHeader {
            background: none !important;
        }

        table.table th {
            border: none;
        }

        .dashboard tr {
            display: flex;
        }

        .dashboard td {
            border-spacing: 0px !important;
            padding: 3px !important;
            flex: 1 auto;
            word-wrap: break-word;
            background: none !important;
            padding: 3px 0 0 0 !important;
            line-height: none !important;
        }

        .dashboard thead tr:after {
            content: '';
            overflow-y: scroll;
            visibility: hidden;
            height: 0;
        }

        .dashboard thead th {
            flex: 1 auto;
            display: block;
            padding: 0px;
            background-color: #000;
        }


            .dashboard thead th:first-child {
                border-top-left-radius: 4px;
            }

            .dashboard thead th:last-child {
                border-top-right-radius: 4px;
            }


        .dashboard tbody {
            display: block;
            width: 100%;
            overflow-y: auto;
            height: 370px;
        }

        .itdashtitle {
            margin-left: 7px;
        }
    </style>
    <link href="../css/chosen.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="right_panel">
        <!-- appointment tabs section start -->
        <ul class="appointment_tab">
            <li><a href="home.aspx">Sales Calendar</a></li>
            <li><a href="GoogleCalendarView.aspx">Master  Calendar</a></li>
            <li><a class="active" href="ITDashboard.aspx">Operations Calendar</a></li>
            <li><a href="CallSheet.aspx">Call Sheet</a></li>
            <li id="li_AnnualCalender" visible="false" runat="server"><a href="#" runat="server">Annual Event Calendar</a> </li>
        </ul>
        <!-- appointment tabs section end -->
        <h1><b>IT Dashboard</b></h1>
        <%--     <asp:Panel ID="pnlTestEmail" Visible="false" GroupingText="Test E-Mail" runat="server" CssClass="clsTestMail">
            <asp:TextBox ID="txtTestEmail" runat="server"></asp:TextBox>
            <asp:Button ID="btnTestMail" runat="server" Text="Send Mail" OnClick="btnTestMail_Click" />
            <br />
            <asp:Label runat="server" ID="lblMessage"></asp:Label>
        </asp:Panel>--%>

        <%--<asp:UpdatePanel runat="server" ID="upAlerts">
            <ContentTemplate>--%>
        <h2 runat="server" id="lblalertpopup">Alerts:
                    <a id="lblNewCounter" href="javascript:void(0);" runat="server" />
            <asp:Label ID="lblNewCounter0" runat="server"></asp:Label>
            <a id="lblFrozenCounter" href="javascript:void(0);" runat="server" />
            <asp:Label ID="lblFrozenCounter0" runat="server"></asp:Label>
        </h2>

        <!--  ------- Start DP new/frozen tasks popup ------  -->
        <button id="btnFake" style="display: none" runat="server"></button>
        <div id="pnlNewFrozenTask" class="dialog">

            <table id="Table2" runat="server" width="100%">
                <tr>
                    <td align="left" width="25%">
                        <h2 class="itdashtitle">Partial Frozen Tasks</h2>
                    </td>
                    <td align="center" width="30%">
                        <table id="tblSearchcontrols" runat="server">
                            <tr>
                                <td>Designation</td>
                                <td>Users</td>
                            </tr>
                            <tr>
                                <td>
                                    <%--  <asp:DropDownList ID="drpDesigFrozen" runat="server" Style="width: 150px;" AutoPostBack="true" OnSelectedIndexChanged="drpDesigFrozen_SelectedIndexChanged">
                                            </asp:DropDownList>--%>
                                    <asp:UpdatePanel ID="upnlDesignationFrozen" runat="server" RenderMode="Inline">
                                        <ContentTemplate>
                                            <asp:DropDownCheckBoxes ID="ddlDesigFrozen" runat="server" UseSelectAllNode="false" AutoPostBack="true" OnSelectedIndexChanged="ddlDesigFrozen_SelectedIndexChanged">
                                                <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                <Items>
                                                    <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                                                    <asp:ListItem Text="ITLead" Value="ITLead"></asp:ListItem>
                                                    <asp:ListItem Text="Jr. Sales" Value="Jr. Sales"></asp:ListItem>
                                                    <asp:ListItem Text="Jr Project Manager" Value="Jr Project Manager"></asp:ListItem>
                                                    <asp:ListItem Text="Office Manager" Value="Office Manager"></asp:ListItem>
                                                    <asp:ListItem Text="Recruiter" Value="Recruiter"></asp:ListItem>
                                                    <asp:ListItem Text="Sales Manager" Value="Sales Manager"></asp:ListItem>
                                                    <asp:ListItem Text="Sr. Sales" Value="Sr. Sales"></asp:ListItem>
                                                    <asp:ListItem Text="IT - Network Admin" Value="ITNetworkAdmin"></asp:ListItem>
                                                    <asp:ListItem Text="IT - Jr .Net Developer" Value="ITJr.NetDeveloper"></asp:ListItem>
                                                    <asp:ListItem Text="IT - Sr .Net Developer" Value="ITSr.NetDeveloper"></asp:ListItem>
                                                    <asp:ListItem Text="IT - Android Developer" Value="ITAndroidDeveloper"></asp:ListItem>
                                                    <asp:ListItem Text="IT - PHP Developer" Value="ITPHPDeveloper"></asp:ListItem>
                                                    <asp:ListItem Text="IT - SEO / BackLinking" Value="ITSEOBackLinking"></asp:ListItem>
                                                    <asp:ListItem Text="Installer - Helper" Value="InstallerHelper"></asp:ListItem>
                                                    <asp:ListItem Text="Installer - Journeyman" Value="InstallerJourneyman"></asp:ListItem>
                                                    <asp:ListItem Text="Installer - Mechanic" Value="InstallerMechanic"></asp:ListItem>
                                                    <asp:ListItem Text="Installer - Lead mechanic" Value="InstallerLeadMechanic"></asp:ListItem>
                                                    <asp:ListItem Text="Installer - Foreman" Value="InstallerForeman"></asp:ListItem>
                                                    <asp:ListItem Text="Commercial Only" Value="CommercialOnly"></asp:ListItem>
                                                    <asp:ListItem Text="SubContractor" Value="SubContractor"></asp:ListItem>
                                                </Items>
                                            </asp:DropDownCheckBoxes>
                                            <asp:CustomValidator ID="cvalidatorDesignationFrozen" runat="server" ValidationGroup="Submit" ErrorMessage="Please Select Designation" Display="None" ClientValidationFunction="checkddlDesigFrozen"></asp:CustomValidator>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>

                                </td>
                                <td>
                                    <%--<asp:DropDownList ID="drpUserFrozen" Style="width: 150px;" runat="server" AutoPostBack="true" OnSelectedIndexChanged="drpUserFrozen_SelectedIndexChanged">
                                            </asp:DropDownList>--%>
                                    <asp:UpdatePanel ID="upnlUsersFrozen" runat="server" RenderMode="Inline">
                                        <ContentTemplate>
                                            <asp:DropDownCheckBoxes ID="ddlUserFrozen" runat="server" UseSelectAllNode="false"
                                                AutoPostBack="true" OnSelectedIndexChanged="gv_ddlUserFrozen_SelectedIndexChanged">
                                                <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                <Texts SelectBoxCaption="--All--" />
                                            </asp:DropDownCheckBoxes>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td align="right">
                        <div style="float: left; margin-top: 15px;">
                            <asp:TextBox ID="txtSearchFrozen" runat="server" CssClass="textbox" placeholder="search users" />
                            <asp:Button ID="btnSearchFrozen" runat="server" Text="Search" Style="display: none;" class="btnSearc" OnClick="btnSearchFrozen_Click" />

                            Number of Records: 
                                <asp:DropDownList ID="drpPageSizeFrozen" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="drpPageSizeFrozen_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" />
                                    <asp:ListItem Selected="True" Text="20" Value="20" />
                                    <asp:ListItem Text="30" Value="30" />
                                    <asp:ListItem Text="40" Value="40" />
                                    <asp:ListItem Text="50" Value="50" />
                                </asp:DropDownList>
                        </div>
                    </td>
                </tr>
            </table>

            <asp:Label runat="server" ID="Label2"></asp:Label>

            <asp:UpdatePanel runat="server" ID="upnlFrozenTasks">
                <ContentTemplate>
                    <asp:GridView ID="grdFrozenTask" runat="server" OnPreRender="grdFrozenTask_PreRender"
                        AllowPaging="true" EmptyDataRowStyle-HorizontalAlign="Center"
                        HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                        CssClass="table dashboard" AllowCustomPaging="true"
                        EmptyDataText="No Frozen Tasks Found !!" Width="100%" CellSpacing="0" CellPadding="0"
                        AutoGenerateColumns="False" EnableSorting="true" GridLines="Both"
                        OnPageIndexChanging="OnPaginggrdFrozenTask" OnRowDataBound="grdFrozenTask_RowDataBound" PageSize="20">
                        <RowStyle CssClass="FirstRow" />
                        <HeaderStyle CssClass="trHeader" />
                        <AlternatingRowStyle CssClass="AlternateRow" />
                        <PagerSettings Mode="NumericFirstLast" NextPageText="Next" PreviousPageText="Previous" Position="Bottom" />
                        <PagerStyle HorizontalAlign="Right" CssClass="pagination-ys" />
                        <Columns>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Parent Task">
                                <ItemTemplate>
                                    <asp:HiddenField ID="frozenMainParentId" runat="server" Value='<%# Eval("MParentId")%>' />
                                    <asp:HiddenField ID="lblTaskIdInPro" runat="server" Value='<%# Eval("TaskId")%>' />
                                    <asp:HiddenField ID="lblParentTaskIdInPro" runat="server" Value='<%# Eval("ParentTaskId")%>' />
                                    <%--<%#Eval("Assigneduser") %>--%>
                                    <asp:Label ID="lblAssigneduser" runat="server" Text='<%# Eval("ParentTaskTitle")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Left"
                                HeaderStyle-Width="425px" ItemStyle-Width="425px" HeaderText="Sub Task">
                                <ItemTemplate>
                                    <asp:LinkButton ForeColor="Blue" ID="lnkInstallId" runat="server" Text='<%# Eval("InstallId")%>' data-highlighter='<%# Eval("TaskId")%>' parentdata-highlighter='<%# Eval("MParentId")%>' CssClass="context-menu"></asp:LinkButton>
                                    <asp:Label ID="lblDesc" runat="server" Text='<%# (string.IsNullOrEmpty(Convert.ToString(Eval("InstallId"))) ? Eval("Title") : (": "+ Eval("Title")) )%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--<asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Justify"
                                HeaderStyle-Width="300px" ItemStyle-Width="300px" HeaderText="Sub Task">
                                <ItemTemplate>
                                    <asp:Label ID="lblDesc" runat="server"
                                        Text='<%# Eval("Title")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>--%>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="120px" ItemStyle-Width="120px" HeaderText="Status">
                                <ItemTemplate>
                                    <%--<asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status")%>'></asp:Label>--%>
                                    <asp:HiddenField ID="lblStatus" runat="server" Value='<%# Eval("Status")%>'></asp:HiddenField>
                                    <asp:DropDownList ID="drpStatusFrozen" ClientIDMode="AutoID" runat="server" AutoPostBack="false" CssClass="gv_drp_Task_Status">
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="150px" ItemStyle-Width="150px" HeaderText="Approval">
                                <ItemTemplate>
                                    <div class="approvalBoxes">
                                        <asp:CheckBox ID="chkAdmin" Checked='<%# Convert.ToBoolean(Eval("AdminStatus")) %>' runat="server" CssClass="fz fz-admin" ToolTip="Admin" ClientIDMode="AutoID" />
                                        <asp:CheckBox ID="chkITLead" runat="server" Checked='<%# Convert.ToBoolean(Eval("TechLeadStatus")) %>' CssClass="fz fz-techlead" ToolTip="IT Lead" ClientIDMode="AutoID" />
                                        <asp:CheckBox ID="chkUser" runat="server" Checked='<%# Convert.ToBoolean(Eval("OtherUserStatus")) %>' CssClass="fz fz-user" ToolTip="User" ClientIDMode="AutoID" />
                                    </div>
                                    <div class="approvepopup">

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
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("AdminStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("AdminStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("AdminStatusUpdated").ToString())== true?"":"(EST)" %></span>
                                            </div>
                                            <div class='<%# String.IsNullOrEmpty( Eval("AdminStatusUpdated").ToString()) == true ? "display_inline" : "hide"  %>'>
                                                <input type="text" style="width: 100px;" placeholder="Admin password" />
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
                                                <input type="text" style="width: 55px;" placeholder="Est. Hours" />
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
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("TechLeadStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("TechLeadStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("TechLeadStatusUpdated").ToString())== true?"":"(EST)" %></span>
                                            </div>
                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("TechLeadStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                <input type="text" style="width: 100px;" placeholder="ITLead Password" />
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
                                                <input type="text" style="width: 55px;" placeholder="Est. Hours" />
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
                                                <span><%#String.Format("{0:M/d/yyyy}", Eval("OtherUserStatusUpdated"))%></span>&nbsp<span style="color: red"><%#String.Format("{0:hh:mm:ss tt}", Eval("OtherUserStatusUpdated"))%></span>&nbsp;<span><%#  String.IsNullOrEmpty(Eval("OtherUserStatusUpdated").ToString())== true?"":"(EST)" %></span>
                                            </div>
                                            <div style="width: 50%; float: right; font-size: x-small;" class='<%# String.IsNullOrEmpty( Eval("OtherUserStatusUpdated").ToString()) == true ? "display_inline": "hide" %>'>
                                                <input type="text" style="width: 100px;" placeholder="User Password" />
                                            </div>

                                        </div>

                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>

            <table id="htmltblNonFrozen" runat="server" width="100%">
                <tr>
                    <td align="left" width="30%">
                        <h2 class="itdashtitle">Non Frozen Tasks</h2>
                    </td>
                    <td align="center" width="30%">
                        <%-- <table id="Table6" runat="server"  >
                                <tr>
                                    <td>Designation</td><td>Users</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:DropDownList ID="drpDesigNew" runat="server"  AutoPostBack="true" OnSelectedIndexChanged="drpDesigNew_SelectedIndexChanged" >
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                            <asp:DropDownList ID="drpUserNew" runat="server" >
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                            </table>--%>
                    </td>
                    <td align="right">
                        <div style="float: left; margin-top: 15px;">
                            Number of Records: 
                                <asp:DropDownList ID="drpPageSizeNew" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="drpPageSizeNew_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" />
                                    <asp:ListItem Selected="True" Text="20" Value="20" />
                                    <asp:ListItem Text="30" Value="30" />
                                    <asp:ListItem Text="40" Value="40" />
                                    <asp:ListItem Text="50" Value="50" />
                                </asp:DropDownList>
                        </div>
                    </td>
                </tr>
            </table>

            <asp:Label runat="server" ID="Label3"></asp:Label>

            <asp:UpdatePanel runat="server" ID="upnlNonFrozenTasks">
                <ContentTemplate>
                    <asp:GridView ID="grdNewTask" runat="server" OnPreRender="grdNewTask_PreRender"
                        AllowPaging="true" EmptyDataRowStyle-HorizontalAlign="Center"
                        HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                        CssClass="table dashboard" AllowCustomPaging="true"
                        EmptyDataText="No Frozen Tasks Found !!" Width="100%" CellSpacing="0" CellPadding="0"
                        AutoGenerateColumns="False" EnableSorting="true" GridLines="Both"
                        OnPageIndexChanging="OnPaginggrdNewTask" OnRowDataBound="grdNewTask_RowDataBound" PageSize="20">
                        <RowStyle CssClass="FirstRow" />
                        <HeaderStyle CssClass="trHeader" />
                        <AlternatingRowStyle CssClass="AlternateRow" />
                        <PagerSettings Mode="NumericFirstLast" NextPageText="Next" PreviousPageText="Previous" Position="Bottom" />
                        <PagerStyle HorizontalAlign="Right" CssClass="pagination-ys" />
                        <Columns>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Parent Task">
                                <ItemTemplate>
                                    <asp:HiddenField ID="nonfrozenMainParentId" runat="server" Value='<%# Eval("MainParentId")%>' />
                                    <asp:HiddenField ID="lblTaskIdInPro" runat="server" Value='<%# Eval("TaskId")%>' />
                                    <asp:HiddenField ID="lblParentTaskIdInPro" runat="server" Value='<%# Eval("ParentTaskId")%>' />
                                    <%--<asp:Label ID="lblDueDate" runat="server" Text='<%# Eval("DueDate")%>'></asp:Label>--%>
                                    <%--<asp:Label ID="lblAssignedUser" runat="server" Text='<%# Eval("Assigneduser")%>'></asp:Label>--%>
                                    <asp:Label ID="lblAssigneduser" runat="server" Text='<%# Eval("ParentTaskTitle")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Left"
                                HeaderStyle-Width="425px" ItemStyle-Width="425px" HeaderText="Sub Task">
                                <ItemTemplate>
                                    <asp:LinkButton ForeColor="Blue" ID="lnkInstallId" runat="server" Text='<%# Eval("InstallId") %>' data-highlighter='<%# Eval("TaskId")%>' parentdata-highlighter='<%# Eval("MainParentId")%>' CssClass="context-menu"></asp:LinkButton>
                                    <asp:Label ID="lblDesc" runat="server" Text='<%# (string.IsNullOrEmpty(Convert.ToString(Eval("InstallId"))) ? Eval("Title") : (": "+ Eval("Title")) )%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--<asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Justify"
                                HeaderStyle-Width="30%" ItemStyle-Width="30%" HeaderText="Sub Task">
                                <ItemTemplate>
                                    <asp:Label ID="lblDesc" runat="server"
                                        Text='<%# Eval("Title")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>--%>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="120px" ItemStyle-Width="120px" HeaderText="Status">
                                <ItemTemplate>
                                    <%--<asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status")%>'></asp:Label>--%>
                                    <asp:HiddenField ID="lblStatus" runat="server" Value='<%# Eval("Status")%>'></asp:HiddenField>
                                    <asp:DropDownList ID="drpStatusFrozen" ClientIDMode="AutoID" runat="server" AutoPostBack="false" CssClass="gv_drp_Task_Status">
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                                HeaderStyle-Width="150px" ItemStyle-Width="150px" HeaderText="Approval">
                                <ItemTemplate>
                                    <div class="approvalBoxes">
                                        <asp:CheckBox ID="chkAdmin" Checked="false" runat="server" CssClass="fz fz-admin" ToolTip="Admin" ClientIDMode="AutoID" />
                                        <asp:CheckBox ID="chkITLead" runat="server" Checked="false" CssClass="fz fz-techlead" ToolTip="IT Lead" ClientIDMode="AutoID" />
                                        <asp:CheckBox ID="chkUser" runat="server" Checked="false" CssClass="fz fz-user" ToolTip="User" ClientIDMode="AutoID" />
                                    </div>
                                    <asp:Label ID="lblHoursLeadInPro" runat="server"></asp:Label>
                                    <br />
                                    <asp:Label ID="lblHoursDevInPro" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>


                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>

            <table border="1" cellspacing="5" cellpadding="5">
                <tr>
                    <td colspan="2">
                        <asp:Button ID="btnCalClose" runat="server" Height="30px" Width="70px" TabIndex="6" OnClick="btnCalClose_Click" Text="Close" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" />
                    </td>
                </tr>
            </table>

        </div>
        <!-- --------- End DP -------  -->
        <%--</ContentTemplate>
        </asp:UpdatePanel>--%>

        <asp:UpdatePanel ID="upnlInprogressTasks" runat="server" width="100%">
            <ContentTemplate>

                <table width="100%">
                    <tr>
                        <td align="left" width="30%">
                            <h2 class="itdashtitle">In Progress, Assigned-Requested</h2>
                        </td>
                        <td align="center" width="30%">
                            <table id="tblInProgress" runat="server">
                                <tr>
                                    <td>Designation</td>
                                    <td>Users</td>
                                </tr>
                                <tr>
                                    <td>
                                        <%--<asp:DropDownList ID="drpDesigInProgress" runat="server" Style="width: 150px;" AutoPostBack="true" OnSelectedIndexChanged="drpDesigInProgress_SelectedIndexChanged">
                                        </asp:DropDownList>--%>
                                        <asp:UpdatePanel ID="upnlDesignation" runat="server" RenderMode="Inline">
                                            <ContentTemplate>
                                                <asp:DropDownCheckBoxes ID="ddlInprogressUserDesignation" runat="server" UseSelectAllNode="false" AutoPostBack="true" OnSelectedIndexChanged="ddlInprogressUserDesignation_SelectedIndexChanged">
                                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                    <Items>
                                                        <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                                                        <asp:ListItem Text="ITLead" Value="ITLead"></asp:ListItem>
                                                        <asp:ListItem Text="Jr. Sales" Value="Jr. Sales"></asp:ListItem>
                                                        <asp:ListItem Text="Jr Project Manager" Value="Jr Project Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Office Manager" Value="Office Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Recruiter" Value="Recruiter"></asp:ListItem>
                                                        <asp:ListItem Text="Sales Manager" Value="Sales Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Sr. Sales" Value="Sr. Sales"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Network Admin" Value="ITNetworkAdmin"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Jr .Net Developer" Value="ITJr.NetDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Sr .Net Developer" Value="ITSr.NetDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Android Developer" Value="ITAndroidDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - PHP Developer" Value="ITPHPDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - SEO / BackLinking" Value="ITSEOBackLinking"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Helper" Value="InstallerHelper"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Journeyman" Value="InstallerJourneyman"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Mechanic" Value="InstallerMechanic"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Lead mechanic" Value="InstallerLeadMechanic"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Foreman" Value="InstallerForeman"></asp:ListItem>
                                                        <asp:ListItem Text="Commercial Only" Value="CommercialOnly"></asp:ListItem>
                                                        <asp:ListItem Text="SubContractor" Value="SubContractor"></asp:ListItem>
                                                    </Items>
                                                </asp:DropDownCheckBoxes>
                                                <asp:CustomValidator ID="cvDesignations" runat="server" ValidationGroup="Submit" ErrorMessage="Please Select Designation" Display="None" ClientValidationFunction="checkDesignations"></asp:CustomValidator>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
                                        <%--<asp:DropDownList ID="drpUsersInProgress" Style="width: 150px;" runat="server" AutoPostBack="true" OnSelectedIndexChanged="drpUsersInProgress_SelectedIndexChanged">
                                        </asp:DropDownList>--%>
                                        <asp:UpdatePanel ID="upnlAssigned" runat="server" RenderMode="Inline">
                                            <ContentTemplate>
                                                <asp:ListBox ID="ddlInProgressAssignedUsers" runat="server" Width="150" ClientIDMode="AutoID" SelectionMode="Multiple"
                                                    CssClass="chosen-select" data-placeholder="Select"
                                                    AutoPostBack="false" />
                                                <asp:Button ID="searchUsers" runat="server" ClientIDMode="AutoID" OnClick="searchUsers_Click" Text="SearchUsers" CssClass="hide"></asp:Button>
                                                <%--<asp:DropDownCheckBoxes ID="ddlInProgressAssignedUsers" runat="server" UseSelectAllNode="false"
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlInProgressAssignedUsers_SelectedIndexChanged">
                                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                    <Texts SelectBoxCaption="--All--" />
                                                </asp:DropDownCheckBoxes>--%>
                                                <%--<asp:LinkButton ID="lbtnViewInProgressAcceptanceLog" runat="server" Text="View Acceptance Log" OnClick="lbtnViewInProgressAcceptanceLog_Click" />--%>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="searchUsers" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="right">

                            <div style="float: left; margin-top: 15px;">
                                <asp:TextBox ID="txtSearchInPro" runat="server" CssClass="textbox" placeholder="search users" MaxLength="15" />
                                <asp:Button ID="btnSearchInPro" runat="server" Text="Search" Style="display: none;" class="btnSearc" OnClick="btnSearchInPro_Click" />

                                Number of Records: 
                                <asp:DropDownList ID="drpPageSizeInpro" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="drpPageSizeInpro_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" />
                                    <asp:ListItem Selected="True" Text="20" Value="20" />
                                    <asp:ListItem Text="30" Value="30" />
                                    <asp:ListItem Text="40" Value="40" />
                                    <asp:ListItem Text="50" Value="50" />
                                </asp:DropDownList>
                            </div>
                        </td>
                    </tr>
                </table>

                <asp:Label runat="server" ID="lblMessage"></asp:Label>
                <asp:GridView ID="grdTaskPending" runat="server" OnPreRender="grdTaskPending_PreRender"
                    AllowPaging="true" EmptyDataRowStyle-HorizontalAlign="Center"
                    HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                    CssClass="table dashboard" AllowCustomPaging="true"
                    EmptyDataText="No Pending Tasks Found !!" Width="100%" CellSpacing="0" CellPadding="0"
                    AutoGenerateColumns="False" EnableSorting="true" GridLines="Both"
                    OnPageIndexChanging="OnPagingTaskInProgress" OnRowDataBound="grdTaskPending_RowDataBound" PageSize="20">
                    <RowStyle CssClass="FirstRow" />
                    <HeaderStyle CssClass="trHeader " />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <PagerSettings Mode="NumericFirstLast" NextPageText="Next" PreviousPageText="Previous" Position="Bottom" />
                    <PagerStyle HorizontalAlign="Right" CssClass="pagination-ys" />
                    <Columns>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px"
                            ItemStyle-Width="100px" HeaderText="Assigned To">
                            <ItemTemplate>
                                <asp:HiddenField ID="hdMainParentId" runat="server" Value='<%# Eval("MainParentId")%>' />
                                <asp:HiddenField ID="lblTaskIdInPro" runat="server" Value='<%# Eval("TaskId")%>' />
                                <asp:HiddenField ID="lblParentTaskIdInPro" runat="server" Value='<%# Eval("ParentTaskId")%>' />
                                <%--<asp:Label ID="lblDueDate" runat="server" Text='<%# Eval("DueDate")%>'></asp:Label>--%>
                                <asp:Label ID="lblAssignedUser" runat="server" Text='<%# Eval("Assigneduser")%>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Sub Task ID#">
                            <ItemTemplate>
                                <asp:LinkButton ForeColor="Blue" ID="lnkInstallId" runat="server" Text='<%# Eval("InstallId")%>' data-highlighter='<%# Eval("TaskId")%>' parentdata-highlighter='<%# Eval("MainParentId")%>' CssClass="context-menu"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Justify" HeaderStyle-Width="300px" ItemStyle-Width="300px" HeaderText="Sub Task">
                            <ItemTemplate>
                                <asp:Label ID="lblDesc" runat="server"
                                    Text='<%# Eval("Title")%>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="150px" ItemStyle-Width="150px" HeaderText="Parent Task">
                            <ItemTemplate>
                                <%#Eval("ParentTaskTitle") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="120px" ItemStyle-Width="120px" HeaderText="Status">
                            <ItemTemplate>
                                <asp:HiddenField ID="lblStatus" runat="server" Value='<%# Eval("Status")%>'></asp:HiddenField>
                                <asp:DropDownList ID="drpStatusInPro" runat="server" AutoPostBack="true" OnSelectedIndexChanged="drpStatusInPro_SelectedIndexChanged">
                                </asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Approval">
                            <ItemTemplate>
                                <%--<asp:CheckBox ID="chkAdmin" Enabled="false" runat="server" />
                                <asp:CheckBox ID="chkITLead" Enabled="false" runat="server" />
                                <asp:CheckBox ID="chkUser" Enabled="false" runat="server" />--%>
                                <div class="approvalBoxes">
                                    <%--<asp:CheckBox ID="" Checked='<%# String.IsNullOrEmpty(Eval("AdminStatusUpdated").ToString())== true? false : true %>' runat="server" CssClass="fz fz-admin" ToolTip="Admin" ClientIDMode="AutoID" />
                                    <asp:CheckBox ID="" runat="server" Checked='<%# String.IsNullOrEmpty(Eval("TechLeadStatusUpdated").ToString())== true? false : true %>' CssClass="fz fz-techlead" ToolTip="IT Lead" ClientIDMode="AutoID" />
                                    <asp:CheckBox ID="" runat="server" Checked='<%# String.IsNullOrEmpty(Eval("OtherUserStatusUpdated").ToString())== true? false : true %>' CssClass="fz fz-user" ToolTip="User" ClientIDMode="AutoID" />--%>

                                    <asp:CheckBox ID="chkAdmin" Checked='<%# Convert.ToBoolean(Eval("AdminStatus")) %>' runat="server" CssClass="fz fz-admin" ToolTip="Admin" ClientIDMode="AutoID" />
                                    <asp:CheckBox ID="chkITLead" runat="server" Checked='<%# Convert.ToBoolean(Eval("TechLeadStatus")) %>' CssClass="fz fz-techlead" ToolTip="IT Lead" ClientIDMode="AutoID" />
                                    <asp:CheckBox ID="chkUser" runat="server" Checked='<%# Convert.ToBoolean(Eval("OtherUserStatus")) %>' CssClass="fz fz-user" ToolTip="User" ClientIDMode="AutoID" />

                                </div>

                                <asp:Label ID="lblHoursLeadInPro" runat="server"></asp:Label>
                                <br />
                                <asp:Label ID="lblHoursDevInPro" runat="server"></asp:Label>

                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>

                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
        <h2></h2>
        <asp:UpdatePanel ID="upClosedTask" runat="server">
            <ContentTemplate>

                <table width="100%">
                    <tr>
                        <td align="left" width="30%">
                            <h2 class="itdashtitle">Commits, Closed-Billed</h2>
                        </td>
                        <td align="center" width="30%">
                            <table id="tblClosedTask" runat="server">
                                <tr>
                                    <td>Designation</td>
                                    <td>Users</td>
                                </tr>
                                <tr>
                                    <td>
                                        <%--<asp:DropDownList ID="drpDesigClosed" runat="server" Style="width: 150px;" AutoPostBack="true" OnSelectedIndexChanged="drpDesigClosed_SelectedIndexChanged">
                                        </asp:DropDownList>--%>
                                        <asp:UpdatePanel ID="upnlDesignationClosedTasks" runat="server" RenderMode="Inline">
                                            <ContentTemplate>
                                                <asp:DropDownCheckBoxes ID="ddlClosedUserDesignation" runat="server" UseSelectAllNode="false" AutoPostBack="true" OnSelectedIndexChanged="ddlClosedUserDesignation_SelectedIndexChanged">
                                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                    <Items>
                                                        <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                                                        <asp:ListItem Text="ITLead" Value="ITLead"></asp:ListItem>
                                                        <asp:ListItem Text="Jr. Sales" Value="Jr. Sales"></asp:ListItem>
                                                        <asp:ListItem Text="Jr Project Manager" Value="Jr Project Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Office Manager" Value="Office Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Recruiter" Value="Recruiter"></asp:ListItem>
                                                        <asp:ListItem Text="Sales Manager" Value="Sales Manager"></asp:ListItem>
                                                        <asp:ListItem Text="Sr. Sales" Value="Sr. Sales"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Network Admin" Value="ITNetworkAdmin"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Jr .Net Developer" Value="ITJr.NetDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Sr .Net Developer" Value="ITSr.NetDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - Android Developer" Value="ITAndroidDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - PHP Developer" Value="ITPHPDeveloper"></asp:ListItem>
                                                        <asp:ListItem Text="IT - SEO / BackLinking" Value="ITSEOBackLinking"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Helper" Value="InstallerHelper"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Journeyman" Value="InstallerJourneyman"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Mechanic" Value="InstallerMechanic"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Lead mechanic" Value="InstallerLeadMechanic"></asp:ListItem>
                                                        <asp:ListItem Text="Installer - Foreman" Value="InstallerForeman"></asp:ListItem>
                                                        <asp:ListItem Text="Commercial Only" Value="CommercialOnly"></asp:ListItem>
                                                        <asp:ListItem Text="SubContractor" Value="SubContractor"></asp:ListItem>
                                                    </Items>
                                                </asp:DropDownCheckBoxes>
                                                <asp:CustomValidator ID="CustomValidator1" runat="server" ValidationGroup="Submit" ErrorMessage="Please Select Designation" Display="None" ClientValidationFunction="checkClosedDesignations"></asp:CustomValidator>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
                                        <%--<asp:DropDownList ID="drpUsersClosed" Style="width: 150px;" runat="server" AutoPostBack="true" OnSelectedIndexChanged="drpUsersClosed_SelectedIndexChanged">
                                        </asp:DropDownList>--%>
                                        <asp:UpdatePanel ID="upnlUsersClosedTasks" runat="server" RenderMode="Inline">
                                            <ContentTemplate>
                                                <asp:DropDownCheckBoxes ID="ddlClosedAssignedUsers" runat="server" UseSelectAllNode="false"
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlClosedAssignedUsers_SelectedIndexChanged">
                                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                                    <Texts SelectBoxCaption="--All--" />
                                                </asp:DropDownCheckBoxes>
                                                <%--<asp:LinkButton ID="lbtnViewClosedAcceptanceLog" runat="server" Text="View Acceptance Log" OnClick="lbtnViewClosedAcceptanceLog_Click" />--%>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="right">
                            <div style="float: left; margin-top: 15px;">
                                <asp:TextBox ID="txtSearchClosed" runat="server" CssClass="textbox" placeholder="search users" MaxLength="15" />
                                <asp:Button ID="btnSearchClosed" runat="server" Text="Search" Style="display: none;" class="btnSearc" OnClick="btnSearchClosed_Click" />

                                Number of Records: 
                                <asp:DropDownList ID="drpPageSizeClosed" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="drpPageSizeClosed_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" />
                                    <asp:ListItem Selected="True" Text="20" Value="20" />
                                    <asp:ListItem Text="30" Value="30" />
                                    <asp:ListItem Text="40" Value="40" />
                                    <asp:ListItem Text="50" Value="50" />
                                </asp:DropDownList>
                            </div>
                        </td>
                    </tr>
                </table>

                <asp:Label runat="server" ID="Label1"></asp:Label>
                <asp:GridView ID="grdTaskClosed" runat="server"
                    OnPreRender="grdTaskClosed_PreRender"
                    ShowHeaderWhenEmpty="true" AllowPaging="true" EmptyDataRowStyle-HorizontalAlign="Center"
                    HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                    EmptyDataText="No Closed Tasks Found !!" CssClass="table dashboard" Width="100%"
                    CellSpacing="0" CellPadding="0" AllowCustomPaging="true"
                    AutoGenerateColumns="False" EnableSorting="true" GridLines="Both" OnPageIndexChanging="OnPagingTaskClosed"
                    OnRowDataBound="grdTaskClosed_RowDataBound" PagerStyle-HorizontalAlign="Right" PageSize="20">
                    <HeaderStyle CssClass="trHeader " />
                    <RowStyle CssClass="FirstRow" />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <PagerSettings Mode="NumericFirstLast" NextPageText="Next" PreviousPageText="Previous" Position="Bottom" />
                    <PagerStyle HorizontalAlign="Right" CssClass="pagination-ys" />
                    <Columns>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                            HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Assigned To">
                            <ItemTemplate>
                                <asp:HiddenField ID="hdnMainParentId" runat="server" Value='<%# Eval("MainParentId")%>' />
                                <asp:HiddenField ID="lblTaskIdClosed" runat="server" Value='<%# Eval("TaskId")%>' />
                                <asp:HiddenField ID="lblParentTaskIdClosed" runat="server" Value='<%# Eval("ParentTaskId")%>' />
                                <%--<asp:Label ID="lblDueDate" runat="server" Text='<%# Eval("DueDate")%>'></asp:Label>--%>
                                <asp:Label ID="lblAssignedUser" runat="server" Text='<%# Eval("Assigneduser")%>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center"
                            HeaderStyle-Width="100px" ItemStyle-Width="100px" HeaderText="Sub Task ID#">
                            <ItemTemplate>
                                <asp:LinkButton ForeColor="Blue" ID="lnkInstallId" runat="server" Text='<%# Eval("InstallId")%>' data-highlighter='<%# Eval("TaskId")%>' parentdata-highlighter='<%# Eval("MainParentId")%>' CssClass="context-menu"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Justify"
                            HeaderStyle-Width="300px" ItemStyle-Width="300px" HeaderText="Sub Task">
                            <ItemTemplate>
                                <asp:Label ID="lblDesc" runat="server"
                                    Text='<%# Eval("Title")%>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="120px" ItemStyle-Width="120px" HeaderText="Status">
                            <ItemTemplate>
                                <asp:HiddenField ID="lblStatus" runat="server" Value='<%# Eval("Status")%>'></asp:HiddenField>
                                <asp:DropDownList ID="drpStatusClosed" runat="server" AutoPostBack="true" OnSelectedIndexChanged="drpStatusClosed_SelectedIndexChanged">
                                </asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="grdTaskClosed" />
            </Triggers>
        </asp:UpdatePanel>

    </div>
    <div id="HighLightedTask" class="modal">
        <iframe id="ifrmTask" style="height: 100%; width: 100%; overflow: auto;"></iframe>
    </div>
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/js/chosen.jquery.js")%>"></script>
    <script type="text/javascript">

        function pageLoad(sender, args) {
            $(".gv_drp_Task_Status").each(function (index) {
                //$(this).unbind('click').click(function () {
                //});
                $(this).bind("change", function () {
                    var taskId = $(this).attr("data-task-id");
                    var ddlValue = $(this).val();
                    updateTaskStatus(taskId, ddlValue);
                    return false;
                });
            });
        }

        function updateTaskStatus(id, value) {
            ShowAjaxLoader();
            var postData = {
                intTaskId: id,
                TaskStatus: value
            };

            $.ajax
            (
                {
                    url: '../WebServices/JGWebService.asmx/SetTaskStatus',
                    contentType: 'application/json; charset=utf-8;',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify(postData),
                    asynch: false,
                    success: function (data) {
                        HideAjaxLoader();
                        alert('Task Status Updated successfully.');
                    },
                    error: function (a, b, c) {
                        HideAjaxLoader();
                    }
                }
            );
        }
        // check if user has selected any designations or not.
        function checkDesignations(oSrc, args) {
            args.IsValid = ($("#<%= ddlInprogressUserDesignation.ClientID%> input:checked").length > 0);
        }

        // check if user has selected any designations or not.
        function checkddlDesigFrozen(oSrc, args) {
            args.IsValid = ($("#<%= ddlDesigFrozen.ClientID%> input:checked").length > 0);
        }

        function checkClosedDesignations(oSrc, args) {
            args.IsValid = ($("#<%= ddlClosedUserDesignation.ClientID%> input:checked").length > 0);
        }

       <%-- function checkFrozenDesignations(oSrc, args) {
            args.IsValid = ($("#<%= ddlFrozenUserDesignation.ClientID%> input:checked").length > 0);
        }--%>

        var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

        prmTaskGenerator.add_endRequest(function () {
            Initialize();
        });

        function _updateQStringParam(uri, key, value, Mainkey, MainValue) {
            var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
            var separator = uri.indexOf('?') !== -1 ? "&" : "?";

            if (uri.match(re)) {
                return uri.replace(re, '$1' + key + "=" + value + '$2');
            }
            else {
                uri = uri.replace("ITDashboard", "TaskGenerator");
                return uri + separator + Mainkey + "=" + MainValue + '&' + key + "=" + value;
            }
        }

        $(document).ready(function () {
            checkNShowTaskPopup();
            Initialize();
        });


        function Initialize() {
            SetInProTaskAutoSuggestion();
            SetInProTaskAutoSuggestionUI();

            SetClosedTaskAutoSuggestion();
            SetClosedTaskAutoSuggestionUI();

            SetFrozenTaskAutoSuggestion();
            SetFrozenTaskAutoSuggestionUI();

            SetApprovalUI();
            SetTaskCounterPopup();
            checkDropdown();

            ChosenDropDown();
            setSelectedUsersLink();

            $(".context-menu").bind("contextmenu", function () {
                var urltoCopy = _updateQStringParam(window.location.href, "hstid", $(this).attr('data-highlighter'), "TaskId", $(this).attr('parentdata-highlighter'));
                copyToClipboard(urltoCopy);
                return false;
            });
        }

        //$(".context-menu").bind("contextmenu", function () {
        //    debugger;
        //    var urltoCopy = updateQueryStringParameter(window.location.href, "hstid", $(this).attr('data-highlighter'), "TaskId", $(this).attr('parentdata-highlighter'));
        //    copyToClipboard(urltoCopy);
        //    return false;
        //});
        function checkNShowTaskPopup() {

            var TaskId = getUrlVars()["TaskId"];
            if (TaskId) {
                var iframeURL = '<%=JG_Prospect.Common.JGApplicationInfo.GetSiteURL()%>' + '/Sr_App/TaskGenerator.aspx?' + window.location.href.slice(window.location.href.indexOf('?') + 1);
                console.log(iframeURL);
                $('#ifrmTask').attr("Src", iframeURL);

                var $dialog = $('#HighLightedTask').dialog({
                    autoOpen: true,
                    modal: false,
                    height: 500,
                    width: 800
                });

            }
        }

        // Read a page's GET URL variables and return them as an associative array.
        function getUrlVars() {
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for (var i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
            return vars;
        }

        function setSelectedUsersLink() {

            $('.search-choice').each(function () {
                var itemIndex = $(this).children('.search-choice-close').attr('data-option-array-index');
                //console.log(itemIndex);
                if (itemIndex) {
                    //console.log($(this).parent('.chosen-choices').parent('.chosen-container'));
                    var selectoptionid = '#' + $(this).parent('.chosen-choices').parent('.chosen-container').attr('id').replace("_chosen", "") + ' option';
                    var chspan = $(this).children('span');
                    if (chspan) {
                        chspan.html('<a style="color:blue;" href="/Sr_App/ViewSalesUser.aspx?id=' + $(selectoptionid)[itemIndex].value + '">' + chspan.text() + '</a>');
                        chspan.bind("click", "a", function () {
                            window.open($(this).children("a").attr("href"), "_blank", "", false);
                        });
                    }
                }
            });

            $('.chosen-select').bind('change', function (evt, params) {
                console.log(evt);
                console.log(params);

                if (params.selected === "0" || !$('#<%=ddlInProgressAssignedUsers.ClientID%>').val()) {
                    console.log(params.selected);
                    $('#<%=ddlInProgressAssignedUsers.ClientID%>').val(null);
                    $('#<%=ddlInProgressAssignedUsers.ClientID%>').val("0");
                }
                else {
                    $("#<%=ddlInProgressAssignedUsers.ClientID%> option[value='0']").remove();
                }
                //console.log($('#<%=ddlInProgressAssignedUsers.ClientID%>').val());
                var selectedUsers = $('#<%=ddlInProgressAssignedUsers.ClientID%>').val();
                console.log(selectedUsers);
                if (selectedUsers) {
                    SearchUsers();
                }
            });
        }

        function SearchUsers() {
            $('#<%=searchUsers.ClientID%>').click();
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

        function SetFrozenTaskAutoSuggestion() {

            $("#<%=txtSearchFrozen.ClientID%>").catcomplete({
                delay: 500,
                source: function (request, response) {

                    if (request.term == "") {
                        $('#<%=btnSearchFrozen.ClientID%>').click();
                         return false;
                     }

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
                             $("#<%=txtSearchFrozen.ClientID%>").removeClass("ui-autocomplete-loading");
                        }
                    });
                 },
                minLength: 0,
                select: function (event, ui) {
                    $("#<%=txtSearchFrozen.ClientID%>").val(ui.item.value);
                     //TriggerSearch();
                     $('#<%=btnSearchFrozen.ClientID%>').click();
                 }
            });
         }

         function SetFrozenTaskAutoSuggestionUI() {

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


         function SetClosedTaskAutoSuggestion() {

             $("#<%=txtSearchClosed.ClientID%>").catcomplete({
                delay: 500,
                source: function (request, response) {

                    if (request.term == "") {
                        $('#<%=btnSearchClosed.ClientID%>').click();
                        return false;
                    }


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
                            $("#<%=txtSearchClosed.ClientID%>").removeClass("ui-autocomplete-loading");
                        }
                    });
                },
                minLength: 0,
                select: function (event, ui) {
                    $("#<%=txtSearchClosed.ClientID%>").val(ui.item.value);
                    //TriggerSearch();
                    $('#<%=btnSearchClosed.ClientID%>').click();
                }
            });
        }

        function SetClosedTaskAutoSuggestionUI() {

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




        function SetInProTaskAutoSuggestion() {

            $("#<%=txtSearchInPro.ClientID%>").catcomplete({
                delay: 500,
                source: function (request, response) {

                    if (request.term == "") {
                        $('#<%=btnSearchInPro.ClientID%>').click();
                        return false;
                    }

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
                            $("#<%=txtSearchInPro.ClientID%>").removeClass("ui-autocomplete-loading");
                        }
                    });
                },
                minLength: 0,
                select: function (event, ui) {
                    $("#<%=txtSearchInPro.ClientID%>").val(ui.item.value);
                    //TriggerSearch();
                    $('#<%=btnSearchInPro.ClientID%>').click();
                }
            });
        }

        function SetInProTaskAutoSuggestionUI() {

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


        function SetTaskCounterPopup() {

            var dlg = $('#pnlNewFrozenTask').dialog({
                width: 1000,
                show: 'slide',
                hide: 'slide',
                autoOpen: false,
                modal: true
            });

            dlg.parent().appendTo(jQuery("form:first"));

            $('#<%= lblNewCounter.ClientID %>').click(function () { $('#pnlNewFrozenTask').dialog('open'); });
            $('#<%= lblFrozenCounter.ClientID %>').click(function () { $('#pnlNewFrozenTask').dialog('open'); });
        }

        function checkDropdown() {
         <%--   $('#<%=ddlDesigFrozen.ClientID %> [type="checkbox"]').each(function () {
                $(this).click(function () { console.log($(this).prop('checked')); })
            });--%>
        }
    </script>
</asp:Content>
