using JG_Prospect.App_Code;
using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.Sr_App
{
    public partial class manage_aptitude_tests : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            CommonFunction.AuthenticateUser();

            if (!IsPostBack)
            {
                FillddlDesignation();
                FillrepExams();
            }
        }

        private void FillddlDesignation()
        {
            List<Designation> lstDesignations = DesignationBLL.Instance.GetAllDesignation();
            if (lstDesignations != null && lstDesignations.Any())
            {
                ddlDesignation.DataSource = lstDesignations;
                ddlDesignation.DataTextField = "DesignationName";
                ddlDesignation.DataValueField = "ID";
                ddlDesignation.DataBind();
            }
            ddlDesignation.Items.Insert(0, new ListItem("--All--", "0"));
        }

        private void FillrepExams()
        {
            DataTable dtExams = null;
            if (ddlDesignation.SelectedValue == "0")
            {
                dtExams = AptitudeTestBLL.Instance.GetMCQ_Exams(null);
            }
            else
            {
                dtExams = AptitudeTestBLL.Instance.GetMCQ_Exams(Convert.ToInt32(ddlDesignation.SelectedValue));
            }

            grdExams.DataSource = dtExams;
            grdExams.DataBind();

            upExams.Update();
        }

        protected void ddlDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            FillrepExams();
        }
    }
}