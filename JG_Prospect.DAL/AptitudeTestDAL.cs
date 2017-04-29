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
            private set { ; }
        }

        public DataTable GetPerformanceByUserID(int userID)
        {
            string SQL = "select * from [MCQ_Performance] where UserID = '" + userID.ToString() + "'";

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
                        + "'" + userID + "'" + ")";

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

        public DataTable GetMCQ_Exams(int? intDesignationID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetMCQ_Exams");
                    command.CommandType = CommandType.StoredProcedure;
                    if (intDesignationID.HasValue)
                    {
                        database.AddInParameter(command, "@DesignationID", DbType.Int32, intDesignationID.Value);
                    }
                    return database.ExecuteDataSet(command).Tables[0];
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public DataSet GetMCQ_ExamByID(Int64 intExamID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetMCQ_ExamByID");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ExamID", DbType.Int64, intExamID);
                    return database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public long InsertMCQ_Exam(MCQ_Exam objMCQ_Exam)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertMCQ_Exam");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@ExamTitle", DbType.String, objMCQ_Exam.ExamTitle);
                    database.AddInParameter(command, "@ExamDescription", DbType.String, objMCQ_Exam.ExamDescription);
                    database.AddInParameter(command, "@IsActive", DbType.Boolean, objMCQ_Exam.IsActive);
                    database.AddInParameter(command, "@CourseID", DbType.Int64, objMCQ_Exam.CourseID);
                    database.AddInParameter(command, "@ExamDuration", DbType.Int32, objMCQ_Exam.ExamDuration);
                    database.AddInParameter(command, "@PassPercentage", DbType.Decimal, objMCQ_Exam.PassPercentage);
                    database.AddInParameter(command, "@DesignationID", DbType.Int64, objMCQ_Exam.DesignationID);

                    return Convert.ToInt64(database.ExecuteScalar(command));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void UpdateMCQ_Exam(MCQ_Exam objMCQ_Exam)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateMCQ_Exam");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@ExamID", DbType.Int64, objMCQ_Exam.ExamID);
                    database.AddInParameter(command, "@ExamTitle", DbType.String, objMCQ_Exam.ExamTitle);
                    database.AddInParameter(command, "@ExamDescription", DbType.String, objMCQ_Exam.ExamDescription);
                    database.AddInParameter(command, "@IsActive", DbType.Boolean, objMCQ_Exam.IsActive);
                    database.AddInParameter(command, "@CourseID", DbType.Int64, objMCQ_Exam.CourseID);
                    database.AddInParameter(command, "@ExamDuration", DbType.Int32, objMCQ_Exam.ExamDuration);
                    database.AddInParameter(command, "@PassPercentage", DbType.Decimal, objMCQ_Exam.PassPercentage);
                    database.AddInParameter(command, "@DesignationID", DbType.Int64, objMCQ_Exam.DesignationID);

                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public long InsertMCQ_Question(MCQ_Question objMCQ_Question)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertMCQ_Question");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@Question", DbType.String, objMCQ_Question.Question);
                    database.AddInParameter(command, "@QuestionType", DbType.Int64, objMCQ_Question.QuestionType);
                    database.AddInParameter(command, "@PositiveMarks", DbType.Int64, objMCQ_Question.PositiveMarks);
                    database.AddInParameter(command, "@NegetiveMarks", DbType.Int64, objMCQ_Question.NegetiveMarks);
                    database.AddInParameter(command, "@PictureURL", DbType.String, objMCQ_Question.PictureURL);
                    database.AddInParameter(command, "@ExamID", DbType.Int64, objMCQ_Question.ExamID);
                    database.AddInParameter(command, "@AnswerTemplate", DbType.String, objMCQ_Question.AnswerTemplate);

                    return Convert.ToInt64(database.ExecuteScalar(command));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void UpdateMCQ_Question(MCQ_Question objMCQ_Question)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateMCQ_Question");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@QuestionID", DbType.Int64, objMCQ_Question.QuestionID);
                    database.AddInParameter(command, "@Question", DbType.String, objMCQ_Question.Question);
                    database.AddInParameter(command, "@QuestionType", DbType.Int64, objMCQ_Question.QuestionType);
                    database.AddInParameter(command, "@PositiveMarks", DbType.Int64, objMCQ_Question.PositiveMarks);
                    database.AddInParameter(command, "@NegetiveMarks", DbType.Int64, objMCQ_Question.NegetiveMarks);
                    database.AddInParameter(command, "@PictureURL", DbType.String, objMCQ_Question.PictureURL);
                    database.AddInParameter(command, "@ExamID", DbType.Int64, objMCQ_Question.ExamID);
                    database.AddInParameter(command, "@AnswerTemplate", DbType.String, objMCQ_Question.AnswerTemplate);

                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void DeleteMCQ_Question(long intQuestionID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("DeleteMCQ_Question");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@QuestionID", DbType.Int64, intQuestionID);

                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public long InsertMCQ_Option(MCQ_Option objMCQ_Option)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertMCQ_Option");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@OptionText", DbType.String, objMCQ_Option.OptionText);
                    database.AddInParameter(command, "@QuestionID", DbType.Int64, objMCQ_Option.QuestionID);

                    return Convert.ToInt64(database.ExecuteScalar(command));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void UpdateMCQ_Option(MCQ_Option objMCQ_Option)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateMCQ_Option");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@OptionText", DbType.String, objMCQ_Option.OptionText);
                    database.AddInParameter(command, "@QuestionID", DbType.Int64, objMCQ_Option.QuestionID);

                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public long InsertMCQ_CorrectAnswer(MCQ_Option objMCQ_Option)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertMCQ_CorrectAnswer");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@OptionText", DbType.String, objMCQ_Option.OptionText);
                    database.AddInParameter(command, "@QuestionID", DbType.Int64, objMCQ_Option.QuestionID);

                    return Convert.ToInt64(database.ExecuteScalar(command));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void UpdateMCQ_CorrectAnswer(MCQ_Option objMCQ_Option)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateMCQ_CorrectAnswer");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@OptionText", DbType.String, objMCQ_Option.OptionText);
                    database.AddInParameter(command, "@QuestionID", DbType.Int64, objMCQ_Option.QuestionID);

                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
