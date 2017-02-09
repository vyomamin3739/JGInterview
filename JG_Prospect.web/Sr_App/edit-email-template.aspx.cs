using JG_Prospect.App_Code;
using JG_Prospect.BLL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.Sr_App
{
    public partial class edit_email_template : System.Web.UI.Page
    {
        protected HTMLTemplates? HTMLTemplate
        {
            get
            {
                HTMLTemplates objHTMLTemplate;
                if (Enum.TryParse<HTMLTemplates>(Request["MasterId"], out objHTMLTemplate))
                {
                    return objHTMLTemplate;
                }
                return null;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            CommonFunction.AuthenticateUser();

            if (!IsPostBack)
            {
                if (this.HTMLTemplate.HasValue)
                {
                    ddlDesignation.DataSource = DesignationBLL.Instance.GetAllDesignation();
                    ddlDesignation.DataTextField = "DesignationName";
                    ddlDesignation.DataValueField = "ID";
                    ddlDesignation.DataBind();
                    ddlDesignation.Items.Insert(0, new ListItem("--Select--", "0"));

                    HTMLTemplatesMaster objHTMLTemplatesMaster = HTMLTemplateBLL.Instance.GetHTMLTemplateMasterById(this.HTMLTemplate.Value);

                    txtName.Text = objHTMLTemplatesMaster.Name;
                    txtSubject.Text = objHTMLTemplatesMaster.Subject;
                    txtHeader.Text = objHTMLTemplatesMaster.Header;
                    txtBody.Text = objHTMLTemplatesMaster.Body;
                    txtFooter.Text = objHTMLTemplatesMaster.Footer;
                    trMasterCopy.Visible = true;
                }
            }
        }

        protected void ddlDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlDesignation.SelectedIndex > 0)
            {
                DesignationHTMLTemplate objDesignationHTMLTemplate = HTMLTemplateBLL.Instance.GetDesignationHTMLTemplate(this.HTMLTemplate.Value, ddlDesignation.SelectedValue);

                txtSubject.Text = objDesignationHTMLTemplate.Subject;
                txtHeader.Text = objDesignationHTMLTemplate.Header;
                txtBody.Text = objDesignationHTMLTemplate.Body;
                txtFooter.Text = objDesignationHTMLTemplate.Footer;
                trMasterCopy.Visible = (objDesignationHTMLTemplate.Id == 0);
            }
            else
            {
                txtHeader.Text =
                txtBody.Text =
                txtFooter.Text =
                txtSubject.Text = string.Empty;
                trMasterCopy.Visible = false;
            }
        }

        protected void btnSaveTemplate_Click(object sender, EventArgs e)
        {
            DesignationHTMLTemplate objDesignationHTMLTemplate = new DesignationHTMLTemplate();
            objDesignationHTMLTemplate.HTMLTemplatesMasterId = (byte)this.HTMLTemplate.Value;
            objDesignationHTMLTemplate.Designation = ddlDesignation.SelectedValue;
            objDesignationHTMLTemplate.Subject = txtSubject.Text;
            objDesignationHTMLTemplate.Header = txtHeader.Text;
            objDesignationHTMLTemplate.Body = txtBody.Text;
            objDesignationHTMLTemplate.Footer = txtFooter.Text;
            if (HTMLTemplateBLL.Instance.SaveDesignationHTMLTemplate(objDesignationHTMLTemplate))
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Designation template updated.");
                Response.Redirect(Request.Url.ToString());
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Designation template can not be updated! Please try again later.");
            }
        }

        protected void btnRevertToMaster_Click(object sender, EventArgs e)
        {
            if (HTMLTemplateBLL.Instance.DeleteDesignationHTMLTemplate(this.HTMLTemplate.Value, ddlDesignation.SelectedValue))
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Designation template deleted.");
                Response.Redirect(Request.Url.ToString());
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Designation template can not be deleted! Please try again later.");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sr_App/email-template-maintainance.aspx");
        }
    }
}