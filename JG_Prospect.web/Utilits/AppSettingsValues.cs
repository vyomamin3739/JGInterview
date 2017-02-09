using System.Configuration;

namespace JG_Prospect.Utilits
{
    public static class AppSettingsValues
    {
        public static string GetDomainActiveUserEailCreation
        {
            get
            {
                return ConfigurationManager.AppSettings["CreateActiveUserEailForDomai"].ToString();
            }

        }
    }
}