using JG_Prospect.BLL;
using JG_Prospect.Common.RestServiceJSONParser;
using JG_Prospect.Utilits;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.Sr_App
{
    public partial class ajaxcalls : System.Web.UI.Page
    {

        #region "-- Web Methods --"

        /// <summary>
        /// Get auto search suggestions for task generator search box.
        /// </summary>
        /// <param name="searchterm"></param>
        /// <returns>categorised search suggestions for Users, Designations, Task Title, Task Ids</returns>
        [WebMethod]
        public static string GetSearchSuggestions(string searchterm)
        {
            DataSet dsSuggestions;

            string SearchSuggestions = string.Empty;

            dsSuggestions = TaskGeneratorBLL.Instance.GetTaskSearchAutoSuggestion(searchterm);

            if (dsSuggestions != null && dsSuggestions.Tables.Count > 0 && dsSuggestions.Tables[0].Rows.Count > 0)
            {
                SearchSuggestions = JsonConvert.SerializeObject(dsSuggestions.Tables[0]);
            }

            return SearchSuggestions;
        }

        /// <summary>
        /// Load auto search suggestion as user types in search box for sales users.
        /// </summary>
        /// <param name="searchTerm"></param>
        /// <returns> categorised search suggestions for sales users</returns>
        [WebMethod]
        public static string GetSalesUserAutoSuggestion(string searchterm)
        {
            DataSet dsSuggestions;

            string SearchSuggestions = string.Empty;

            dsSuggestions = InstallUserBLL.Instance.GetSalesUserAutoSuggestion(searchterm);

            if (dsSuggestions != null && dsSuggestions.Tables.Count > 0 && dsSuggestions.Tables[0].Rows.Count > 0)
            {
                SearchSuggestions = JsonConvert.SerializeObject(dsSuggestions.Tables[0]);
            }

            return SearchSuggestions;
        }

        [WebMethod]
        public static string GetEmailCounters()
        {
            YandexEmailCountersResponse EmailCounters = YandexManager.GetUnreadEmailCount(AppSettingsValues.GetDomainActiveUserEmailCreation, "jgrove@jmgroveconstruction.com");
            return JsonConvert.SerializeObject(EmailCounters.counters, Formatting.Indented);

        }

        //---------- Start DP ---------
        [WebMethod]
        public static string GetTaskUsers(string searchterm)
        {
            DataSet dsSuggestions;

            string SearchSuggestions = string.Empty;

            dsSuggestions = InstallUserBLL.Instance.GetTaskUsers(searchterm);

            if (dsSuggestions != null && dsSuggestions.Tables.Count > 0 && dsSuggestions.Tables[0].Rows.Count > 0)
            {
                SearchSuggestions = JsonConvert.SerializeObject(dsSuggestions.Tables[0]);
            }

            return SearchSuggestions;
        }

        //---------- End DP ---------


        #endregion

        #region "-- Chat --"

        [WebMethod]
        public static string LogintoChat()
        {
            string returnval = string.Empty;

            string server = "http://chat.jmgrovebuildingsupply.com";

            var strPostData = string.Format("username={0}&email={1}&password={2}&confirmPassword={2}", JGSession.UserLoginId.Replace("@", "."), JGSession.UserLoginId, JGSession.UserPassword);
            var arrPostData = System.Text.Encoding.ASCII.GetBytes(strPostData);

            if (SendHttpWebRequest(server + "/account/create", arrPostData).StatusCode == System.Net.HttpStatusCode.OK)
            {
                strPostData = string.Format("username={0}&password={1}", JGSession.UserLoginId.Replace("@", "."), JGSession.UserPassword);
                arrPostData = System.Text.Encoding.ASCII.GetBytes(strPostData);

                if (SendHttpWebRequest(server + "/account/login", arrPostData).StatusCode == System.Net.HttpStatusCode.OK)
                {
                    returnval = "1"; 
                }
            }

            return returnval;
        }

        private static System.Net.HttpWebResponse SendHttpWebRequest(string strUrl, byte[] arrPostData)
        {
            var objRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(strUrl);

            objRequest.Method = "POST";
            objRequest.ContentType = "application/x-www-form-urlencoded";
            objRequest.ContentLength = arrPostData.Length;

            objRequest.Headers.Add("sec-jabbr-client", "1");

            using (var stream = objRequest.GetRequestStream())
            {
                stream.Write(arrPostData, 0, arrPostData.Length);
            }

            return (System.Net.HttpWebResponse)objRequest.GetResponse();
        }

        #endregion


    }
}