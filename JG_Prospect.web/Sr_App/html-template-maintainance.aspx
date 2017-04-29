<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="html-template-maintainance.aspx.cs" 
    Inherits="JG_Prospect.Sr_App.html_template_maintainance" %>

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
        <h1>Maintainance</h1>
        <div style="padding:5px;">
            <table>
                <tr>
                    <td>
                        <label>Company Address</label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCompanyAddress" runat="server" CssClass="cls_textbox"></asp:TextBox>
                    </td>
                    <td>
                        <label>Zip</label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtZip" runat="server" CssClass="cls_textbox"></asp:TextBox>
                    </td>
                    <td>
                        <label>City</label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCity" runat="server" CssClass="cls_textbox"></asp:TextBox>
                    </td>

                    <td>
                        <label>State<span></span></label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtState" runat="server" CssClass="cls_textbox"></asp:TextBox>
                    </td>
                    <td>
                        <asp:HiddenField ID="hdnCompanyAddressId" runat="server" />
                        <div class="btn_sec">
                            <input type="button" id="btnupdate" runat="server" style="width: 80px;" onclick="UpdateCompanyAddress();" value="Update" />
                        </div>
                    </td>
                </tr>
            </table>
            <br />
            <h3>HR Auto Email Templates</h3>
            <asp:GridView ID="grdTemplates_HRAutoEmail" runat="server"  AutoGenerateColumns="false" DataKeyNames="Id"
                CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" GridLines="Vertical">
                <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                <HeaderStyle CssClass="trHeader " />
                <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                <AlternatingRowStyle CssClass="AlternateRow " />
                <Columns>
                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:HyperLink ID="hypEdit" ForeColor="Blue" runat="server" Text='<%# Eval("Name") %>' 
                                NavigateUrl='<%# Page.ResolveUrl("~/Sr_App/edit-html-template.aspx?MasterId=" + Eval("Id") + 
                                                "&Type="+ Convert.ToByte(JG_Prospect.Common.HTMLTemplateTypes.AutoEmailTemplate).ToString() +
                                                "&Category="+ Eval("Category")) %>' />                        
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Subject">
                        <ItemTemplate>
                            <%# Eval("Subject") %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <br />
            <h3>Sales Auto Email Templates</h3>
            <asp:GridView ID="grdTemplates_SalesAutoEmail" runat="server"  AutoGenerateColumns="false" DataKeyNames="Id"
                CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" GridLines="Vertical">
                <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                <HeaderStyle CssClass="trHeader " />
                <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                <AlternatingRowStyle CssClass="AlternateRow " />
                <Columns>
                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink1" ForeColor="Blue" runat="server" Text='<%# Eval("Name") %>' 
                                NavigateUrl='<%# Page.ResolveUrl("~/Sr_App/edit-html-template.aspx?MasterId=" + Eval("Id") + 
                                                "&Type="+ Convert.ToByte(JG_Prospect.Common.HTMLTemplateTypes.AutoEmailTemplate).ToString() +
                                                "&Category="+ Eval("Category")) %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Subject">
                        <ItemTemplate>
                            <%# Eval("Subject") %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <br />
            <h3>Vendor Auto Email Templates</h3>
            <asp:GridView ID="grdTemplates_VendorAutoEmail" runat="server"  AutoGenerateColumns="false" DataKeyNames="Id"
                CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" GridLines="Vertical">
                <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                <HeaderStyle CssClass="trHeader " />
                <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                <AlternatingRowStyle CssClass="AlternateRow " />
                <Columns>
                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink2" ForeColor="Blue" runat="server" Text='<%# Eval("Name") %>' 
                                NavigateUrl='<%# Page.ResolveUrl("~/Sr_App/edit-html-template.aspx?MasterId=" + Eval("Id") + 
                                                "&Type="+ Convert.ToByte(JG_Prospect.Common.HTMLTemplateTypes.AutoEmailTemplate).ToString() +
                                                "&Category="+ Eval("Category")) %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Subject">
                        <ItemTemplate>
                            <%# Eval("Subject") %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <br />
            <h3>Templates</h3>
            <asp:Repeater ID="repTemplates_Template" runat="server" >
                <HeaderTemplate>
                    <ul style="display:block; width:100%;">
                </HeaderTemplate>
                <ItemTemplate>
                    <li style="float:left; width: 30%; padding: 10px 10px 10px 0px;">
                        <asp:HyperLink ID="hypEdit" ForeColor="Blue" runat="server" Text='<%# Eval("Name") %>' 
                                NavigateUrl='<%# Page.ResolveUrl("~/Sr_App/edit-html-template.aspx?MasterId=" + Eval("Id") + 
                                                "&Type="+ Convert.ToByte(JG_Prospect.Common.HTMLTemplateTypes.Template).ToString() +
                                                "&Category="+ Eval("Category")) %>' />
                    </li>
                </ItemTemplate>
                <FooterTemplate>
                    </ul>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
    <script type="text/javascript">
        $(document).ready(function () {
            GetComapnyAddress();
        });

        function GetComapnyAddress() {
            $.ajax({
                type: "POST",
                url: "html-template-maintainance.aspx/GetCompanyAddress",
                // data: "{'strZip':'" + $(".list_limit li[style*='background-color: lemonchiffon']").text() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "JSON",
                success: function (data) {
                    var response = JSON.parse(data.d);
                    $('#<%=hdnCompanyAddressId.ClientID%>').val(response.Table[0].intCompanyId);
                    $('#<%=txtCompanyAddress.ClientID%>').val(response.Table[0].strCompanyAddress);
                    $('#<%=txtCity.ClientID%>').val(response.Table[0].strCity);
                    $('#<%=txtZip.ClientID%>').val(response.Table[0].strZipCode);
                    $('#<%=txtState.ClientID%>').val(response.Table[0].strState);
                }
            });
        }
        function UpdateCompanyAddress() {
            var Id = $('#<%=hdnCompanyAddressId.ClientID%>').val();
            var CompanyAddress = $('#<%=txtCompanyAddress.ClientID%>').val();
            var CompanyCity = $('#<%=txtCity.ClientID%>').val();
            var CompanyState = $('#<%=txtState.ClientID%>').val();
            var CompanyZipCode = $('#<%=txtZip.ClientID%>').val();
            $.ajax({
                type: "POST",
                url: "html-template-maintainance.aspx/UpdateCompanyAddress",
                data: "{'Id':'" + Id + "','Address':'" + CompanyAddress + "','City':'" + CompanyCity + "','State':'" + CompanyState + "','ZipCode':'" + CompanyZipCode + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "JSON",
                success: function (data) {
                    if (data.d = 'Success') {
                        GetComapnyAddress();
                    }
                    else {
                        alert("Company address can not be updated. Please try later.");
                    }
                }
            });
        }
    </script>
</asp:Content>
