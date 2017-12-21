<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CardReader.ascx.cs" Inherits="CardReader" %>

<script type="text/javascript" src="../../js/myext.js"></script>
<script type="text/javascript" src="../../js/cardreaderhelper.js"></script>
<script type="text/javascript">

//window.onload = function(){

//	document.body.insertAdjacentHTML("beforeEnd", " \
//    <iframe name=\"idFrame\" width=\"0\" height=\"0\" src=\"..\\..\\Tools\\print\\printArea.html\"> \
//    </iframe>");


//    document.body.insertAdjacentHTML("beforeEnd", " \
//        <object id=\"printFactory\" style=\"display:none\"   \
//         classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
//        </object>");
//        
//    if (printFactory.object) {
//        printFactory.printing.header = "";
//        printFactory.printing.footer = "";
//        printFactory.printing.portrait = true;
//        printFactory.printing.leftMargin = 3.25;
//        printFactory.printing.topMargin = 8.47;
//        printFactory.printing.rightMargin = 3.1;
//        printFactory.printing.bottomMargin = 14.11;
//    }
//}

//function printArea(printContent) {

//    idFrame.document.body.innerHTML = document.all.item(printContent).innerHTML;

//    if (!printFactory.object) { //no install printx object     
//        // printdiv(printContent);        
//        idFrame.focus();  idFrame.print();       
//    }
//    else {
//        printFactory.printing.Print(false, idFrame);
//    }
//}
    
    
function assignSexValue(sexId, idInfo) {
    assignValue(sexId, idInfo.sex == "男" ? "0" : "1");
}

function warnConfirm()
{
     var hidw = $get('hidWarning');

     MyExtConfirm('警告', hidw != null ? hidw.value : "", showResult);
}

        
function showReadCardErr(errInfo, errRet, showErr)
{
    if (showErr) {
        MyExtAlert('读卡错误', errInfo + ', 错误码:' + errRet);
    }
}

function writeCard() {

    if ($get('hidCardnoForCheck')) {//add by liuhe 20111104 页面写卡前做此验证

        if (cardReader.CardInfo.cardNo != $get('hidCardnoForCheck').value) {
                MyExtAlert("警告", "读卡器上卡片为:<br>"
                + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
                + "<br>先前读出卡号为: <br>"
                + '<span class="red">' + $get('hidCardnoForCheck').value + '</span>'
                + "<br>不一致。<br><br> 请重新确认办理业务的卡片！", writeFailCallBack);
                return;
        }
    }		

    MyExtShow('请等待', '正在执行写卡操作...');
    setTimeout(writeCardDelay, 500);
}

//add by liuhe 20111104
function writeFailCallBack() {
    var hidw = $get('hidWarning');
    var btnCf = $get('btnConfirm');
    if (hidw != null) hidw.value = 'writeFail';
    if (btnCf != null) btnCf.click();
}
 
function writeCompleteCallBack() 
{   
    MyExtHide();

    var hidw = $get('hidWarning');
    var btnCf = $get('btnConfirm');

    if (cardReader.testingMode )
    {
        if ( cardReader.CardNo.substr(0,1) == '2')
        {
             if (hidw != null) hidw.value = 'writeSuccess';            
             if (btnCf != null) btnCf.click();
             return;
        }
        else
        {
            MyExtConfirm('写卡失败',  
            '是否重新放置好卡片，然后再试？', rewriteCard);
        }
        
        return;
    }

    if (cardReader.ErrRet != 0) {
        MyExtConfirm('写卡失败', cardReader.ErrInfo + ", ReturnCode:" + cardReader.ErrRet +
            '<br><br>是否重新放置好卡片，然后再试？', rewriteCard);
        assignValue('hidWriteCardFailInfo', cardReader.ErrRet + "," + cardReader.ErrInfo);
    }
    else {
        //
        if (cardReader.ErrInfo === 'Error') {
            assignValue('hidWriteCardFailInfo', cardReader.ErrRet + "," + cardReader.ErrInfo);
        }
        var callCb = true;
        if (cardReader.readCallback) {
            callCb = cardReader.readCallback();
            cardReader.readCallback = null;
        }

        if (callCb) writeSuccessCallBack();

    }
}

function readCardForCheck() {
    var ret = ReadCardInfo();

    if (ret)
	{
	    assignValue('cMoney', (cardReader.CardInfo.balance/100).toFixed(2));
	}

    return false;
}


function chargeCardConfirm()
{
		MyExtAlert('充值成功', '卡号:' + cardReader.CardNo + '<br/><br/>' 
			+ '充值前卡内余额:' + 	(cardReader.preMoney/100).toFixed(2) + '<br/><br/>'
			+ '充值金额:<span class="red">' + (cardReader.chargeMoney/100).toFixed(2)  + '</span><br/><br/>'
			+ '充值后读出卡内余额: <span class="red">' + (cardReader.CardInfo.balance/100).toFixed(2) + '</span>', 
			writeSuccessCallBack);
		
}

