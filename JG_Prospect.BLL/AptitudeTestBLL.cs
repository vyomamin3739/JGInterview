using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using JG_Prospect.Common.modal;
using JG_Prospect.DAL;
using System.Data;
using JG_Prospect.Common;

namespace JG_Prospect.BLL
{
   public class AptitudeTestBLL
    {
        private static AptitudeTestBLL m_AptitudeTestBLL = new AptitudeTestBLL();

        private AptitudeTestBLL()
        {
        }

        public static AptitudeTestBLL Instance
        {
            get { return m_AptitudeTestBLL; }
            set {; }
        }

        public DataTable GetPerformanceByUserID(int userID)
        {
            return AptitudeTestDAL.Instance.GetPerformanceByUserID(userID);
        }

        public DataTable GetExamByExamID(Enums.Aptitude_ExamType ExamType, int userID)
        {
            return AptitudeTestDAL.Instance.GetExamByExamID(ExamType,userID);
        }

        public string GetExamNameByExamID(string ExamId)
        {
            return AptitudeTestDAL.Instance.GetExamNameByExamID(ExamId);
        }

        public string GetExamDurationByID(string examID)
        {
            return AptitudeTestDAL.Instance.GetExamDurationByID(examID);
        }

        public DataTable GetQuestionsForExamByID(string examID)
        {
            return AptitudeTestDAL.Instance.GetQuestionsForExamByID(examID);
        }

        public DataTable GetQuestionsByID(int questionID)
        {
            return AptitudeTestDAL.Instance.GetQuestionsByID(questionID);
        }

        public DataTable GetcorrectAnswerByQuestionID(int questionID)
        {
            return AptitudeTestDAL.Instance.GetcorrectAnswerByQuestionID(questionID);
        }

        public DataTable GetQuestionsoptionByQustionID(int questionID)
        {
            return AptitudeTestDAL.Instance.GetQuestionsoptionByQustionID(questionID);
        }

        public bool InsertPerformance(int InstallUserID, int ExamID, int marksEarned, int totalMarks, float percentage, int Status)
        {
            return AptitudeTestDAL.Instance.InsertPerformance(InstallUserID, ExamID, marksEarned, totalMarks, percentage, Status);
        }
    }
}
