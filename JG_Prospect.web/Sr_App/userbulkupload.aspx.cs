using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.Sr_App
{
    public partial class userbulkupload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SaveUploadedFile(Request.Files);
            }
        }

        /// <summary>
        /// Save all uploaded image
        /// </summary>
        /// <param name="httpFileCollection"></param>
        public void SaveUploadedFile(HttpFileCollection httpFileCollection)
        {
            //bool isSavedSuccessfully = true;
            //string fName = "";
            foreach (string fileName in httpFileCollection)
            {
                HttpPostedFile file = httpFileCollection.Get(fileName);
                UploadAttachment(file);
            }
        }

        public void UploadAttachment(HttpPostedFile file)
        {

            if (file != null && file.ContentLength > 0)
            {
                string strFolderName = DateTime.Now.Month.ToString() + DateTime.Now.Day.ToString() + DateTime.Now.Second.ToString();
                var originalDirectory = new DirectoryInfo(Server.MapPath("~/UploadedExcel/" + strFolderName + "/"));

                string strFileName = Path.GetFileName(file.FileName);
                string strNewFileName = Guid.NewGuid() + "-" + strFileName.Replace(",", "-").Replace("@", "-");

                string strPath = Path.Combine(originalDirectory.ToString(), strNewFileName);

                if (!Directory.Exists(originalDirectory.ToString()))
                {
                    System.IO.Directory.CreateDirectory(originalDirectory.ToString());
                }

                file.SaveAs(strPath);
                Response.Write(strFolderName + "/" + strNewFileName + "^");
            }
        }

        [WebMethod]
        public static string RemoveUploadedattachment(string serverfilename)
        {
            var originalDirectory = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/TaskAttachments"));

            string pathString = System.IO.Path.Combine(originalDirectory.ToString(), serverfilename);

            bool isExists = System.IO.File.Exists(pathString);

            if (isExists)
                File.Delete(pathString);

            return serverfilename;
        }
    }
}