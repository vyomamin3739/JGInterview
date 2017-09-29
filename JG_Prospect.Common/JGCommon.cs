using System;
using System.Configuration;
using System.Text;
using System.Web;

namespace JG_Prospect.Common
{
    public class JGCommon
    {
        public static string GenerateOTP(int length)
        {
            const string valid = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789011223344556677889900";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random(5);
            while (0 < length--)
            {
                res.Append(valid[rnd.Next(valid.Length)]);
            }
            return res.ToString();
        }

        public static string GetEmailUnSubscribeSection()
        {
            String html = "<div style=\"clear:both;\"></div><div style=\"text-align:center;\">if you do not want to continue receiving emails from us, Please <a href =\"#URL#/unsubscribe.aspx?e=#UNSEMAIL#\" > Unsubscribe here.</a> </div>";
            html = html.Replace("#URL#",JGApplicationInfo.GetSiteURL());

            return html;
        }

    }

    public class JGApplicationInfo
    {
        public static double GetAcceptiblePrecentage()
        {
            return Convert.ToDouble(ConfigurationManager.AppSettings["AcceptableUserPercentage"]);
        }
        public static Int32 GetJMGCAutoUserID()
        {
            return Convert.ToInt32(ConfigurationManager.AppSettings["JMGCAUTOUSERID"]);
        }
        public static string GetApplicationEnvironment()
        {
            return ConfigurationManager.AppSettings["ApplicationEnvironment"];

        }
        public static string GetSiteURL()
        {
            return ConfigurationManager.AppSettings["URL"];

        }
        public static string GetDefaultBCCEmail()
        {
            return ConfigurationManager.AppSettings["DefaultBCCEmail"];

        }

        public static bool IsSendEmailExceptionOn()
        {
            bool returnVal = false;

            if (ConfigurationManager.AppSettings["AllowEmailSendingExceptionEmail"].Equals("1"))
            {
                returnVal = true; 
            }

            return returnVal;
        }
    }

}
