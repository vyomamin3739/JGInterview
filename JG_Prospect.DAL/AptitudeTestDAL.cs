using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.OleDb;

using System.Data.Common;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using JG_Prospect.DAL.Database;
using JG_Prospect.Common.modal;
using JG_Prospect.Common;
using System.Configuration;
using System.Data.SqlClient;

namespace JG_Prospect.DAL
{
    public class AptitudeTestDAL
    {
        private static AptitudeTestDAL m_AptitudeTestDAL = new AptitudeTestDAL();
        string constr = ConfigurationManager.ConnectionStrings["JGPA"].ConnectionString;

        private AptitudeTestDAL()
        {
          
        }

        public static AptitudeTestDAL Instance
        {
            get { return m_AptitudeTestDAL; }
            private set {; }
        }

        public DataTable GetPerformanceByUserID(int userID)
        {    
            string SQL = "select * from [MCQ_Performance] where UserID = '" + userID.ToString()+"'";

            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }
        }

        public DataTable GetcorrectAnswerByQuestionID(int questionID)
        {
            string SQL = "SELECT * FROM [MCQ_CorrectAnswer] where QuestionID = " + questionID.ToString();
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }
        }

        public bool InsertPerformance(int installUserID, int examID, int marksEarned, int totalMarks, float percentage, int status)
        { 
             try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_InsertPerfomace");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@installUserID", DbType.String, installUserID.ToString());
                    database.AddInParameter(command, "@examID", DbType.Int32, examID);
                    database.AddInParameter(command, "@marksEarned", DbType.Int32, marksEarned);
                    database.AddInParameter(command, "@totalMarks", DbType.Int32, totalMarks);
                    database.AddInParameter(command, "@Aggregate", DbType.Double, percentage);

                    database.ExecuteScalar(command);
                    //int res = Convert.ToInt32(database.GetParameterValue(command, "@result"));
                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;

            }
        }

        public DataTable GetQuestionsoptionByQustionID(int questionID)
        {
            string SQL = "SELECT *  FROM [MCQ_Option] WHERE QuestionID = " + questionID.ToString();
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }
        }

        public DataTable GetQuestionsByID(int questionID)
        {
            string SQL = "SELECT *  FROM [MCQ_Question] where QuestionID = " + questionID.ToString();
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }
        }

        public DataTable GetQuestionsForExamByID(string examID)
        {
           
            string SQL = "SELECT * FROM [MCQ_Question] WHERE ExamID = " + examID;

            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }

        }
        
        public DataTable GetExamByExamID(Enums.Aptitude_ExamType examType, int userID)
        {
            string SQL = "SELECT * FROM [MCQ_Exam] Ex WHERE ExamID NOT IN ( "
                        + "select ExamID from [MCQ_Performance] where UserID = "
                        + "'" + userID + "'"+")";

            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = SQL;
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        using (DataSet ds = new DataSet())
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
            }
        }

        public string GetExamDurationByID(string examID)
        {
            return "15";
        }

        public string GetExamNameByExamID(string examId)
        {
            string SQL = "select ExamTitle from [MCQ_Exam] WHERE ExamID =" + examId;
            //throw new NotImplementedException();
            return ".Net Aptitude Test";
        }
    }
}
