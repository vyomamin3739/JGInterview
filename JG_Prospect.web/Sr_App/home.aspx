<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="home.aspx.cs" Inherits="JG_Prospect.Sr_App.home" %>

<%@ Register Src="~/Sr_App/LeftPanel.ascx" TagName="LeftPanel" TagPrefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .clsTestMail {
            padding: 20px;
            font-size: 14px;
        }

            .clsTestMail input[type='text'] {
                padding: 5px;
            }

            .clsTestMail input[type='submit'] {
                background: #000;
                color: #fff;
                padding: 5px 7px;
                border: 1px solid #808080;
            }

                .clsTestMail input[type='submit']:hover {
                    background: #fff;
                    color: #000;
                    cursor: pointer;
                }


        .menu-wrap {
            width: 100%;
            box-shadow: 0px 1px 3px rgba(0,0,0,0.2);
            background: #3e3436;
        }

        .menu li ul {
            width: 450px;
        }

        .menu li:hover > a, .menu .current-item > a {
            text-decoration: none;
            color: #be5b70;
        }

        /*----- Top Level -----*/
        .menu > ul > li {
            float: left;
            display: inline-block;
            position: relative;
            font-size: 19px;
        }

            .menu > ul > li:hover > a, .menu > ul > .current-item > a {
                background: #2e2728;
            }

        /*----- Bottom Level -----*/
        .menu li:hover .sub-menu {
            z-index: 1;
            opacity: 1;
        }

        .sub-menu {
            width: 150%;
            padding: 5px 5px;
            position: absolute;
            top: 100%;
            left: 0px;
            z-index: -1;
            opacity: 0;
            transition: opacity linear 0.15s;
        }

            .sub-menu li {
                display: block;
                font-size: 16px;
            }

                .sub-menu li a {
                    padding: 2px 15px;
                    display: block;
                }

                    .sub-menu li a:hover, .sub-menu .current-item a {
                        background: #3e3436;
                    }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="right_panel">
        <!-- appointment tabs section start -->
        <div class="menu-wrap">
            <nav class="menu">
                <ul class="appointment_tab">
                    <li><a href="home.aspx" class="active">Sales Calendar</a></li>
                    <li><a href="home.aspx">Master Calendar</a>
                        <ul class="sub-menu">
                            <li><a href="home.aspx" runat="server">IT-Dashboard</a></li>
                            <li><a href="GoogleCalendarView.aspx" runat="server">Calendars</a></li>
                        </ul>
                    </li>
                    <li><a href="#">Operations Calendar</a></li>
                    <li><a href="CallSheet.aspx">Call Sheet</a></li>
                    <li id="li_AnnualCalender" visible="false" runat="server"><a href="#" runat="server">Annual Event Calendar</a> </li>
                </ul>
            </nav>
        </div>

        <!-- appointment tabs section end -->
        <h1><b>Dashboard</b></h1>
        <asp:Panel ID="pnlTestEmail" Visible="false" GroupingText="Test E-Mail" runat="server" CssClass="clsTestMail">
            <asp:TextBox ID="txtTestEmail" runat="server"></asp:TextBox>
            <asp:Button ID="btnTestMail" runat="server" Text="Send Mail" OnClick="btnTestMail_Click" />
            <br />
            <asp:Label runat="server" ID="lblMessage"></asp:Label>
        </asp:Panel>
        <h2>Personal Prospect Calendar</h2>
        <div class="calendar" style="margin: 0;">
            <iframe src="../JGCalender/Calender.aspx" width="100%" height="1000" style="border: 0;"></iframe>
        </div>
        <!--<div class="form_panel">
  <div class="calendar" style="margin: 0;">

  <div id="calendarBodyDiv" >
    
  <iframe src="http://localhost:60652/calendar/cal.aspx?eid=jgrove.georgegrove@gmail.com" width="100%" height="1200" style="border:0;" ></iframe>
  
  <%--<iframe src="https://www.Google.com/calendar/embed?src=<%=
    GetCalendarId()%>&ctz=Europe%2FMoscow" style="border: 0" width="800"
height="600" frameborder="0" scrolling="no"></iframe>--%>

  </div>
<%--<asp:Image ID="Image1" runat="server" ImageUrl="~/image/dashboard.png" />--%>

</div> 


</div>-->

    </div>


</asp:Content>
