<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_StockOut.aspx.cs" Inherits="ASP_UserCard_UC_StockOut" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>用户卡出库</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        function Change()
        {
            var sFCard = $('txtFromCardNo').value;
            var sECard = $('txtToCardNo').value;
            var lCardSum = 0;

            if(sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$"))
            {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if(lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }
            

            $('txtCardSum').value = lCardSum;
        }
        
        
    </script>
</head>
<body>
    <form id="form1" runat="server">

<div class="tb">
卡片管理->用户卡出库（原）
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <script type="text/javascript" language="javascript">
            var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
            swpmIntance.add_initializeRequest(BeginRequestHandler);
            swpmIntance.add_pageLoading(EndRequestHandler);
            function BeginRequestHandler(sender, args) {
                try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
            }
            function EndRequestHandler(sender, args) {
                try { MyExtHide(); } catch (ex) { }
            }
        </script>        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="card">卡批量出库</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td><div align="right">起讫卡号:</div></td>
    <td colspan="3">
    <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
    -
    <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
       <span class="red">*</span></td>
    <td><div align="right">领用员工:</div></td>
    
    <td>
    <asp:DropDownList ID="selAssignedStaff" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selAssignedStaff_Change"></asp:DropDownList>
    </td>
  </tr>
  <tr>
    <td><div align="right">出库数量:</div></td>
    <td>&nbsp;<asp:TextBox ID="txtCardSum" CssClass="labeltext" width=100 runat="server" Text="0"></asp:TextBox></td>
    <td><div align="right">服务周期:</div></td>
     <td>
        <asp:DropDownList ID="selServiceCycle" CssClass="input" runat="server">
        </asp:DropDownList>
    </td>
    <td><div align="right">服务费　:</div></td>
    <td><asp:TextBox ID="txtServiceFee" CssClass="input" runat="server" MaxLength="13"></asp:TextBox>
      <span class="red">*</span> 100分</td>
  </tr>
  <tr>
    <td><div align="right">退值　　:</div></td>
    <td>
        <asp:DropDownList ID="selRetValMode" CssClass="input" runat="server">
        </asp:DropDownList>
    
    </td>
        <td><div align="right">售卡方式:</div></td>
    <td>
        <asp:DropDownList ID="selSaleType" CssClass="input" runat="server">
        </asp:DropDownList>
    
    </td>
<%--    <td><div align="right">条件　　:</div></td>
    <td>      
        <asp:DropDownList ID="selRetValCond" CssClass="input" runat="server">
        </asp:DropDownList>
      </td>
    <td><div align="right">数值　　:</div></td>
    <td><asp:TextBox ID="txtRetVal" CssClass="input" runat="server" MaxLength="13"></asp:TextBox>
      <span class="red">*</span> 100分</td>
                            --%>
                        </tr>
                    </table>
                    <div>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                保证金余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labDeposit" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                可领卡价值额度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labUsablevalue" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                网点剩余卡价值:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labStockvalue" runat="server" />
                            </td>
                        </tr>
                        <tr>
                          <td style="width: 12%" align="right">
                              最大可领卡数：
                          </td>
                          <td style="width: 12%" colspan="5">
                              <asp:Label ID="labMaxAvailaCard" runat="server" />
                          </td>
                        </tr>
                    </table>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
