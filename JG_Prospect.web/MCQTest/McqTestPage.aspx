<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="McqTestPage.aspx.cs" Inherits="JG_Prospect.MCQTest.McqTestPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/screen.css" rel="stylesheet" media="screen" type="text/css" />
    <script type="text/javascript" src="../js/TimerFunctions.js"></script>
    <style>
        .tblResult{
                text-align-last: auto;
                width: 100%;
                padding: 50px;
        }
        .tblResult tr td
        {
            background : url('../img/line.png') repeat-x 50% bottom;
            padding: 10px 15px 12px 15px;
        }
        .tblExamStartup
        {
            width: 100%;
                padding: 50px;
        }

    </style>
</head>
<body style="background:none;">
    <form id="form1"  method="post" runat="server">
        <h1> Aptitude Screening Test </h1>
        <div style="text-align: center" class="form_panel_custom">
            <p>
                <asp:Label ID="Label1" runat="server" BackColor="RosyBrown"></asp:Label>
            </p>
            <p>
                <asp:Label ID="lblSPI" runat="server" Text=""></asp:Label>
            </p>
            
            <br /><br />
         </div>
				
    </form>
</body>
</html>
