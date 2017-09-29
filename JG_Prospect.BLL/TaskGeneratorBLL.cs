using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using JG_Prospect.DAL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System.Data;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System.Data.Common;
using JG_Prospect.DAL.Database;

namespace JG_Prospect.BLL
{
    public class TaskGeneratorBLL
    {
        private static TaskGeneratorBLL m_TaskGeneratorBLL = new TaskGeneratorBLL();

        private TaskGeneratorBLL()
        {

        }

        public static TaskGeneratorBLL Instance
        {
            get { return m_TaskGeneratorBLL; }
            set {; }
        }

        #region "-- Task Sequences --"

        public DataSet GetAllTasksforSubSequencing(Int32 DesignationId, String DesiSeqCode, bool IsTechTask, Int64 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetAllTasksforSubSequencing(DesignationId,DesiSeqCode,IsTechTask,TaskId);

        }

        public DataSet GetLatestTaskSequence(Int32 DesignationId, bool IsTechTask)
        {
            return TaskGeneratorDAL.Instance.GetLatestTaskSequence(DesignationId, IsTechTask);
        }

        public DataSet GetAllTaskWithSequence(Int32 page, Int32 pageSize, String DesignationIds, bool IsTechTask, Int64 HighlightedTaskID)
        {
            return TaskGeneratorDAL.Instance.GetAllTaskWithSequence(page, pageSize, DesignationIds, IsTechTask, HighlightedTaskID);
        }


        public int UpdateTaskSequence(Int64 Sequence, Int64 TaskID, Int32 DesignationID, bool IsTechTask)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskSequence(Sequence, TaskID, DesignationID, IsTechTask);

        }

        public DataSet GetInterviewDateSequences(Int32 DesignationId, Int32 UserCount)
        {
            return TaskGeneratorDAL.Instance.GetInterviewDateSequences(DesignationId,UserCount);

        }

