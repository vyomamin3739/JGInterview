using System;
using System.Data;
using System.Drawing;
using JG_Prospect.BLL;
using JG_Prospect.Common;

namespace JG_Prospect.MCQTest
{
    public partial class McqTestPage : System.Web.UI.Page
    {

        int UserID = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["ID"] != null)
                if (Session["ID"].ToString() != "")
                {
                    UserID = Convert.ToInt32(Session["ID"]);
                    populateLabel();
                    populatePerformanceArea();
                }
        }

        private void populatePerformanceArea()
        {
            DataTable performanceTable = AptitudeTestBLL.Instance.GetPerformanceByUserID(UserID);
            string buffer = "<table class='tblResult' bgcolor=white border=1>";

            if (performanceTable.Rows.Count > 0)
            {
                buffer += "<tr><td><b>Exam Title</b></td><td><b>Marks Earned</b></td><td><b>Total Marks</b></td><td><b>Aggregate</b></td></tr>";

                //for (int i = 0; i < performanceTable.Rows.Count; i++)
                foreach (DataRow row in performanceTable.Rows)
                {   
                    String examName = AptitudeTestBLL.Instance.GetExamNameByExamID(row["ExamID"].ToString());
                    String studentName = row["UserID"].ToString();
                    String aggregate = row["Aggregate"].ToString();
                    String marksEarned = row["MarksEarned"].ToString();
                    String totalMarks = row["TotalMarks"].ToString();
                    
                    buffer += "<tr><td>" + examName + "</td><td>" + marksEarned + "</td><td>" + totalMarks + "</td><td>" + aggregate + "</td></tr>";
                }

                buffer += "</table>";
                lblSPI.Text = buffer;
                //performanceAdapter.Fill(perfTable);
            }
        }

        private void populateLabel()
        {
            DataTable examsNotWrittenYet = AptitudeTestBLL.Instance.GetExamByExamID(Enums.Aptitude_ExamType.DotNet ,UserID);

            if (examsNotWrittenYet.Rows.Count == 0)
            {
                Label1.ForeColor = Color.DarkBlue;
                Label1.Text = "";
            }
            else
            {
                string buff = "<table class='tblExamStartup' bgcolor=white>";

                foreach (DataRow ExamRow in examsNotWrittenYet.Rows)
                {
                    if (Enums.Aptitude_ExamType.DotNet.GetHashCode() == (int)ExamRow["ExamType"])
                    {
                        String url = "StartExam";
                        buff += "<tr><td>Click on following link to Start Exam ";
                        buff += "</Br></Br></Br>";
                        buff += "<b><a href=" + url + ".aspx?exam_id=" + ExamRow["ExamID"].ToString() + ">" + ExamRow["ExamTitle"] + "</a></b></td>";
                        buff += "</tr>";
                        buff += "<tr><td> </Br></Br>" + ExamRow["ExamDescription"] + "</td>";
                        buff += "</Br></Br></Br></tr>";
                    }

                    buff += "</table>";
                    Label1.Text = buff;
                }
            }



        }
    }
}