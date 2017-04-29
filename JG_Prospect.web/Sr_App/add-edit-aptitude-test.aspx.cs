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
    public partial class add_edit_aptitude_test : System.Web.UI.Page
    {
        DataTable dtExam = null;

        public DataTable Questions
        {
            get
            {
                if (ViewState["Questions"] == null)
                {
                    return null;
                }

                return (DataTable)ViewState["Questions"];
            }
            set
            {
                ViewState["Questions"] = value;
            }
        }

        public DataTable Options
        {
            get
            {
                if (ViewState["Options"] == null)
                {
                    return null;
                }

                return (DataTable)ViewState["Options"];
            }
            set
            {
                ViewState["Options"] = value;
            }
        }

        public Int64 ExamID
        {
            get
            {

                if (string.IsNullOrEmpty(Request.QueryString["ExamID"]))
                {
                    return 0;
                }

                return Convert.ToInt64(Request.QueryString["ExamID"]);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            CommonFunction.AuthenticateUser();

            if (!IsPostBack)
            {
                FillddlDesignation();

                if (this.ExamID > 0)
                {
                    ltrlPageHeader.Text = "Edit Aptitude Test";

                    DataSet dsExam = AptitudeTestBLL.Instance.GetMCQ_ExamByID(this.ExamID);

                    if (dsExam != null && dsExam.Tables.Count > 0)
                    {
                        dtExam = dsExam.Tables[0];

                        if (dtExam.Rows.Count > 0)
                        {
                            txtTitle.Text = Convert.ToString(dtExam.Rows[0]["ExamTitle"]);
                            txtDescription.Text = Convert.ToString(dtExam.Rows[0]["ExamDescription"]);
                            txtDuration.Text = Convert.ToString(dtExam.Rows[0]["ExamDuration"]);
                            txtPassPercentage.Text = Convert.ToString(dtExam.Rows[0]["PassPercentage"]);
                            chkActive.Checked = Convert.ToBoolean(dtExam.Rows[0]["IsActive"]);
                            ddlDesignation.SelectedValue = Convert.ToString(dtExam.Rows[0]["DesignationID"]);

                            if (dsExam.Tables.Count > 1)
                            {
                                Questions = dsExam.Tables[1];

                                if (dsExam.Tables.Count > 2)
                                {
                                    Options = dsExam.Tables[2];
                                }

                                repQuestions.DataSource = Questions;
                                repQuestions.DataBind();
                            }
                        }
                    }
                }
                else
                {
                    ltrlPageHeader.Text = "Add Aptitude Test";
                }
            }
        }

        protected DataTable GetOptionsByQuestionID(Int64 intQuestionID)
        {
            if (Options == null)
            {
                DataTable dtOptions = new DataTable();
                dtOptions.Columns.Add("OptionID", typeof(long));
                dtOptions.Columns.Add("OptionText", typeof(string));
                dtOptions.Columns.Add("QuestionID", typeof(long));

                Options = dtOptions;

                for (var i = 0; i < 4; i++)
                {
                    DataRow drOption = Options.NewRow();
                    drOption["OptionID"] = 0;
                    drOption["QuestionID"] = 0;
                    drOption["OptionText"] = "";
                    Options.Rows.Add(drOption);
                }

                return Options;
            }
            else
            {
                DataView dvOptions = Options.DefaultView;

                dvOptions.RowFilter = string.Format("QuestionID = {0}", intQuestionID);

                return dvOptions.ToTable();
            }
        }

        protected bool IsCorrectAnswer(Int64 intQuestionID, Int64 intOptionID)
        {
            if (Options != null)
            {
                DataView dvQuestions = Questions.DefaultView;

                dvQuestions.RowFilter = string.Format("QuestionID = {0} AND AnswerOptionID = {1}", intQuestionID, intOptionID);

                return (dvQuestions.ToTable().Rows.Count == 1);
            }

            return false;
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

        private MCQ_Exam GetMCQ_Exam()
        {
            MCQ_Exam objMCQ_Exam = new MCQ_Exam();
            objMCQ_Exam.ExamID = this.ExamID;
            objMCQ_Exam.CourseID = 0;
            objMCQ_Exam.DesignationID = Convert.ToInt32(ddlDesignation.SelectedValue);
            objMCQ_Exam.ExamDescription = txtDescription.Text.Trim();
            objMCQ_Exam.ExamDuration = Convert.ToInt32(txtDuration.Text.Trim());
            objMCQ_Exam.ExamTitle = txtTitle.Text.Trim();
            objMCQ_Exam.IsActive = chkActive.Checked;
            objMCQ_Exam.PassPercentage = (float)Convert.ToDecimal(txtPassPercentage.Text.Trim());
            return objMCQ_Exam;
        }

        protected void btnSaveExam_Click(object sender, EventArgs e)
        {
            MCQ_Exam objMCQ_Exam = GetMCQ_Exam();

            if (objMCQ_Exam.ExamID > 0)
            {
                AptitudeTestBLL.Instance.UpdateMCQ_Exam(objMCQ_Exam);
            }
            else
            {
                objMCQ_Exam.ExamID = AptitudeTestBLL.Instance.InsertMCQ_Exam(objMCQ_Exam);
            }

            foreach (RepeaterItem riQuestion in repQuestions.Items)
            {
                MCQ_Question objMCQ_Question = new MCQ_Question();
                objMCQ_Question.ExamID = objMCQ_Exam.ExamID;
                objMCQ_Question.QuestionID = Convert.ToInt64((riQuestion.FindControl("hdnQuestionID") as HiddenField).Value.Trim());
                objMCQ_Question.Question = (riQuestion.FindControl("txtQuestion") as TextBox).Text.Trim();
                objMCQ_Question.PositiveMarks = Convert.ToInt64((riQuestion.FindControl("txtPositiveMarks") as TextBox).Text.Trim());
                objMCQ_Question.NegetiveMarks = Convert.ToInt64((riQuestion.FindControl("txtNegetiveMarks") as TextBox).Text.Trim());
                objMCQ_Question.QuestionType = 1;

                if (objMCQ_Question.QuestionID > 0)
                {
                    AptitudeTestBLL.Instance.UpdateMCQ_Question(objMCQ_Question);
                }
                else
                {
                    objMCQ_Question.QuestionID = AptitudeTestBLL.Instance.InsertMCQ_Question(objMCQ_Question);
                }

                Repeater repOptions = (riQuestion.FindControl("repOptions") as Repeater);

                foreach (RepeaterItem riOptions in repOptions.Items)
                {
                    MCQ_Option objMCQ_Option = new MCQ_Option();
                    objMCQ_Option.OptionID = Convert.ToInt64((riOptions.FindControl("hdnOptionID") as HiddenField).Value.Trim());
                    objMCQ_Option.OptionText = (riOptions.FindControl("txtOptionText") as TextBox).Text.Trim();
                    objMCQ_Option.QuestionID = objMCQ_Question.QuestionID;

                    if (objMCQ_Option.OptionID > 0)
                    {
                        AptitudeTestBLL.Instance.UpdateMCQ_Option(objMCQ_Option);

                        if ((riOptions.FindControl("rdoIsAnswer") as RadioButton).Checked)
                        {
                            AptitudeTestBLL.Instance.UpdateMCQ_CorrectAnswer(objMCQ_Option);
                        }
                    }
                    else
                    {
                        objMCQ_Option.OptionID = AptitudeTestBLL.Instance.InsertMCQ_Option(objMCQ_Option);

                        if ((riOptions.FindControl("rdoIsAnswer") as RadioButton).Checked)
                        {
                            AptitudeTestBLL.Instance.InsertMCQ_CorrectAnswer(objMCQ_Option);
                        }
                    }
                }
            }
        }

        protected void lbtnAddQuestion_Click(object sender, EventArgs e)
        {
            if (Questions == null)
            {
                DataTable dtQuestion = new DataTable();
                dtQuestion.Columns.Add("QuestionID", typeof(long));
                dtQuestion.Columns.Add("Question", typeof(string));
                dtQuestion.Columns.Add("QuestionType", typeof(long));
                dtQuestion.Columns.Add("PositiveMarks", typeof(long));
                dtQuestion.Columns.Add("NegetiveMarks", typeof(long));
                dtQuestion.Columns.Add("PictureURL", typeof(string));
                dtQuestion.Columns.Add("ExamID", typeof(long));
                dtQuestion.Columns.Add("AnswerTemplate", typeof(string));

                Questions = dtQuestion;
            }

            DataRow drQuestion = Questions.NewRow();
            drQuestion["QuestionID"] = 0;
            Questions.Rows.Add(drQuestion);

            repQuestions.DataSource = Questions;
            repQuestions.DataBind();

            upQuestions.Update();
        }
    }
}