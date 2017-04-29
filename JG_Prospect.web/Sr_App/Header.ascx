<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="JG_Prospect.Sr_App.Header" %>
<%@ Register Src="~/Sr_App/Controls/TaskGenerator.ascx" TagPrefix="uc1" TagName="TaskGenerator" %>

<!--tabs jquery-->
<%--<script type="text/javascript" src="../js/jquery.ui.core.js"></script>
<script type="text/javascript" src="../js/jquery.ui.widget.js"></script>
<!--tabs jquery ends-->
<script type="text/javascript">
    $(function () {
        // Tabs
        $('#tabs').tabs();
    });
		</script>
<style type="text/css">
.ui-widget-header {
	border: 0;
	background:none/*{bgHeaderRepeat}*/;
	color: #222/*{fcHeader}*/;
}
</style>--%>
<style>
    #divTask {
        width: 80%;
        height: 150px;
    }

        #divTask:hover {
            height: 100%;
            position: absolute;
        }
    /*#divTask:hover > nav {
            position:fixed;
        }*/
    #test a {
        color: red;
    }

    .ProfilImg {
        left: 1px;
        top: 5px;
        position: absolute;
        margin-left: -58px;
        width: 181px;
    }

    .img-Profile {
        border-radius: 50%;
        width: 77px;
        height: 76px;
    }

    .ProfilImg .caption {
        opacity: 0;
        position: absolute;
        height: 28px;
        width: 75px;
        bottom: 0px;
        padding: 2px 0px;
        color: #ffffff;
        background: #1f211f;
        text-align: center;
        font-weight: bold;
        left: 2px;
    }

    .ProfilImg:hover .caption {
        opacity: 0.6;
    }
</style>
<script>

</script>
<div class="header">
    <img src="../img/logo.png" alt="logo" width="88" height="89" class="logo" />
    <div id="divTask">
        <uc1:TaskGenerator runat="server" ID="TaskGenerator" />
    </div>
    <div class="user_panel">
        Welcome! <span>
            <asp:Label ID="lbluser" runat="server" Text="User"></asp:Label>
            <asp:Button ID="btnlogout" runat="server" Text="Logout" CssClass="cancel" ValidationGroup="header" OnClick="btnlogout_Click" />
        </span>&nbsp;<div class="clr">
        </div>
        <ul>
            <li><a href="home.aspx">Home</a></li>
            <li>|</li>
            <li><a href='<%=Page.ResolveUrl("~/changepassword.aspx")%>'>Change Password</a></li>
        </ul>
        <div class="clr">
        </div>
        <%--<ul>
            <li><a id="idPhoneLink" class="clsPhoneLink" onclick="GetPhoneDiv()">Phone Dashboard</a></li>
        </ul>
        <div class="clr">
        </div>--%>
        <ul>
            <!--Email with # of unread msgs and new font-->
            <li id="test"><a id="hypEmail" runat="server" style="color: white;" target="_blank">Emails<label id="lblNewCounter" class="badge badge-error hide"></label><label id="lblUnRead" class="badge badge-error hide"></label></a></li>
            <li>|</li>
            <li><a id="idPhoneLink" class="clsPhoneLink" onclick="GetPhoneDiv()">Phone / Vmail(0)</a></li>
            <li>|</li>
            <li><a id="hypChat" href="#" onclick="javascript:OpenChatWindow();">Chat </a></li>
        </ul>
        <div class="ProfilImg" style="width: 90px;">
            <asp:Image CssClass="img-Profile" ID="imgProfile" runat="server" />
            <asp:HyperLink class="caption" runat="server" ID="hLnkEditProfil" Text="Edit"></asp:HyperLink>
            <%--<a href="#"><div class="caption">Edit</div></a>--%>
        </div>
        <div class="clr">
        </div>

    </div>

</div>
<!--nav section-->
<div class="nav">
    <ul>
        <li><a href="home.aspx">Home</a></li>
        <li><a href="new_customer.aspx">Add Customer</a></li>
        <%-- <li><a href="view_customer.aspx">Review / Edit Customer Estimate</a></li>--%>
        <li><a href="ProductEstimate.aspx">Product Estimate</a></li>
        <li><a href="SalesReort.aspx">Sales Report</a></li>
        <%--<li><a href="Vendors.aspx">Vendor Master</a></li>--%>
        <li id="Li_Jr_app" runat="server" visible="true"><a href="~/home.aspx" runat="server"
            id="Jr_app">Junior App</a></li>
        <li id="Li_Installer" runat="server" visible="true"><a href="~/Installer/InstallerHome.aspx" runat="server"
            id="A1">Installer</a></li>


        <%-- <li><a href="/EditUser.aspx" runat="server" id="edituser">EditUser</a></li>
  <li><a href="/Accounts/newuser.aspx" runat="server" id ="newuser">CreateUser</a></li>--%>
    </ul>
</div>
<script type="text/javascript">
    function SetEmailCounts() {

        $.ajax({
            type: "POST",
            url: "ajaxcalls.aspx/GetEmailCounters",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                console.log(data);
                if (data.d) {
                    var counters = JSON.parse(data.d);
                    console.log(counters);
                    if (counters) {
                        $('#lblNewCounter').html(counters.newone);
                        $('#lblNewCounter').show();
                        $('#lblUnRead').html("Unread: " + counters.unread);
                    }
                    //response(data.length === 1 && data[0].length === 0 ? [] : JSON.parse(data.d));
                }
            }
        });
    }

    function OpenChatWindow() {
        
        $('<img />').attr({
            src: '/img/ajax-loader.gif',
            id: 'chatprogress'
        }).appendTo($('#hypChat'));

        $.ajax({
            type: "POST",
            url: "ajaxcalls.aspx/LogintoChat",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                console.log(data);
                if (data.d) {
                    var counters = JSON.parse(data.d);
                    console.log(counters);
                    if (counters == "1") {
                        window.open('/Sr_App/JabbRChat.aspx', "JMG - Chat", "width=600,height=600,scrollbars=yes");
                    }
                    else {
                        alert('Couldn\'t Login to Chat application right now, Please try again later.');
                    }
                }
                else {
                    alert('Couldn\'t Login to Chat application right now, Please try again later.');
                }
                $('#hypChat').html('Chat');
            },
            error: function () {
                $('#hypChat').html('Chat');
            }
        });

    }
</script>
