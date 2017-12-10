<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_TestCard.aspx.cs" Inherits="TestCard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>OCX Test</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript">
   var OperateCardNo = "<%= ((Hashtable)Session["LogonInfo"])["CardID"] %>";
   var currCardNo = null;
   var cardBalance = 0;
   
   function readCardNo() {
        var i = SX_CARDOCX1.ReadCardNo(); 
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }
        currCardNo = SX_CARDOCX1.CardNo;
        MyExtMsg ('提示', "卡号:" + SX_CARDOCX1.CardNo);
        return true;
    }
    
    function readCardInfo() {
        var i;
        i = SX_CARDOCX1.ReadInfo(OperateCardNo);
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }

        currCardNo = SX_CARDOCX1.CARDNO;
        cardBalance = SX_CARDOCX1.Balance;
        
        MyExtMsg('提示', "卡号:" + SX_CARDOCX1.CARDNO 
           + "<br>应用类型:" + SX_CARDOCX1.AppType 
           + "<br>应用版本:" + SX_CARDOCX1.AppVersion 
           + "<br>卡序列号:" + SX_CARDOCX1.AppSn 
           + "<br>启用日期:" + SX_CARDOCX1.AppStartDate 
           + "<br>有效期:" + SX_CARDOCX1.AppEndDate 
           + "<br>FCI:" + SX_CARDOCX1.FCI
           + "<br>卡类型:" + SX_CARDOCX1.CardType
           + "<br>交易序号:" + SX_CARDOCX1.Tradeno 
           + "<br>卡内余额:" + (SX_CARDOCX1.Balance/100).toFixed(2) + "元"
           + "<br>内部员工标识:" + SX_CARDOCX1.StaffTag);

        return true;

    }
     function readCardInfoEx() {
        var i;
        i = SX_CARDOCX1.ReadInfoEx(OperateCardNo);
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }

        currCardNo = SX_CARDOCX1.CARDNO;
        cardBalance = SX_CARDOCX1.Balance;
        
        MyExtMsg('提示', "卡号:" + SX_CARDOCX1.CARDNO 
           + "<br>应用类型:" + SX_CARDOCX1.AppType 
           + "<br>应用版本:" + SX_CARDOCX1.AppVersion 
           + "<br>卡序列号:" + SX_CARDOCX1.AppSn 
           + "<br>启用日期:" + SX_CARDOCX1.AppStartDate 
           + "<br>有效期:" + SX_CARDOCX1.AppEndDate 
           + "<br>FCI:" + SX_CARDOCX1.FCI
           + "<br>卡类型:" + SX_CARDOCX1.CardType
           + "<br>交易序号:" + SX_CARDOCX1.Tradeno 
           + "<br>卡内余额:" + SX_CARDOCX1.Balance 
           + "<br>内部员工标识:" + SX_CARDOCX1.StaffTag);

        return true;

    }   
    function unlockCard()
    {
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		//alert('卡号:' + currCardNo + '<br>操作员卡号:' + OperateCardNo+ "<br>令牌:" + SX_CARDOCX1.Token);

	    var i = SX_CARDOCX1.UnLock(OperateCardNo);
	    if (i != 0) 
	    {
	        MyExtMsg('提示', "解锁失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i + "<br>令牌:" + SX_CARDOCX1.Token);
	        return false;
	    } 
	
	    MyExtMsg('提示', "解锁成功!"+SX_CARDOCX1.Token);	
    	return true;
    }
    
	function lockCard()
	{
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.Lock(OperateCardNo, currCardNo);
		if (i != 0) 
		{
		    MyExtMsg('提示', "锁卡失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		
		MyExtMsg('提示', "锁卡成功!");	
		return true;
	}
    
    function unloadCard()
    {
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.UnLoad(OperateCardNo, currCardNo, cardBalance, cardBalance,"000000000000");
		if (i != 0) 
		{
		    MyExtMsg('提示', "圈提失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		
		MyExtMsg('提示', "圈提成功!");	
		return true;
    }
    	
    function lockHelp()
    {
        $get('hidHelp').value = "lockCard();";
        return true;
    }
    
    function unlockHelp()
    {
        $get('hidHelp').value = "unlockCard();";
        return true;
    }
    
    function unloadHelp()
    {
        $get('hidHelp').value = "unloadCard();";
        return true;
    }
    
    function WriteWjLvyou()
    {
		SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.WriteWjLvyou(OperateCardNo, "2150019900010129","032012123164");//03 + 日期 + 次数（16进制）

		if (i != 0) 
		{
		    MyExtMsg('提示', "吴江园林年卡开卡:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		MyExtMsg('提示', "吴江园林年卡开卡成功!");	
		return true;
				
    }
    
    function ReadWjLvyou()
    {
		
		SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.ReadWjLvyou(OperateCardNo);
		if (i != 0) 
		{
		    MyExtMsg('提示', "读取吴江园林卡信息失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		MyExtMsg('提示', SX_CARDOCX1.WjLvyouTag);	
		return true;
				
    }
    
    function WriteWjLvyouHelp()
    {
        $get('hidHelp').value = "WriteWjLvyou();";
        return true;
    }
    
    function ReadWjLvyouHelp()
    {
        $get('hidHelp').value = "ReadWjLvyou();";
        return true;
    }
    
    function ReadGj() {
        var i = SX_CARDOCX1.ReadGjTrade(OperateCardNo); 
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }
        MyExtMsg ('提示', "标识:" + SX_CARDOCX1.TradeNumber);
        return true;
    }

    function WriteGj()
    {
       SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.WriteGjTrade(OperateCardNo,"01300000000000003DCE0000000000000000000000000000000000000000000000000000000007");
		if (i != 0) 
		{
		    MyExtMsg('提示', "开通失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		
		MyExtMsg('提示', "开通成功!");	
		return true;
    }

      function ReadShiping() {
        var i = SX_CARDOCX1.ReadShiping(OperateCardNo); 
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }
        MyExtMsg ('提示', "标识:" + SX_CARDOCX1.ShiPingTag);
        return true;
    }
    
    function WriteShiPingHelp()
    {
        $get('hidHelp').value = "WriteShiPing();";
        return true;
    }
    function WriteShiPing()
    {
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
		var i = SX_CARDOCX1.WriteShiPing(OperateCardNo,"201505311234567890ab");
		if (i != 0) 
		{
		    MyExtMsg('提示', "开通失败:"+SX_CARDOCX1.ErrInfo+"<br>返回值："+i+ "<br>令牌:" + SX_CARDOCX1.Token);
		    return false;
		} 
		
		
		MyExtMsg ('提示', "标识:" + SX_CARDOCX1.ShiPingTag);
		return true;
    }

    function ReadDriverRecordYL()
    {
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
        this.i = SX_CARDOCX1.ReadDriverRecordYL(OperateCardNo);
       if (i != 0) 
		{
		     MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
		} 
		
		
		   MyExtMsg ('提示', "标识:" + SX_CARDOCX1.DriverRecordYL);
        return true;
    
    }

     function ReadDriverRecord()
    {
        SX_CARDOCX1.Token =  $get('hidCardReaderToken').value;
        this.i = SX_CARDOCX1.ReadDriverRecord(OperateCardNo);
       if (i != 0) 
		{
		     MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
		} 
		
		
		   MyExtMsg ('提示', "标识:" + SX_CARDOCX1.DriverRecord);
        return true;
    
    }
    </script>
</head>
<body>
    <object id="SX_CARDOCX1" classid="clsid:0362744E-0794-4020-B5B0-355ED58A736D" width="0"
        height="0">
    </object>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
            <asp:HiddenField runat="server" ID="hidHelp" />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <div align="center">
                <asp:Button runat="server" ID="btnReadCardNo" Text="读卡号" OnClientClick="return readCardNo()" />
                <asp:Button runat="server" ID="Button1" Text="读卡信息" OnClientClick="return readCardInfo()" />
                <asp:Button runat="server" ID="Button3" Text="锁卡" OnClientClick="return lockHelp()"
                    OnClick="Button2_Click" />
                <asp:Button runat="server" ID="Button5" Text="读卡信息(锁卡)" OnClientClick="return readCardInfoEx()" />
                <asp:Button runat="server" ID="Button2" Text="解锁" OnClientClick="return unlockHelp()"
                    OnClick="Button2_Click" />
                <asp:Button runat="server" ID="Button4" Text="圈提" OnClientClick="return unloadHelp()"
                    OnClick="Button2_Click" />
                <br />
                <br />
                <asp:Button runat="server" ID="Button6" Text="吴江园林卡开卡" OnClientClick="return WriteWjLvyouHelp()"
                    OnClick="Button2_Click" />
                <asp:Button runat="server" ID="Button7" Text="读取吴江园林卡信息" OnClientClick="return ReadWjLvyouHelp()"
                    OnClick="Button2_Click" />
                <br />
                <br />
                <asp:Button runat="server" ID="Button8" Text="读取世乒旅游标识" OnClientClick="return ReadShiping()" />
                <asp:Button runat="server" ID="Button9" Text="世乒旅游开卡" OnClientClick="return WriteShiPingHelp()"
                    OnClick="Button2_Click" />
                <asp:Button runat="server" ID="Button10" Text="读取轨交次数" OnClientClick="return ReadGj()" />
                <asp:Button runat="server" ID="Button11" Text="读取闪付记录" OnClientClick="return ReadDriverRecordYL()" />
                <asp:Button runat="server" ID="Button12" Text="读取交易记录" OnClientClick="return ReadDriverRecord()" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
