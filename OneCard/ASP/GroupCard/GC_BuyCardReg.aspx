<%@ Page Language="C#" AutoEventWireup="true"  EnableEventValidation="false" CodeFile="GC_BuyCardReg.aspx.cs" Inherits="ASP_GroupCard_GC_BuyCardReg" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
   <%-- <link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>

    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/Window.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   <%-- <script type="text/javascript" src="../../js/mootools.js"></script>--%>

    <script type="text/javascript" language="javascript">
        function SelectComBuyCard() {
            $get('hidCardType').value = "combuycard";
            searchComBuyCard.style.display = "block";
            searchPerBuyCard.style.display = "none";
            combuycardgv.style.display = "block";
            perbuycardgv.style.display = "none";
            divComBuy.style.display = "block";
            divPerBuy.style.display = "none";
            
            document.getElementById("txtActername2").value = "";
            document.getElementById("txtActerPaperno2").value = "";
            
            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectPerBuyCard() {
            $get('hidCardType').value = "perbuycard";
            searchComBuyCard.style.display = "none";
            perbuycardgv.style.display = "block";
            combuycardgv.style.display = "none";
           
            divComBuy.style.display = "none";
            divPerBuy.style.display = "block";
            searchPerBuyCard.style.display = "block";
            document.getElementById("txtActername").value = "";
            document.getElementById("txtActerPaperno").value = "";
            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
        function mout() {
            var cardname = $get('hidCardType').value;
            var object = document.getElementById(cardname);

        }

       
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        订单管理->购卡客户维护
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />

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
     <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
        
            <asp:HiddenField ID="hidCardType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liSupplyStock" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" 
                                        onmouseout="mout();" OnClientClick="return SelectComBuyCard()"><span class="signA">单位购卡</span></asp:LinkButton></li>
                                <li runat="server" id="liNewCard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" 
                                        onmouseout="mout();" OnClientClick="return SelectPerBuyCard()"><span class="signB">个人购卡</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5" id ="searchComBuyCard" style="display: block"   runat="server">
                    <div >
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                         <td>
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td colspan="2" width="36%">
                                <asp:TextBox ID="txtCompanyname" CssClass="input" MaxLength="100" runat="server"
                                    AutoPostBack="true" OnTextChanged="queryCompanyName"></asp:TextBox>
                           
                                <asp:DropDownList ID="selCompanyname" CssClass="inputmid" Width="200px" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompanyname_Change">
                                </asp:DropDownList>
                            </td>
                            
                            <td width="12%">
                                <div align="right" >
                                    单位证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selActerPapertype1" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                           <td width="12%">
                                <div align="right">
                                    单位证件号码:</div>
                            </td>
                            <td  align="left">
                                <asp:TextBox ID="txtCompaperno" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            
                        </tr>
                        <tr >
                           <td width="12%">
                                <div align="right" >
                                    经办人姓名:</div>
                            </td>
                            <td colspan="2" width="24%">
                                <asp:TextBox ID="txtActername" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    经办人证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtActerPaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            
                            
                        </tr>
                        <tr>
                        <td colspan="6"  align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                    </div>
                    
                </div>
                <div class="kuang5"  id ="searchPerBuyCard" style="display: none"   runat="server">
                    <div id ="Div1" >
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right" >
                                    姓名:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtActername2" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right" >
                                    证件类型:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="selActerPapertype2" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            
                            <td>
                                <div align="right" >
                                    证件号码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtActerPaperno2" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        
                        <tr>
                        <td colspan="6"  align="right">
                                <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                    </div>
                    
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                <div id="combuycardgv" style="height: 250px; display: block; overflow: auto"  runat="server">
                <asp:GridView ID="gvComResult" runat="server" CssClass="tab1" Width="200%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" 
                        SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvComResult_Page"
                            OnRowDataBound="gvComResult_RowDataBound" OnSelectedIndexChanged="gvComResult_SelectedIndexChanged"
                            OnRowCreated="gvComResult_RowCreated" EmptyDataText="没有查询出任何记录">
                            <Columns>
                            <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="num" runat="server" Value='<%# Container.DataItemIndex%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="COMPANYNO" HeaderText="COMPANYNO" />
                                <asp:BoundField DataField="COMPANYNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="COMPANYPAPERTYPE" HeaderText="单位证件类型" />
                                <asp:BoundField DataField="COMPANYPAPERNO" HeaderText="单位证件号码" />
                                <asp:BoundField DataField="NAME" HeaderText="经办人姓名" />
                                <asp:BoundField DataField="PAPERTYPE" HeaderText="经办人证件类型" />
                                <asp:BoundField DataField="PAPERNO" HeaderText="经办人证件号码" />
                                <asp:BoundField DataField="PAPERENDDATE" HeaderText="经办人证件有效期" />
                                <asp:BoundField DataField="PHONENO" HeaderText="联系电话" />
                                <asp:BoundField DataField="ADDRESS" HeaderText="联系地址" />
                                <asp:BoundField DataField="EMAIL" HeaderText="电子邮件" />
                                <asp:BoundField DataField="appcalling" HeaderText="应用行业名称" />
                                <asp:BoundField DataField="registeredcapital" HeaderText="注册资金" />
                                <asp:BoundField DataField="securityvalue" HeaderText="安全值" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            单位名称
                                        </td>
                                        <td>
                                            单位证件类型
                                        </td>
                                        <td>
                                            单位证件号码
                                        </td>
                                        <td>
                                            经办人姓名
                                        </td>
                                        <td>
                                            经办人证件类型
                                        </td>
                                        <td>
                                            经办人证件号码
                                        </td>
                                        <td>
                                            经办人证件有效期
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            联系地址
                                        </td>
                                        <td>
                                            电子邮件
                                        </td>
                                        <td>
                                            应用行业名称
                                        </td>
                                        <td>
                                            注册资金
                                        </td>
                                        <td>
                                            安全值
                                        </td>
                                       
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                </div>
                <div id="perbuycardgv" style="height: 250px; display: none; overflow: auto"  runat="server">
                <asp:GridView ID="gvPerResult" runat="server"
                    CssClass="tab1"
                    Width ="200%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="20"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="gvPerResult_Page"
                    OnRowDataBound="gvPerResult_RowDataBound"
                    OnSelectedIndexChanged="gvPerResult_SelectedIndexChanged"
                    OnRowCreated="gvPerResult_RowCreated">
                    <Columns> 
                    <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="num" runat="server" Value='<%# Container.DataItemIndex%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>   
                          <asp:BoundField DataField="NAME"   HeaderText="姓名"/>            
                          <asp:BoundField DataField="PAPERTYPE"    HeaderText="证件类型"/>             
                          <asp:BoundField DataField="PAPERNO"    HeaderText="证件号码"/> 
                          <asp:BoundField DataField="SEX"    HeaderText="性别"/> 
                           <asp:BoundField DataField="BIRTHDAY"   HeaderText="出生日期"/> 
                           <asp:BoundField DataField="NATIONALITY"   HeaderText="国籍"/>
                            <asp:BoundField DataField="JOB"   HeaderText="职业"/>          
                          <asp:BoundField DataField="PHONENO"     HeaderText="联系电话"/>                 
                          <asp:BoundField DataField="ADDRESS"   HeaderText="联系地址"/> 
                          <asp:BoundField DataField="EMAIL"  HeaderText="电子邮件"/>
                          <asp:BoundField DataField="appcalling" HeaderText="应用行业名称" />
                          <asp:BoundField DataField="registeredcapital" HeaderText="注册资金" />
                          <asp:BoundField DataField="securityvalue" HeaderText="安全值" />
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                              <td>姓名</td> 
                              <td>证件类型</td>
                              <td>证件号码</td>
                              <td>性别</td>
                              <td>出生日期</td>
                              <td>国籍</td>
                              <td>职业</td>
                              <td>联系电话</td>
                              <td>联系地址</td>
                              <td>电子邮件</td>
                              <td>应用行业名称</td>
                              <td>注册资金</td>
                              <td>安全值</td>

                           </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
            </div>
            </div>
           
          <div id ="divComBuy" >
            <div class="pip" >
                    购卡单位资料维护</div>
              <div  class="kuang5" style=" overflow: auto" >
                    <table width="99%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <asp:HiddenField runat="server" ID="hidCompanyNo" />
                            <td width="12%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td colspan="3" width = "40%">
                                <asp:TextBox ID="txtCompany" CssClass="input" MaxLength="100" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryCompany"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Change">
                                </asp:DropDownList>
                                <span class="red" runat="server" id="spnGroup">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    单位证件类型:</div>
                            </td>
                             <td width="12%" >
                                <asp:DropDownList ID="selComPapertype" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span class="red" runat="server" id="spnlComPapertype">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" >
                                    单位证件号码:</div>
                            </td>
                             <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtComPaperNo2" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                                 <span class="red" runat="server" id="spnComPaperNo">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    单位证件信息:</div>
                            </td>
                            <td colspan="2" id = "tdFileUpload" runat="server" >
                                <asp:FileUpload ID="FileUpload2" runat="server"  CssClass="inputlong"/>
                            </td>
                            <td id="tdShowPicture" runat="server" width = "20%" height="50" align="center">
                            <img id="preview" runat="server" alt="图片"  src="../../Images/cardface.jpg" style="cursor:hand" height="50"  align="middle"  />
                            </td>
                            <td id="tdMsg" runat="server" width = "20%" 
                                style="border-width: 40px; padding: 0px;" >
                                <asp:Label ID="lblMsg" runat="server" Text="单位证件扫描件为空，请尽快补录！" ForeColor="Red" ></asp:Label>
                            </td>
                           
                            <td width="12%">
                                <div align="right">
                                    证件有效期:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="20"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                                    <span class="red" runat="server" id="spnComEndDate">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    法人证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtHoldNo" CssClass="input" runat="server" MaxLength="20"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right" >
                                    经办人姓名:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtCusname" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                                <span class="red" runat="server" id="spntxtCusname">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" >
                                    经办人证件类型:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selPapertype" CssClass="input" runat="server" Width="117">
                                </asp:DropDownList>
                                 <span class="red" runat="server" id="spnPapertype">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" >
                                    经办人证件号码:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtCustpaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                                <span class="red" runat="server" id="spnCustpaperno">*</span>
                            </td>
                            <td>
                                <div align="right" >
                                    经办人证件有效期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtAccEndDate" CssClass="input" MaxLength="8" runat="server"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtAccEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                        <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustphone" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCustaddr" CssClass="inputlong" MaxLength="100" runat="server"
                                    Width="324"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    电子邮件:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEmail" CssClass="input" MaxLength="40" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                         <td width="12%">
                                <div align="right">
                                    应用行业名称:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selCallingExt"  CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                         <td width="12%">
                                <div align="right">
                                    注册资金:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCompanyMoney" runat="server" CssClass="input" ></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    安全值:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCompanySecurityValue" runat="server" CssClass="input" ></asp:TextBox>
                                
                            </td>
                            <td>
                            <asp:HiddenField ID ="hidCompanySecurityValue" runat="server" />
                            </td>
                        </tr>
 
                        <tr>
                            <td>
                            </td>
                            <td colspan="3">
                            </td>
                            <%--<td>
                                <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" />
                            </td>--%>
                            <td colspan="4" align="right">
                                <asp:Button ID="btnComBuyCardReg" Text="新增" CssClass="button1" runat="server" OnClick="btnBuyCardReg_Click" />
                                <asp:Button ID="btnRegModify" Text="修 改" CssClass="button1" runat="server" Enabled="false"
                                    OnClick="btnRegModify_Click"  OnClientClick=""/>
                               
                            </td>
                        </tr>
                    </table>
                </div> 
                </div>
                <div id="divPerBuy">
                <div class="pip" >购卡个人资料维护</div>
                <div  class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <asp:HiddenField runat="server" ID="hidPAPERTYPE" />
     <asp:HiddenField runat="server" ID="hidPAPERNO" />
    <td><div align="right">姓 名:</div></td>
    <td><asp:TextBox ID="txtName" CssClass="input" maxlength="25" runat="server"></asp:TextBox><span class="red" runat="server" id="spnName">*</span></td>
     <td><div align="right">性 别:</div></td>
    <td><asp:DropDownList ID="selCustsex" CssClass="input" runat="server"></asp:DropDownList></td>
    <td><div align="right">国籍:</div></td>
    <td><asp:TextBox ID="txtNationality" CssClass="input" maxlength="20" runat="server" />
  
    
    <%--<asp:HiddenField runat="server" ID="hiddenPapertype" />
    <asp:HiddenField runat="server" ID="hiddenpaperno" />--%>
    <td><div align="right">职业:</div></td>
    <td><asp:TextBox ID="txtJob" CssClass="input" runat="server"></asp:TextBox></td>
    </tr>
  <tr>
    <td ><div align="right">证件类型:</div></td>
    <td><asp:DropDownList ID="selPerPaperType" CssClass="input" runat="server"></asp:DropDownList><span class="red" runat="server" id="spnPerPaperType">*</span></td>
    <td><div align="right">证件号码:</div></td>
    <td><asp:TextBox ID="txtPerPaperNo" CssClass="input" maxlength="20" runat="server" ></asp:TextBox><span class="red" runat="server" id="spnPerPaperNo">*</span></td>
    <td><div align="right">证件有效期:</div></td>
    <td><asp:TextBox ID="txtPerEndDate" CssClass="input" maxlength="8" runat="server" ></asp:TextBox> <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtPerEndDate"
                                    Format="yyyyMMdd" /></td>
    <td><div align="right">出生日期:</div></td>
    <td><asp:TextBox ID="txtPerBirth" CssClass="input" maxlength="8" runat="server"></asp:TextBox></td>
   
    </tr>
  
  
  <tr>
  <td><div align="right">联系电话:</div></td>
    <td><asp:TextBox ID="txtPhoneNo" CssClass="input" maxlength="20" runat="server"></asp:TextBox></td>
    <td><div align="right">联系地址:</div></td>
    <td colspan="3"><asp:TextBox ID="txtPerAddress" CssClass="inputlong" maxlength="100" runat="server" Width="324"></asp:TextBox></td>
    <td><div align="right">电子邮件:</div></td>
    <td ><asp:TextBox ID="txtPerEmail" CssClass="input" maxlength="40" runat="server"></asp:TextBox></td>
   
    
    
  </tr>
  <tr>
   <td width="12%">
                                <div align="right">
                                    应用行业名称:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selPerCalling"  CssClass="inputmid" runat="server" >
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="7: 个人行业" Value="7"></asp:ListItem>
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
      <td width="12%">
          <div align="right">
              注册资金:</div>
      </td>
      <td>
          <asp:TextBox ID="txtPersonalMoney" runat="server" CssClass="input" Text="200000"></asp:TextBox>
          <span class="red">*</span>
      </td>
      <td width="12%">
          <div align="right">
              安全值:</div>
      </td>
      <td>
          <asp:TextBox ID="txtPersonalSecurityValue" runat="server" CssClass="input"></asp:TextBox>
      </td>
      <td>
        <asp:HiddenField ID ="hidPersonalSecurityValue" runat="server" />
      </td>
  </tr>
  
     </tr>
  
    <tr>
    <td></td>
    <td colspan="3"></td>
    <td></td>
    <%--<td><asp:Button ID="Button1" Text="读二代证" CssClass="button1"  runat="server" 
    OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" /></td>--%>
    <td colspan="4" align="right">
    <asp:Button ID="Button2"  Text="新增" CssClass="button1" runat="server" OnClick="btnBuyCardReg_Click" />
    <asp:Button ID="Button3"  Text="修 改" CssClass="button1" runat="server" Enabled="false" OnClick="btnRegModify_Click" />
   
    </td>
  </tr>

</table>
 </div>
 </div>
                </div>   
             </ContentTemplate>
             <Triggers>
            <asp:PostBackTrigger ControlID="btnComBuyCardReg" />
<asp:PostBackTrigger ControlID="btnRegModify"></asp:PostBackTrigger>
<asp:PostBackTrigger ControlID="btnRegModify"></asp:PostBackTrigger>
<asp:PostBackTrigger ControlID="btnRegModify"></asp:PostBackTrigger>
        </Triggers>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnRegModify" />
        </Triggers>
        
    </asp:UpdatePanel>
    </form>
</body>
</html>
