using System;
using System.Text;
using System.Net.Http;


namespace JG_Prospect.BLL
{
    public class EmailBLL
    {
        static HttpClient client = new HttpClient();
        static EmailBLL()
        {
            client.BaseAddress = new Uri("https://pddimp.yandex.ru");
            
            // Curretly PddToken is dummy value which needs to be change with actual Token
            client.DefaultRequestHeaders.Add("PddToken", "123456789ABCDEF0000000000000000000000000000000000000");
        }


        // Create New Email Id with First name, Last Name, jmgroveconstruction.com domain and 123 as password
        // ASYNC process so it will not block main thread
        public static async void CreateEmail(string firstName, string lastName)
        {
            string emailId = firstName + "." + lastName;

            // New User Email password is created with 123.
            string contentstr = "domain=jmgroveconstruction.com&login=" + emailId + "&password=123";
            HttpContent content = new ByteArrayContent(Encoding.ASCII.GetBytes(contentstr));

            try
            {
                HttpResponseMessage response = await client.PostAsync($"/api2/admin/email/add", content);
                response.EnsureSuccessStatusCode();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.Print(ex.Message);
            }
            finally
            {
                client.Dispose();
            }
        }
    }
}

