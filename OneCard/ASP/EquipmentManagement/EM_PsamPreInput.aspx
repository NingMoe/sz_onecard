<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PsamPreInput.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PsamPreInput"  EnableEventValidation="false"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>POS、PSAM预录入</title>
</head>
<body> 
    <form id="form1" runat="server">
    
    <div class="tb">
		设备管理->POS、PSAM预录入
	</div>
	
	<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
	
		<div class="card">
            POS、PSAM预录入查询
		</div>
  
		<div class="kuang5">
  
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				<tr>
					<td style="text-align:right;">POS编号:</td>
					<td><asp:TextBox ID="txtPosNo1" CssClass="inputmid" runat="server" MaxLength="6"></asp:TextBox>
                    </td>	
					
					<td style="text-align:right;">PSAM号:</td>
					<td><asp:TextBox ID="txtPsamNo1" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
					</td>
					<td>&nbsp;</td>
                    <td>
					    <asp:Button ID="btnQuery" CssClass="button1" runat="server" OnClick="btnQuery_Click" Text="查询" />
					</td>
                </tr>
			</table>
				
			<div class="kuang5">
				<div class="gdtb" style="height:170px">
				
				    <asp:GridView ID="lvwRelation" runat="server" AllowPaging="true" 
                        AlternatingRowStyle-CssClass="tabjg" AutoGenerateColumns="False" 
                        CssClass="tab1" HeaderStyle-CssClass="tabbt" 
                        OnPageIndexChanging="lvwRelation_Page" OnRowCreated="lvwRelation_RowCreated" 
                        OnSelectedIndexChanged="lvwRelation_SelectedIndexChanged" 
                        PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" 
                        PagerStyle-VerticalAlign="Top" PageSize="50" SelectedRowStyle-CssClass="tabsel" 
                        Width="1800">
                        <Columns>
                            <asp:BoundField DataField="POSNO" HeaderText="POS编号" />
                            <asp:BoundField DataField="PSAMNO" HeaderText="PSAM号" />
                            <asp:BoundField DataField="PREINPUTTIME" HeaderText="预录入时间" />
                        </Columns>
                        <EmptyDataTemplate>
                            <table border="0" cellpadding="0" cellspacing="0" class="tab1" width="100%">
                                <tr class="tabbt">
                                    <td>
                                        POS编号</td>
                                    <td>
                                        PSAM号</td>
                                    <td>
                                        预录入时间</td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                    </asp:GridView>
				</div>
			</div>
			
		</div>
		
		<div class="card">
		    预录入关系处理
		</div>
		
		<div class="kuang5">
  
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				<tr>
					
					<td align="right">POS编号:</td>
					<td><asp:TextBox ID="txtPosNo2" CssClass="inputmid" runat="server" MaxLength="6"></asp:TextBox>
					</td>
					<td align="right">PSAM号:</td>
					<td><asp:TextBox ID="txtPsamNo2" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
                    </td>
				</tr>
			
			</table>
		</div>
		
		<div class="btns">
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>   
                    <td align="right">
                        <asp:Button ID="btnBuild" CssClass="button1" runat="server" OnClick="btnBuild_Click" Text="建立" />
                        <asp:Button ID="btnCancel" CssClass="button1" runat="server" OnClick="btnCancel_Click" Text="终止" />
                    </td>
                </tr>
            </table>
        </div>

   </div>
    
    	        </ContentTemplate>  
        </asp:UpdatePanel>  
     
    </form>
             
</body>
</html>