function writeSuccessCallBack()
{
    var hidw = $get('hidWarning');
    var btnCf = $get('btnConfirm');
	 if (hidw != null) hidw.value = 'writeSuccess';
	 if (btnCf != null) btnCf.click();
}

function readOpertor()
{
    var operCardNo = cardReader.testingMode ? "2150024901707227" : readOperCardNo();
    if (operCardNo == null )
    {
        return false;
    }
    
    assignValue('hiddenCheck', operCardNo);
        
    if (cardReader.OperateCardNo == operCardNo)
    {
        MyExtAlert("警告",'审核员工不能和操作员工相同');
        return false;
    }
    
    return true;
}

function RecoverCheck()
{
         MyExtConfirm('提示', '确认是否抹卡并抹数据库金额', RecoverCheckConfirm);
         return false;
}
function DBRecoverCheck()
{
         MyExtConfirm('提示', '确认是否只抹数据库金额', DBRecoverCheckConfirm);
         return false;
}

function ChargeCardChargeCheck() {
    setTimeout(ChargeCardChargeCheckDelay, 500);
}

function ChargeCardChargeCheckDelay() {
    if (!checkMaxBalance()) {
        return false;
    }
    
    MyExtConfirm('提示', '是否确认充值:' + $get('SupplyFee').innerHTML + '元?', SupplyCheckConfirm);
}

function ChargeCardZZChargeCheck() {
    setTimeout(ChargeCardZZChargeCheckDelay, 500);
}

function ChargeCardZZChargeCheckDelay() {
    if (!checkMaxBalance()) {
        return false;
    }

    MyExtConfirm('提示', '是否确认充值:' + $get('hidMoney').value + '元?', SupplyCheckConfirm);
}

function checkMaxBalanceText(txtSupplyFee)
{
    // 检测是否卡内余额加上充值金额超过1千元
    var chargeMoney = parseFloat($get(txtSupplyFee).value)*100 + cardReader.CardInfo.balance;
    if ($get('hidIsJiMing')) {
        //判断是否记名卡
        if ($get('hidIsJiMing').value == "1") {
            if (chargeMoney > 500000) {
                MyExtAlert("警告", '苏州通卡余额上限5千元，此次充值不能完成，请您消费后再充值。</span><br><br>充值失败！');
                return false;
            }
        }
        else {
            if (chargeMoney > 100000) {
                MyExtAlert("警告", '苏州通卡余额上限1千元，此次充值不能完成，请您消费后再充值。</span><br><br>充值失败！');
                return false;
            }
        }
    }
    else {
        if (chargeMoney > 100000) {
            MyExtAlert("警告", '苏州通卡余额上限1千元，此次充值不能完成，请您消费后再充值。</span><br><br>充值失败！');
            return false;
        }
    }
    return true;
}


function checkMaxBalance()
{
    // 检测是否卡内余额加上充值金额超过1千元
    var chargeMoney = parseFloat($get('SupplyFee').innerHTML)*100 + cardReader.CardInfo.balance;
    // alert($get('SupplyFee').innerHTML + "," + cardReader.CardInfo.balance + "," + chargeMoney);
    if ($get('hidIsJiMing')) {
        //判断是否记名卡
        if ($get('hidIsJiMing').value == "1") {
            if (chargeMoney > 500000) {
                MyExtAlert("警告", '卡内余额加上充值金额<br><span class="red">不能超过5千元。</span><br><br>充值失败！');
                return false;
            }
        }
        else {
            if (chargeMoney > 100000) {
                MyExtAlert("警告", '卡内余额加上充值金额<br><span class="red">不能超过1千元。</span><br><br>充值失败！');
                return false;
            }
        }
    }
    else {
        if (chargeMoney > 100000) {
            MyExtAlert("警告", '卡内余额加上充值金额<br><span class="red">不能超过1千元。</span><br><br>充值失败！');
            return false;
        }
    }
    
    
    return true;
}


//验证要写的卡和读的卡是否一致
function CardAndReadCardForCheck() {
    try {
        var ret = ReadCardInfoForCheck();
        if (!ret) {
            return false;
        }
        if (cardReader.CardInfo.cardNo != $get('txtCardNo').value) {
            MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('txtCardNo').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再操作！");
            return false;
        }
        else {
            return true;
        }
        return false;
    }
    catch (e) {
        return false;
    }
    
}