        public bool UpdateTaskSubSequence(Int64 TaskID, Int64 TaskIdSeq, Int64 SubSeqTaskId, Int64 DesignationId)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskSubSequence( TaskID,  TaskIdSeq,  SubSeqTaskId,   DesignationId);

        }

        #endregion
        public Int64 SaveOrDeleteTask(Task objTask, int TaskLevel, int maintaskid)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTask(objTask, TaskLevel, maintaskid);
        }

        public DataSet GetTaskByMaxId(string parentTaskid, short taskLVL)
        {
            return TaskGeneratorDAL.Instance.GetTaskByMaxId(parentTaskid, taskLVL);
        }

        public bool SaveTaskDesignations(UInt64 TaskId, String strDesignations, String TaskIDCode)
        {
            return TaskGeneratorDAL.Instance.SaveTaskDesignations(TaskId, strDesignations, TaskIDCode);
        }
        public bool SaveTaskAssignedUsers(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.SaveTaskAssignedUsers(TaskId, UserIds);
        }

        public bool SetTaskStatus(int TaskId, string TaskStatus)
        {
            return TaskGeneratorDAL.Instance.SetTaskStatus(TaskId, TaskStatus);
        }

        public bool SaveTaskAssignedToMultipleUsers(UInt64 TaskId, String UserId)
        {
            return TaskGeneratorDAL.Instance.SaveTaskAssignedToMultipleUsers(TaskId, UserId);
        }
        public bool SaveTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.SaveTaskAssignmentRequests(TaskId, UserIds);
        }
        public bool AcceptTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.AcceptTaskAssignmentRequests(TaskId, UserIds);
        }

        public bool UpdateTaskAcceptance(ref TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskUserAcceptance(ref objTaskUser);
        }

        public bool TaskSwapSequence(Int64 FirstSequenceId, Int64 SecondSequenceId, Int64 FirstTaskId, Int64 SecondTaskId)
        {
            return TaskGeneratorDAL.Instance.TaskSwapSequence(FirstSequenceId, SecondSequenceId, FirstTaskId, SecondTaskId);
        }

        public bool TaskSwapSubSequence(Int64 FirstSequenceId, Int64 SecondSequenceId, Int64 FirstTaskId, Int64 SecondTaskId)
        {
            return TaskGeneratorDAL.Instance.TaskSwapSubSequence(FirstSequenceId, SecondSequenceId, FirstTaskId, SecondTaskId);
        }

        public bool DeleteTaskSequence(Int64 TaskId)
        {
            return TaskGeneratorDAL.Instance.DeleteTaskSequence(TaskId);
        }
        public bool DeleteTaskSubSequence(Int64 TaskId)
        {
            return TaskGeneratorDAL.Instance.DeleteTaskSubSequence(TaskId);
        }
        public bool SaveOrDeleteTaskUserFiles(TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTaskUserFiles(objTaskUser);
        }

        public bool DeleteTaskUserFile(Int64 Id)
        {
            return TaskGeneratorDAL.Instance.DeleteTaskUserFile(Id);
        }

        public DataSet GetTaskDetails(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetTaskDetails(TaskId);
        }

        public DataSet GetSubTasks(Int32 TaskId, bool blIsAdmin, string strSortExpression, string vsearch = "", Int32? intPageIndex = 0, Int32? intPageSize = 0, int intHighlightTaskId = 0)
        {
            return TaskGeneratorDAL.Instance.GetSubTasks(TaskId, blIsAdmin, strSortExpression, vsearch, intPageIndex, intPageSize, intHighlightTaskId);
        }

        public DataSet GetTaskUserFiles(Int32 TaskId, JGConstant.TaskFileDestination? objTaskFileDestination, Int32? intPageIndex, Int32? intPageSize)
        {
            return TaskGeneratorDAL.Instance.GetTaskUserFiles(TaskId, objTaskFileDestination, intPageIndex, intPageSize);
        }

        public DataSet GetTaskUserDetails(Int16 Mode)
        {
            return TaskGeneratorDAL.Instance.GetTaskUserDetails(Mode);
        }

        public DataSet GetInstallUsers(int key, string Designation)
        {
            return TaskGeneratorDAL.Instance.GetInstallUsers(key, Designation);
        }

        public DataSet GetInstallUserswithIds(int key, string Designation, string TaskId)
        {
            return TaskGeneratorDAL.Instance.GetInstallUserswithIds(key, Designation, TaskId);
        }

        public DataSet GetAllActiveTechTask()
        {
            return TaskGeneratorDAL.Instance.GetAllActiveTechTask();
        }

        public DataSet GetUserDetails(Int32 Id)
        {
            return TaskGeneratorDAL.Instance.GetUserDetails(Id);
        }

        public DataSet GetInstallUserDetails(Int32 Id)
        {
            return TaskGeneratorDAL.Instance.GetInstallUserDetails(Id);
        }

        public DataTable GetTaskDetailsForMail(Int32 Id)
        {
            return TaskGeneratorDAL.Instance.GetTaskDetailsForMail(Id);
        }

        public DataSet GetTaskSearchAutoSuggestion(String searchTerm)
        {
            return TaskGeneratorDAL.Instance.GetTaskSearchAutoSuggestion(searchTerm);
        }

        public DataSet GetTasksList(int? UserID, string Title, string Designation, Int16? Status, DateTime? CreatedFrom, DateTime? CreatedTo, string Statuses, string Designations, bool isAdmin, int Start, int PageLimit, string strSortExpression)
        {
            return TaskGeneratorDAL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedFrom, CreatedTo, Statuses, Designations, isAdmin, Start, PageLimit, strSortExpression);
        }

        public DataSet GetAllUsersNDesignationsForFilter()
        {
            return TaskGeneratorDAL.Instance.GetAllUsersNDesignationsForFilter();
        }

        public int UpdateTaskStatus(Task objTask)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskStatus(objTask);
        }

        public DataSet GetAllActiveTechTaskForDesignationID(int iDesignationID)
        {
            return TaskGeneratorDAL.Instance.GetAllActiveTechTaskForDesignationID(iDesignationID);
        }

        public int UpdateTaskPriority(Task objTask)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskPriority(objTask);
        }

        public bool DeleteTask(UInt64 TaskId)
        {
            return TaskGeneratorDAL.Instance.DeleteTask(TaskId);
        }

        public bool SaveOrDeleteTaskNotes(ref TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTaskNotes(ref objTaskUser);
        }

        public bool SaveTaskDescription(Int64 TaskId, String TaskDescription)
        {
            return TaskGeneratorDAL.Instance.SaveTaskDescription(TaskId, TaskDescription);
        }

        public bool UpadateTaskNotes(ref TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.UpadateTaskNotes(ref objTaskUser);
        }

        public bool UpdateTaskUiRequested(Int64 intTaskId, bool blUiRequesed)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskUiRequested(intTaskId, blUiRequesed);
        }

        public bool UpdateTaskTechTask(Int64 intTaskId, bool blTechTask)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskTechTask(intTaskId, blTechTask);
        }

        #region TaskWorkSpecification

        public int InsertTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            return TaskGeneratorDAL.Instance.InsertTaskWorkSpecification(objTaskWorkSpecification);
        }

        public int UpdateTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskWorkSpecification(objTaskWorkSpecification);
        }

        public int UpdateTaskTitleById(string tid, string title)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskTitleById(tid, title);
        }

        public int UpdateTaskURLById(string tid, string URL)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskURLById(tid, URL);
        }

        public int UpdateTaskDescriptionById(string tid, string Description)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskDescriptionById(tid, Description);
        }

        public int DeleteTaskWorkSpecification(long intTaskWorkSpecification)
        {
            return TaskGeneratorDAL.Instance.DeleteTaskWorkSpecification(intTaskWorkSpecification);
        }

        public DataSet GetTaskWorkSpecifications(Int32 TaskId, bool blIsAdmin, Int64? intParentTaskWorkSpecificationId, Int32? intPageIndex, Int32? intPageSize)
        {
            return TaskGeneratorDAL.Instance.GetTaskWorkSpecifications(TaskId, blIsAdmin, intParentTaskWorkSpecificationId, intPageIndex, intPageSize);
        }

        public TaskWorkSpecification GetTaskWorkSpecificationById(Int64 Id)
        {
            return TaskGeneratorDAL.Instance.GetTaskWorkSpecificationById(Id);
        }

        public int UpdateTaskWorkSpecificationStatusByTaskId(TaskWorkSpecification objTaskWorkSpecification, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskWorkSpecificationStatusByTaskId(objTaskWorkSpecification, blIsAdmin, blIsTechLead, blIsUser);
        }

        public int UpdateTaskWorkSpecificationStatusById(TaskWorkSpecification objTaskWorkSpecification, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskWorkSpecificationStatusById(objTaskWorkSpecification, blIsAdmin, blIsTechLead, blIsUser);
        }

        public DataSet GetPendingTaskWorkSpecificationCount(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetPendingTaskWorkSpecificationCount(TaskId);
        }

        public bool IsTaskWorkSpecificationApproved(Int32 TaskId)
        {
            int intPendingCount = 0;

            DataSet dsTaskSpecificationStatus = TaskGeneratorBLL.Instance.GetPendingTaskWorkSpecificationCount(TaskId);
            if (dsTaskSpecificationStatus.Tables.Count > 1 && dsTaskSpecificationStatus.Tables[1].Rows.Count > 0)
            {
                intPendingCount = Convert.ToInt32(dsTaskSpecificationStatus.Tables[1].Rows[0]["PendingRecordCount"]);
            }

            return (intPendingCount == 0);
        }

        #endregion

        public int UpdateSubTaskStatusById(Task objTask, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            return TaskGeneratorDAL.Instance.UpdateSubTaskStatusById(objTask, blIsAdmin, blIsTechLead, blIsUser);
        }

        public DataSet GetPendingSubTaskCount(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetPendingSubTaskCount(TaskId);
        }


        public DataSet GetTaskHierarchy(long? intTaskID, bool isAdmin)
        {
            return TaskGeneratorDAL.Instance.GetTaskHierarchy(intTaskID, isAdmin);
        }

        public bool AcceptUserAssignedWithSequence(Int64 SequenceId)
        {
            return TaskGeneratorDAL.Instance.AcceptUserAssignedWithSequence(SequenceId);
        }
        
        public DataSet GetDesignationTaskToAssignWithSequence(Int32 DesignationId, bool IsTechTask)
        {
            return TaskGeneratorDAL.Instance.GetDesignationTaskToAssignWithSequence(DesignationId, IsTechTask);
        }

        public DataSet GetUserAssignedWithSequence(Int32 DesignationId, bool IsTechTask, Int32 UserID)
        {
            return TaskGeneratorDAL.Instance.GetUserAssignedWithSequence(DesignationId, IsTechTask, UserID);
        }

        public DataSet RejectUserAssignedWithSequence(Int64 SequenceID, Int32 UserID, Int32 RejectedUserID)
        {
            return TaskGeneratorDAL.Instance.RejectUserAssignedWithSequence(SequenceID, UserID, RejectedUserID);
        }

        public Boolean InsertAssignedDesignationTaskWithSequence(Int32 DesignationId, bool IsTechTask, Int64 AssignedSequence, Int64 TaskId, Int32 UserId)
        {
            return TaskGeneratorDAL.Instance.InsertAssignedDesignationTaskWithSequence(DesignationId, IsTechTask, AssignedSequence, TaskId, UserId);

        }


        #region TaskAcceptance

        public DataSet GetTaskAcceptances(Int64 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetTaskAcceptances(TaskId);
        }

        public int InsertTaskAcceptance(TaskAcceptance objTaskAcceptance)
        {
            return TaskGeneratorDAL.Instance.InsertTaskAcceptance(objTaskAcceptance);
        }

        #endregion

        #region TaskApprovals

        public int InsertTaskApproval(TaskApproval objTaskApproval)
        {
            return TaskGeneratorDAL.Instance.InsertTaskApproval(objTaskApproval);
        }

        public int UpdateTaskApproval(TaskApproval objTaskApproval)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskApproval(objTaskApproval);
        }


        //--------- Start DP -----------
        public DataSet GetInProgressTasks(string userid, string desigid, string vSearch, int pageindex, int pagesize)
        {
            return TaskGeneratorDAL.Instance.GetInProgressTasks(userid, desigid, vSearch, pageindex, pagesize);
        }

        public DataSet GetClosedTasks(string userid, string desigid, string vSearch, int pageindex, int pagesize)
        {
            return TaskGeneratorDAL.Instance.GetClosedTasks(userid, desigid, vSearch, pageindex, pagesize);
        }
        //------- End DP ----------

        #endregion
    }
}
