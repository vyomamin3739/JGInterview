<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="manage-aptitude-tests.aspx.cs"
    Inherits="JG_Prospect.Sr_App.manage_aptitude_tests" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="right_panel">
        <!-- appointment tabs section start -->
        <ul class="appointment_tab">
            <li><a href="Price_control.aspx">Product Line Estimate</a></li>
            <li><a href="Inventory.aspx">Inventory</a></li>
            <li><a href="Maintenace.aspx">Maintainance</a></li>
            <li><a href="email-template-maintainance.aspx">Maintainance New</a></li>
            <li><a href="manage-aptitude-tests.aspx.aspx">Aptitude Tests</a></li>
        </ul>
        <!-- appointment tabs section end -->
        <h1>Aptitude Tests</h1>
        <div class="form_panel_custom">
            <asp:UpdatePanel ID="upExams" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td>Designation:
                        <asp:DropDownList ID="ddlDesignation" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDesignation_SelectedIndexChanged" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                <a href='<%=Page.ResolveUrl("~/sr_app/add-edit-aptitude-test.aspx") %>'>Add New Aptitude Test</a>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:GridView ID="grdExams" runat="server" AutoGenerateColumns="false" DataKeyNames="ExamId"
                                    CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" GridLines="Vertical">
                                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" BackColor="Black" Height="30" VerticalAlign="Middle" />
                                    <HeaderStyle CssClass="trHeader " />
                                    <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                    <AlternatingRowStyle CssClass="AlternateRow " />
                                    <EmptyDataTemplate>
                                        No records to display.
                                    </EmptyDataTemplate>
                                    <Columns>
                                        <asp:TemplateField HeaderText="Name">
                                            <ItemTemplate>
                                                <a href='<%# string.Format("{0}?ExamID={1}", Page.ResolveUrl("~/sr_app/view-aptitude-test.aspx"), Eval("ExamID")) %>'><%# Eval("ExamTitle") %></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Description">
                                            <ItemTemplate>
                                                <%# Eval("ExamDescription") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Duration">
                                            <ItemTemplate>
                                                <%# Eval("ExamDuration") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Pass Percentage">
                                            <ItemTemplate>
                                                <%# Eval("PassPercentage") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Active">
                                            <ItemTemplate>
                                                <img src='<%# Convert.ToBoolean(Eval("IsActive")) ? Page.ResolveUrl("~/img/success.png") : "javascript:void(0);" %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Designation">
                                            <ItemTemplate>
                                                <%# Eval("DesignationName") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="">
                                            <ItemTemplate>
                                                <a href='<%# string.Format("{0}?ExamID={1}", Page.ResolveUrl("~/sr_app/add-edit-aptitude-test.aspx"), Eval("ExamID")) %>'>Edit</a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                <a href='<%=Page.ResolveUrl("~/sr_app/add-edit-aptitude-test.aspx") %>'>Add New Aptitude Test</a>
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
</asp:Content>