function SupplyAndReadCardForCheck() {
    try {
        var ret = ReadCardInfoForCheck();
        if (!ret) {
            return false;
        }
        if (cardReader.CardInfo.cardNo != $get('txtCardNo').value) {
            MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('txtCardNo').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再操作！");
            return false;
        }
        else if (cardReader.CardInfo.cardNo != $get('hidOrderCardNo').value) {
            MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>订单卡号为: <br>"
            + '<span class="red">' + $get('hidOrderCardNo').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再操作！");
            return false;
        }
        else {
            return true;
        }
        return false;
    }
    catch (e) {
        return false;
    }

}


function SupplyCheck()
{
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }
    
    if (cardReader.CardInfo.cardNo != $get('txtCardno').value) {
        MyExtAlert("警告","读卡器上卡片为:<br>" 
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>" 
            + '<span class="red">' + $get('txtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再充值！");
        return false;
    }

    if ($get('Cash').checked){
        // 检测是否卡内余额加上充值金额超过1千元
        if (!checkMaxBalance()) return false;
    
        MyExtConfirm('提示', '是否确认充值:' + $get('SupplyFee').innerHTML + '元?', SupplyCheckConfirm);
    }
    else {
        $get('hidWarning').value = 'QueryChargeCardValue';
        $get('btnConfirm').click();
    }
      
    return false;
}

function warnCheck()
{
     MyExtConfirm('提示', '请确认是否插入审核员工卡', CheckResult);
     return false;
}
   
function CheckResult(btn)
{
    if (btn == 'yes' )
    {
        var ok = readOpertor();
        if (!ok) return false;

        MyExtConfirm('是否继续', '请插回原操作员卡', showResultNotar);
    }
    else if (btn == 'no')
    {
        MyExtAlert("警告","检验审核员工卡失败!");
        return false;
    }
}

function showResultNotar(btn)
{
    if (btn == 'yes' )
    {
        $get('hidWarning').value = 'submit';
        $get('btnConfirm').click();
    }
    else if (btn == 'no')
    {
        document.all.btnReturnCard.disabled=true;
        MyExtAlert("警告","检验操作员卡失败!");
    }
}

function DeptManagerCheck() {
    MyExtConfirm('提示', '请确认是否插入网点主管员工卡', CheckDeptManagerResult);
    return false;
}
function CheckDeptManagerResult(btn) {
    if (btn == 'yes') {
        var operCardNo = cardReader.testingMode ? "2150024901707227" : readOperCardNo();
        if (operCardNo == null) {
            return false;
        }

        assignValue('hiddenCheck', operCardNo);

        $get('hidWarning').value = 'checkOperCardno';
        $get('btnConfirm').click();
    }
    else if (btn == 'no') {
        MyExtAlert("警告", "检验网点主管员工卡失败!");
        return false;
    }
}
function RecoverOperCardCheck() {
    MyExtConfirm('提示', '请插回原操作员卡', showResultNotar);
    return false;
}

function HYDROPOWER_CardPayCheck() {
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    MyExtConfirm('提示', '确认扣卡并缴费 ' + $get('hidTotalPayFee').value / 100 + ' 元？', HYDROPOWER_CardCheckConfirm);
    return false;
}

function HYDROPOWER_AccountPayCheck() {
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    MyExtConfirm('提示', '确认使用专有账户缴费 ' + $get('hidTotalPayFee').value / 100 + ' 元？', HYDROPOWER_AccountCheckConfirm);
    return false;
}

function HYDROPOWER_CardWriteRollBack() {
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    MyExtConfirm('提示', '确认写卡返销 ' + $get('hidTotalPayFee').value / 100 + ' 元？', HYDROPOWER_CardWriteRollBackConfirm);
    return false;
}

function HYDROPOWER_CardPayRollBack() {
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    MyExtConfirm('提示', '确认电子钱包返销 ' + $get('hidTotalPayFee').value / 100 + ' 元？', HYDROPOWER_CardPayRollBackConfirm);
    return false;
}

function HYDROPOWER_AccountPayRollBack() {
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    MyExtConfirm('提示', '确认专有账户返销 ' + $get('hidTotalPayFee').value / 100 + ' 元？', HYDROPOWER_AccountPayRollBackConfirm);
    return false;
}


function writeCardPeriodExtend() {
    var dateStr = $get('hidModiEndDate').value;
    var ret = ReadCardInfoForCheck();
    if (!ret) {
        return false;
    }

    if (cardReader.CardInfo.cardNo != $get('hiddentxtCardno').value) {
        MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('hiddentxtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再继续操作！");
        return false;
    }
    var confirmStr = '确认修改有效期到 [' + dateStr + '] ？';
    if (dateStr == '99991231') {
        confirmStr = '是否确认取消有效期？';
    }
    MyExtConfirm('提示', confirmStr, writeCardPeriodExtendConfirm);
    return false;
}
</script>