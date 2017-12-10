<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RefundQuery.aspx.cs" Inherits="ASP_PersonalBusiness_PB_RefundQuery" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>退款记录查询</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    设备管理->退款记录查询
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
	
		        <div class="card">
                    退款记录查询
		        </div>
          
		        <div class="kuang5">
          
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				        <td><div align="right">充值ID:</div></td>
					        <td>
                              <asp:TextBox ID="txtID" CssClass="inputmid" MaxLength="18" runat="server"></asp:TextBox>
					      
						        </td>
					        <td><div align="right">卡号:</div></td>
					        <td>
                                <asp:TextBox ID="txtCardNo" CssClass="inputmid" MaxLength="16" runat="server"></asp:TextBox>
					        </td>
					        <td>&nbsp;</td>
					        </tr>
					        <tr>
					        <td><div align="right">状态:</div></td>
					        <td>
                            <asp:DropDownList ID="ddlState" runat="server"   CssClass="inputmid" >
                            <asp:ListItem Value="">--请选择--</asp:ListItem>
                            <asp:ListItem Value="1">1:待审核</asp:ListItem>
                            <asp:ListItem Value="2">2:审核通过</asp:ListItem>
                            <asp:ListItem Value="3">3:作废</asp:ListItem>
                            </asp:DropDownList>
                              </td>
					        <td><div align="right"></div></td>
					        <td>
						      </td>
					       <td>&nbsp;</td>
				        </tr>
				        <tr>
					        
					        
                            <td style="text-align: right;"></td>
                            <td>
						         </td>
                             <td><div align="right"></div></td>
					        <td></td>
					        <td><div align="center"><asp:Button ID="btnPosQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnPosQuery_Click"/></div></td>
					        
				        </tr>
			        </table>
        				
			        <div class="kuang5">
				        <div class="gdtb" style="height:395px">
				            <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top

        AutoGenerateColumns="False">
           <Columns>
                <asp:BoundField HeaderText="充值ID" DataField="ID"/>   
                <asp:BoundField HeaderText="卡号" DataField="CardNo"/>
                <asp:BoundField HeaderText="充值日期" DataField="TradeDate"/>
                <asp:BoundField HeaderText="充值金额" DataField="backmoney"/>
                <asp:BoundField HeaderText="退款账户的开户行" DataField="bank"/>
                <asp:BoundField HeaderText="退款账户的银行账户" DataField="bankaccno"/>
                <asp:BoundField HeaderText="退款账户的开户名" DataField="custname"/>
                
                <asp:BoundField HeaderText="退款比例" DataField="slope"/>
                <asp:BoundField HeaderText="备注" DataField="remark"/>    
                <asp:BoundField HeaderText="状态" DataField="state"/>
                <asp:BoundField HeaderText="收款人账户类型" DataField="purpose"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>充值ID</td>
                    <td>卡号</td>
                    <td>充值日期</td>
                    <td>充值金额</td>
                    <td>退款账户的开户行</td>
                    <td>退款账户的银行账户</td>
                    <td>退款账户的开户名</td>
                   
                    <td>退款比例</td>
                     <td>备注</td>
                      <td>状态</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
				        </div>
			        </div>
        			
		        </div>
        		
           </div>
	        
	        </ContentTemplate>  
        </asp:UpdatePanel>  
     
    </form>
             
</body>
</html>