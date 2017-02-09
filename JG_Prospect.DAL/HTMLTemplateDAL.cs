using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using JG_Prospect.DAL.Database;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.DAL
{
    public class HTMLTemplateDAL
    {
        public static HTMLTemplateDAL m_HTMLTemplateDAL = new HTMLTemplateDAL();

        private HTMLTemplateDAL()
        {

        }

        public static HTMLTemplateDAL Instance
        {
            get { return m_HTMLTemplateDAL; }
            private set { ; }
        }

        public DataSet GetHTMLTemplateMasters()
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHTMLTemplateMasters");
                    command.CommandType = CommandType.StoredProcedure;
                    return database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public HTMLTemplatesMaster GetHTMLTemplateMasterById(HTMLTemplates objHTMLTemplates)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHTMLTemplateMasterById");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int16, (byte)objHTMLTemplates);

                    DataSet dsHTMLTemplate = database.ExecuteDataSet(command);
                    HTMLTemplatesMaster objHTMLTemplate = null;
                    if (
                        dsHTMLTemplate != null &&
                        dsHTMLTemplate.Tables.Count > 0 &&
                        dsHTMLTemplate.Tables[0].Rows.Count > 0
                       )
                    {
                        DataRow dr = dsHTMLTemplate.Tables[0].Rows[0];

                        objHTMLTemplate = new HTMLTemplatesMaster();

                        objHTMLTemplate.Id = Convert.ToInt32(dr["Id"]);
                        objHTMLTemplate.Name = Convert.ToString(dr["Name"]);
                        objHTMLTemplate.Subject = Convert.ToString(dr["Subject"]);
                        objHTMLTemplate.Header = Convert.ToString(dr["Header"]);
                        objHTMLTemplate.Body = Convert.ToString(dr["Body"]);
                        objHTMLTemplate.Footer = Convert.ToString(dr["Footer"]);
                        objHTMLTemplate.DateUpdated = Convert.ToDateTime(dr["DateUpdated"]);
                    }

                    return objHTMLTemplate;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public DesignationHTMLTemplate GetDesignationHTMLTemplate(HTMLTemplates objHTMLTemplates, string strDesignation)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetDesignationHTMLTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int16, (byte)objHTMLTemplates);
                    if (!string.IsNullOrEmpty(strDesignation))
                    {
                        database.AddInParameter(command, "@Designation", DbType.String, strDesignation);
                    }

                    DataSet dsHTMLTemplate = database.ExecuteDataSet(command);
                    DesignationHTMLTemplate objHTMLTemplate = null;
                    if (
                        dsHTMLTemplate != null && 
                        dsHTMLTemplate.Tables.Count > 0 && 
                        dsHTMLTemplate.Tables[0].Rows.Count > 0
                       )
                    {
                        DataRow dr = dsHTMLTemplate.Tables[0].Rows[0];

                        objHTMLTemplate = new DesignationHTMLTemplate();

                        objHTMLTemplate.Id = Convert.ToInt32(dr["Id"]);
                        objHTMLTemplate.HTMLTemplatesMasterId = Convert.ToInt32(dr["HTMLTemplatesMasterId"]);
                        objHTMLTemplate.Subject = Convert.ToString(dr["Subject"]);
                        objHTMLTemplate.Header = Convert.ToString(dr["Header"]);
                        objHTMLTemplate.Body = Convert.ToString(dr["Body"]);
                        objHTMLTemplate.Footer = Convert.ToString(dr["Footer"]);
                        objHTMLTemplate.DateUpdated = Convert.ToDateTime(dr["DateUpdated"]);
                    }

                    return objHTMLTemplate;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public bool SaveDesignationHTMLTemplate(DesignationHTMLTemplate objDesignationHTMLTemplate)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SaveDesignationHTMLTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@HTMLTemplatesMasterId", DbType.Int16, objDesignationHTMLTemplate.HTMLTemplatesMasterId);
                    database.AddInParameter(command, "@Designation", DbType.String, objDesignationHTMLTemplate.Designation);
                    database.AddInParameter(command, "@Subject", DbType.String, objDesignationHTMLTemplate.Subject);
                    database.AddInParameter(command, "@Header", DbType.String, objDesignationHTMLTemplate.Header);
                    database.AddInParameter(command, "@Body", DbType.String, objDesignationHTMLTemplate.Body);
                    database.AddInParameter(command, "@Footer", DbType.String, objDesignationHTMLTemplate.Footer);

                    database.ExecuteNonQuery(command);

                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public bool DeleteDesignationHTMLTemplate(HTMLTemplates objHTMLTemplates, string strDesignation)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("DeleteDesignationHTMLTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int16, (byte)objHTMLTemplates);
                    if (!string.IsNullOrEmpty(strDesignation))
                    {
                        database.AddInParameter(command, "@Designation", DbType.String, strDesignation);
                    }

                    database.ExecuteNonQuery(command);

                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }
    }
}
