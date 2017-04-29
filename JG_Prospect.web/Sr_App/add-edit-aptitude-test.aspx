<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="add-edit-aptitude-test.aspx.cs"
    Inherits="JG_Prospect.Sr_App.add_edit_aptitude_test" %>

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
        <h1>
            <asp:Literal ID="ltrlPageHeader" runat="server" /></h1>
        <div class="form_panel_custom">
            <asp:ValidationSummary ID="vsExam" runat="server" ValidationGroup="vgExam" ShowMessageBox="true" ShowSummary="false" />
            <table class="aptitude-test" width="100%" cellpadding="0" cellspacing="3" border="0">
                <tr>
                    <th width="80" class="noborder">Title:</th>
                    <td>
                        <asp:TextBox ID="txtTitle" runat="server" MaxLength="200" Width="250" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" InitialValue="" ValidationGroup="vgExam"
                            ErrorMessage="Please enter Title." Display="None" />
                        &nbsp;
                        <asp:CheckBox ID="chkActive" runat="server" Text="Active?" TextAlign="Left" /></td>
                    <th width="120" align="right" class="noborder">Duration:</th>
                    <td width="15">
                        <asp:TextBox ID="txtDuration" runat="server" Width="15" MaxLength="3" onkeypress="return IsNumeric(event, true);" onpatse="return false;" />
                        <asp:RequiredFieldValidator ID="rfvDuration" runat="server" ControlToValidate="txtDuration" InitialValue="" ValidationGroup="vgExam"
                            ErrorMessage="Please enter Duration." Display="None" />
                    </td>
                </tr>
                <tr>
                    <th class="noborder">Description:</th>
                    <td>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" Width="100%" />
                        <asp:RequiredFieldValidator ID="rfvDescription" runat="server" ControlToValidate="txtDescription" InitialValue="" ValidationGroup="vgExam"
                            ErrorMessage="Please enter Description." Display="None" /></td>
                    <th class="noborder" align="right">Pass Percentage:</th>
                    <td>
                        <asp:TextBox ID="txtPassPercentage" runat="server" Width="15" MaxLength="3" onkeypress="return IsNumeric(event, true);" onpatse="return false;" />
                        <asp:RequiredFieldValidator ID="rfvPassPercentage" runat="server" ControlToValidate="txtPassPercentage" InitialValue="" ValidationGroup="vgExam"
                            ErrorMessage="Please enter Pass Percentage." Display="None" />
                    </td>
                </tr>
                <tr>
                    <th class="noborder">Designation:</th>
                    <td>
                        <asp:DropDownList ID="ddlDesignation" runat="server" />
                        <asp:RequiredFieldValidator ID="rfvDesignation" runat="server" ControlToValidate="ddlDesignation" InitialValue="0" ValidationGroup="vgExam"
                            ErrorMessage="Please select Designation." Display="None" />
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td colspan="4">
                        <h4>Questions:</h4>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <table width="100%" cellpadding="0" cellspacing="3" border="0">
                            <tr>
                                <td>
                                    <asp:UpdatePanel ID="upQuestions" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:Repeater ID="repQuestions" runat="server">
                                                <HeaderTemplate>
                                                    <table class="question-list" width="100%" cellpadding="0" cellspacing="0" border="0">
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <tr class="question">
                                                        <td width="15" align="center" valign="top">
                                                            <%# (Container.ItemIndex + 1) + "." %>
                                                        </td>
                                                        <td valign="top">
                                                            <asp:HiddenField ID="hdnQuestionID" runat="server" Value='<%# Eval("QuestionID") %>' />
                                                            <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" Rows="2" Width="100%"
                                                                Text='<%# Eval("Question") %>' />
                                                            <asp:RequiredFieldValidator ID="rfvQuestion" runat="server" ControlToValidate="txtQuestion" InitialValue="" ValidationGroup="vgExam"
                                                                ErrorMessage='<%# "Please enter Question " + (Container.ItemIndex + 1) + "." %>' Display="None" />
                                                        </td>
                                                        <td width="250" valign="top" align="right">
                                                            <b>Positive Marks</b> :
                                                    <asp:TextBox ID="txtPositiveMarks" runat="server" Width="15" Text='<%# Eval("PositiveMarks") %>' onkeypress="return IsNumeric(event, true);" onpatse="return false;" />
                                                            <b>Negetive Marks</b> :
                                                    <asp:TextBox ID="txtNegetiveMarks" runat="server" Width="15" Text='<%# Eval("NegetiveMarks") %>' onkeypress="return IsNumeric(event, true);" onpatse="return false;" />
                                                            <asp:RequiredFieldValidator ID="rfvPositiveMarks" runat="server" ControlToValidate="txtPositiveMarks" InitialValue="" ValidationGroup="vgExam"
                                                                ErrorMessage="Please enter Positive Marks." Display="None" />
                                                            <asp:RequiredFieldValidator ID="rfvNegetiveMarks" runat="server" ControlToValidate="txtNegetiveMarks" InitialValue="" ValidationGroup="vgExam"
                                                                ErrorMessage="Please enter Negetive Marks." Display="None" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3">
                                                            <asp:Repeater ID="repOptions" runat="server" DataSource='<%# GetOptionsByQuestionID(Convert.ToInt64(Eval("QuestionID"))) %>'>
                                                                <HeaderTemplate>
                                                                    <ol class="option-list">
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <li class='<%# IsCorrectAnswer(Convert.ToInt64(Eval("QuestionID")), Convert.ToInt64(Eval("OptionID")))? "answer": "" %>'>
                                                                        <asp:HiddenField ID="hdnOptionID" runat="server" Value='<%# Eval("OptionID") %>' />
                                                                        <asp:TextBox ID="txtOptionText" runat="server" Width="200" Text='<%# Eval("OptionText") %>' />&nbsp;
                                                                <asp:RadioButton ID="rdoIsAnswer" runat="server" GroupName='<%# "Q" + Eval("QuestionID") %>'
                                                                    Checked='<%# IsCorrectAnswer(Convert.ToInt64(Eval("QuestionID")), Convert.ToInt64(Eval("OptionID")))%>' />
                                                                        <asp:RequiredFieldValidator ID="rfvOptionText" runat="server" ControlToValidate="txtOptionText" InitialValue="" ValidationGroup="vgExam"
                                                                            ErrorMessage='<%# "Please enter Option " + (Container.ItemIndex + 1) + "." %>' Display="None" />
                                                                    </li>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </ol>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </td>
                                                    </tr>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    </table>
                                                </FooterTemplate>
                                            </asp:Repeater>
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="lbtnAddQuestion" EventName="Click" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:LinkButton ID="lbtnAddQuestion" runat="server" Text="Add Question" OnClick="lbtnAddQuestion_Click" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <div class="btn_sec">
                            <asp:Button ID="btnSaveExam" runat="server" Text="Save Exam" CssClass="ui-button" ValidationGroup="vgExam" OnClick="btnSaveExam_Click" />
                        </div>
                    </td>
                    <td align="rigt">
                        <a href='<%=Page.ResolveUrl("~/sr_app/manage-aptitude-tests.aspx") %>'>Aptitude Tests</a>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <script type="text/javascript">
        function rdoIsAnswer_Click(sender) {
            var $sender = $(sender);
            $('input[data-id="' + $sender.attr('data-id') + '"]').prop('checked', false);
            $sender.prop('checked', true);
        }
    </script>
</asp:Content>
