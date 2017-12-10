<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_Msg.aspx.cs" Inherits="ASP_PrivilegePR_PR_Msg" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>系统消息</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/mail.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        //写新信息
        function writeNewMsg() {
            $get('txtTitle').value = "";
            $get('txtBody').value = "";
            $get('radLevel_0').checked = true;

            $get('hidMsgToDepts').value = "";
            $get('hidMsgToRoles').value = "";
            $get('hidMsgToStaffs').value = "";


            btnclear();
            showclear();

            $get('setup1').className = "inline";
            $get('setupbtn1').className = "select";

            $get('msgWritePage').style.display = "block";
            $get('msgWriteResultPage').style.display = "none";
        }
        //查看已发送信息
        function sentBox() {
            $get('hidIsInRecvBox').value = "false";
            btnclear();
            showclear();

            $get('setup2').className = "inline";
            $get('setupbtn3').className = "select";

            $get('hidWarning').value = "querySentMsg";
            $get('btnConfirm').click();
        }
        //查看收件信息
        function recvBox() {
            $get('hidIsInRecvBox').value = "true";
            btnclear();
            showclear();

            $get('setup2').className = "inline";
            $get('setupbtn2').className = "select";

            $get('hidWarning').value = "queryRecvMsg";
            $get('btnConfirm').click();
        }


        function btnclear() {
            $get('setupbtn1').className = "none";
            $get('setupbtn2').className = "none";
            $get('setupbtn3').className = "none";
        }

        function showclear() {
            $get('setup1').className = "disable";
            $get('setup2').className = "disable";
            $get('setup3').className = "disable";
        }
        //上一页
        function prevMsg(btn) {
            var recvMsgTable = $get('gvRecvList');
            var currMsgId = $get('hidShowMsgId').value;

            for (var i = 1; i < recvMsgTable.rows.length; ++i) {
                if (currMsgId == recvMsgTable.rows[i].cells[0].all('checkItem').value) {
                    if (i - 1 > 0) { // 有前一条
                        $get('hidShowMsgId').value =
                        recvMsgTable.rows[i - 1].cells[0].all('checkItem').value;
                        $get('hidWarning').value = "showMsg";
                        $get('btnConfirm').click();
                        return;
                    }
                }
            }

        }
        //下一页
        function nextMsg() {
            var recvMsgTable = $get('gvRecvList');
            var currMsgId = $get('hidShowMsgId').value;

            for (var i = 1; i < recvMsgTable.rows.length; ++i) {
                if (currMsgId == recvMsgTable.rows[i].cells[0].all('checkItem').value) {
                    if (i + 1 < recvMsgTable.rows.length) { // 有后一条
                        $get('hidShowMsgId').value =
                        recvMsgTable.rows[i + 1].cells[0].all('checkItem').value;
                        $get('hidWarning').value = "showMsg";
                        $get('btnConfirm').click();
                        return;
                    }
                }
            }
        }
        //删除信息
        function delMsg() {
            //if ($get('hidIsInRecvBox').value == "false") {
            //    alert("不能删除已发邮件");
            //    return;
            //}

            var recvMsgTable = $get('gvRecvList');
            var delMsgIdList = "";
            for (var i = 1; i < recvMsgTable.rows.length; ++i) {
                if (recvMsgTable.rows[i].cells[0].all('checkItem').checked) {
                    if (delMsgIdList != "") {
                        delMsgIdList += "," + recvMsgTable.rows[i].cells[0].all('checkItem').value;
                    }
                    else {
                        delMsgIdList = recvMsgTable.rows[i].cells[0].all('checkItem').value;
                    }
                }
            }

            if (delMsgIdList == "") {
                return;
            }

            $get('hidDelMsgIdList').value = delMsgIdList;

            if ($get('hidIsInRecvBox').value == "true") {
                $get('hidWarning').value = "delMsg";
            }
            else {
                $get('hidWarning').value = "delSentMsg";
            }

            $get('btnConfirm').click();
        }
        //已发送转发
        function transferMsg2() {
            $get('hidWarning').value = "transferMsg";
            $get('btnConfirm').click();

            writeNewMsg();
        }
        //收件箱转发
        function transferMsg() {
            var recvMsgTable = $get('gvRecvList');
            var transferMsgId = "";
            var i = 1
            for (; i < recvMsgTable.rows.length; ++i) {
                if (recvMsgTable.rows[i].cells[0].all('checkItem').checked) {
                    transferMsgId = recvMsgTable.rows[i].cells[0].all('checkItem').value;
                    break;
                }
            }

            if (transferMsgId == "") return;

            $get('hidShowMsgId').value = transferMsgId;
            $get('hidWarning').value = "transferMsg";
            $get('btnConfirm').click();

            writeNewMsg();
        }
        //已发送回复
        function replyMsg2() {
            $get('hidWarning').value = "replyMsg";
            $get('btnConfirm').click();

            writeNewMsg();
        }
        //收件箱回复
        function replyMsg() {
            var recvMsgTable = $get('gvRecvList');
            var transferMsgId = "";
            var i = 1
            for (; i < recvMsgTable.rows.length; ++i) {
                if (recvMsgTable.rows[i].cells[0].all('checkItem').checked) {
                    transferMsgId = recvMsgTable.rows[i].cells[0].all('checkItem').value;
                    break;
                }
            }

            if (transferMsgId == "") return;

            $get('hidShowMsgId').value = transferMsgId;
            $get('hidWarning').value = "replyMsg";
            $get('btnConfirm').click();

            writeNewMsg();
        }
        //选择发件人
        function selectMsgee() {
            var msgee = document.getElementById('apDiv1');
            msgee.className = 'inline';
        }
        //清除发送部门，发送人
        function clearRecv() {
            $get('chkDept').checked = false;
            checkAll($get('chkDept'), 'gvDept');

            $get('chkRole').checked = false;
            checkAll($get('chkRole'), 'gvRole');

            $get('chkStaff').checked = false;
            checkAll($get('chkStaff'), 'gvStaff');
        }
        //全选部门或角色或用户
        function checkAll(chkAllCtrl, gvCtrl) {
            var gv = $get(gvCtrl);
            var allInput = gv.getElementsByTagName("input");
            for (var i = 0; i < allInput.length; i++) {
                if (allInput[i].type == 'checkbox') {
                    allInput[i].checked = chkAllCtrl.checked;
                }
            }
        }

        function selectFinish() {
            document.getElementById('apDiv1').className = 'disable';

            var txtRecv = document.getElementById('txtRecv');
            txtRecv.value = "";

            var gv = document.getElementById('gvDept');
            var count = 0;
            var msg2Depts = $get('hidMsgToDepts');
            var allInput = gv.getElementsByTagName("input");
            for (var i = 0; i < allInput.length; i++) {
                if (allInput[i].type == 'checkbox') {
                    var chk = allInput[i];
                    if (chk.checked) {
                        ++count;
                        var row = chk.parentNode.parentNode;

                        if (count == 1) {
                            txtRecv.value += "部门: " + row.cells[2].innerHTML;
                            msg2Depts.value = row.cells[1].innerHTML;
                        }
                        else {
                            txtRecv.value += "," + row.cells[2].innerHTML;
                            msg2Depts.value += "," + row.cells[1].innerHTML;
                        }

                    }
                }
            }
            gv = document.getElementById('gvRole');
            allInput = gv.getElementsByTagName("input");

            count = 0;
            var msg2Roles = $get('hidMsgToRoles');
            var temp = "";

            for (var i = 0; i < allInput.length; i++) {
                if (allInput[i].type == 'checkbox') {
                    var chk = allInput[i];
                    if (chk.checked) {
                        ++count;
                        var row = chk.parentNode.parentNode;


                        if (count == 1) {
                            temp = "角色: " + row.cells[2].innerHTML;
                            msg2Roles.value = row.cells[1].innerHTML;
                        }
                        else {
                            temp += "," + row.cells[2].innerHTML;
                            msg2Roles.value += "," + row.cells[1].innerHTML;
                        }

                    }
                }
            }
            if (count > 0) {
                if (txtRecv.value != "") {
                    txtRecv.value += ";  " + temp;
                }
                else {
                    txtRecv.value = temp;
                }
            }

            gv = document.getElementById('gvStaff');
            allInput = gv.getElementsByTagName("input");
            temp = "";
            count = 0;
            var msg2Staffs = $get('hidMsgToStaffs');

            for (var i = 0; i < allInput.length; i++) {
                if (allInput[i].type == 'checkbox') {
                    var chk = allInput[i];
                    if (chk.checked) {
                        ++count;
                        var row = chk.parentNode.parentNode;

                        if (count == 1) {
                            temp = "员工: " + row.cells[2].innerHTML;
                            msg2Staffs.value = row.cells[1].innerHTML;
                        }
                        else {
                            temp += "," + row.cells[2].innerHTML;
                            msg2Staffs.value += "," + row.cells[1].innerHTML;
                        }
                    }
                }
            }
            if (count > 0) {
                if (txtRecv.value != "") {
                    txtRecv.value += ";  " + temp;
                }
                else {
                    txtRecv.value = temp;
                }
            }
        }

        function sendMsg() {
            if ($get('msgWritePage').style.display == "none") {
                return false;
            }

            var txtRecv = document.getElementById('txtRecv');
            if (txtRecv.value == "") {
                alert("请选择收件人");
                return false;
            }

            var txtTitle = $get('txtTitle');
            if (txtTitle.value == "") {
                alert("请养成写消息主题的好习惯");
                return false;
            }

            $get('msgWritePage').style.display = "none";
            $get('msgWriteResultPage').style.display = "block";
        }

        function showSingleMsg(msgid) {
            $get('setup2').className = "disable";
            $get('setup3').className = "inline";

            $get('hidShowMsgId').value = msgid;
            $get('hidWarning').value = "showMsg";
            $get('btnConfirm').click();
        }


    </script>
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <div id="apDiv1" class="disable">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td class="small">
                    选择部门
                </td>
                <td>
                    选择角色
                </td>
                <td>
                    选择员工
                </td>
            </tr>
            <tr>
                <td>
                    <div class="tabletc">
                        <asp:GridView ID="gvDept" runat="server" Width="90%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" EmptyDataText="没有部门信息">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <input type="checkbox" id="chkDept" onclick="return checkAll(this, 'gvDept');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="checkItem" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="编号" DataField="departno" />
                                <asp:BoundField HeaderText="部门" DataField="departname" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </td>
                <td>
                    <div class="tabletc">
                        <asp:GridView ID="gvRole" runat="server" Width="90%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" EmptyDataText="没有角色信息" AutoGenerateColumns="False">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <input type="checkbox" id="chkRole" onclick="return checkAll(this, 'gvRole');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="checkItem" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="编号" DataField="roleno" />
                                <asp:BoundField HeaderText="角色" DataField="rolename" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </td>
                <td>
                    <div class="tabletc">
                        <asp:GridView ID="gvStaff" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" EmptyDataText="没有员工信息" AutoGenerateColumns="False">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <input type="checkbox" id="chkStaff" onclick="return checkAll(this, 'gvStaff');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="checkItem" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="工号" DataField="staffno" />
                                <asp:BoundField HeaderText="姓名" DataField="staffname" />
                                <asp:BoundField HeaderText="部门" DataField="departname" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </td>
            </tr>
            <tr>
                <td align="left">
                    &nbsp;
                </td>
                <td>
                    &nbsp;
                </td>
                <td>
                    <div class="gntbtn">
                        <ul>
                            <li onclick="selectFinish()">确定</li>
                            <li onclick="apDiv1.className='disable';">取消</li>
                            <li onclick="clearRecv();">清除</li>
                        </ul>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div class="tb">
        系统消息
    </div>
    <div class="all">
        <div class="left">
            <div class="list">
                <ul>
                    <li id="setupbtn1" onclick="writeNewMsg()">
                        <div id="list1">
                            写新消息</div>
                    </li>
                    <li id="setupbtn2" onclick="recvBox()" class="select">
                        <div id="list2">
                            收件箱</div>
                    </li>
                    <li id="setupbtn3" onclick="sentBox()">
                        <div id="list3">
                            已发送</div>
                    </li>
                </ul>
            </div>
        </div>
        <div class="mailright">
            <div id="setup1" class="disable" runat="server">
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <div class="gnttop">
                            <ul>
                                <li id="fs">
                                    <asp:LinkButton ID="linkSend" runat="server" OnClick="sendMsg" OnClientClick="return sendMsg();">发送</asp:LinkButton>
                                </li>
                            </ul>
                        </div>
                        <div class="nr">
                            <div id="msgWritePage" runat="server">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="8%">
                                            <div align="center">
                                                <a href="javascript:selectMsgee();">收件人</a>：</div>
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtRecv" class="textfield" Enabled="false"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="center">
                                                主 题：</div>
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTitle" class="textfield" MaxLength="64" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center">
                                            级 别：
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" class="textfield" ID="radLevel" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="一般" Selected="True" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="重要" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="紧急" Value="2"></asp:ListItem>
                                                <asp:ListItem Text="特急" Value="3"></asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center">
                                            内 容：
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtBody" CssClass="textarea" TextMode="MultiLine"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center">
                                            附 件：
                                        </td>
                                        <td>
                                            <asp:FileUpload ID="fileUpload" runat="server" CssClass="textfield" />
                                            <br />
                                            （多个附件请压缩上传）
                                        </td>
                                    </tr>
                                </table>
                                <asp:HiddenField runat="server" ID="hidMsgToDepts" />
                                <asp:HiddenField runat="server" ID="hidMsgToRoles" />
                                <asp:HiddenField runat="server" ID="hidMsgToStaffs" />
                            </div>
                            <div id="msgWriteResultPage" style="display: none" runat="server">
                                <asp:Label runat="server" ID="labSentResult"></asp:Label>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="linkSend" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
            <div id="setup2" class="inline" runat="server">
                <div class="gnttop">
                    <ul>
                        <li id="sc" onclick="delMsg()">删除</li>
                        <li id="zf" onclick="transferMsg()">转发</li>
                        <li id="hf" onclick="replyMsg()">回复</li>
                    </ul>
                </div>
                <div class="tableall">
                    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                        <ContentTemplate>
                            <asp:GridView ID="gvRecvList" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top" OnRowDataBound="gvRecvList_RowDataBound" EmptyDataText="没有消息"
                                AllowSorting="true" OnSorting="gvRecvList_Sorting" AutoGenerateColumns="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <input type="checkbox" id="chkStaff" onclick="return checkAll(this, 'gvRecvList');" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <input type="checkbox" name="checkItem" value="xxxyyy" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="msgid" />
                                    <asp:BoundField DataField="msgstate" />
                                    <asp:BoundField HeaderText="发件人" DataField="msgger" SortExpression="msgger" />
                                    <asp:BoundField HeaderText="主题" DataField="msgtitle" SortExpression="msgtitle" />
                                    <asp:BoundField HeaderText="级别" DataField="msglevel" SortExpression="msglevel" />
                                    <asp:BoundField HeaderText="日期" DataField="msgtime" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}"
                                        HtmlEncode="false" SortExpression="msgtime" />
                                </Columns>
                            </asp:GridView>
                            <asp:HiddenField runat="server" ID="hidDelMsgIdList" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
            <div id="setup3" class="disable" runat="server">
                <div class="gnttop">
                    <ul>
                        <li id="up" onclick="prevMsg(this)">上一条</li>
                        <li id="down" onclick="nextMsg(this)">下一条</li>
                        <li id="Li1" onclick="transferMsg2()">转发</li>
                        <li id="Li2" onclick="replyMsg2()">回复</li>
                    </ul>
                </div>
                <div class="nr">
                    <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                        <ContentTemplate>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="8%">
                                        <div align="center">
                                            发件人：</div>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtShowMsgger" class="textfield"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div align="center">
                                            主 题：</div>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtShowTitle" class="textfield" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        级 别：
                                    </td>
                                    <td>
                                        <asp:RadioButtonList runat="server" class="textfield" ID="selShowLevel" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="一般" Selected="True" Value="0"></asp:ListItem>
                                            <asp:ListItem Text="重要" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="紧急" Value="2"></asp:ListItem>
                                            <asp:ListItem Text="特急" Value="3"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        内 容：
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtShowBody" CssClass="textarea" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        附 件：
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="linkDownLoad" runat="server" OnClick="linkDownLoad_Click">下载</asp:LinkButton>
                                    </td>
                                </tr>
                            </table>
                            <asp:HiddenField runat="server" ID="hidShowMsgId" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:PostBackTrigger ControlID="linkDownLoad" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:HiddenField runat="server" ID="hidIsInRecvBox" Value="true" />
            <asp:HiddenField runat="server" ID="hidWarning" />
            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
