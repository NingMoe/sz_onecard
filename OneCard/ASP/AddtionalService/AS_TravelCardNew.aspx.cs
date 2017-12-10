using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;

// 吴江旅游年卡开通处理



public partial class ASP_AddtionalService_AS_TravelCardNew : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性



        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";

        // 初始化证件类型



        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        // 初始化费用列表



        decimal total = initFeeList(gvResult, "6A", 7);

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
    }



    // 检查吴江旅游年卡特征值



    void checkGardenFeature()
    {
        // 按照卡号读取结束日期
        DataTable data = ASHelper.callQuery(context, "ReadTravelInfo", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            return;
        }
        Object[] row = data.Rows[0].ItemArray;

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (((string)row[0]).CompareTo(today) < 0)
        {
            return; // 卡片到期，允许续费


        }

        DataTable openDayDt = ASHelper.callQuery(context, "CheckTravelOpenDay", txtCardNo.Text);

        if (openDayDt != null && openDayDt.Rows.Count > 0)
        {
            DateTime dt = (DateTime)openDayDt.Rows[0].ItemArray[0];
            if (dt.Year == DateTime.Today.Year
                && dt.Month == DateTime.Today.Month
                && dt.Day == DateTime.Today.Day)
            {
                context.AddError("吴江旅游年卡当日开通，不允许再次开通!");
            }
        }

        // 卡片未到期，提醒用户无需开卡。MESSAGEBOX，吴江旅游年卡未到期，是否继续开卡



        if (((string)row[0]).Substring(0, 6) == today.Substring(0, 6))
        {
            return;//卡片当月到期,不需要提示



        }



        hidWarning.Value += Server.HtmlDecode(
            "卡片已是吴江旅游年卡，且未到期;<br>吴江旅游年卡到期时间为:<span class='red'>" + row[0] + "</span><br>");
    }


    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;
        hidWarning.Value = "";

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
      
        #endregion

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取帐户相关信息
        checkAccountInfo(txtCardNo.Text);

        // 读取客户资料
        readCustInfo(txtCardNo.Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtCustPhone.Text.Trim();
        hidForAddr.Value = txtCustAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        // 判断卡片内吴江旅游年卡功能是否到期，否则提示无需开通


        checkGardenFeature();

        // 读取当前吴江旅游年卡结束日期
        labGardenEndDate.Text = hidParkInfo.Value.Substring(2, 8);

        // 读取可用次数
        // readParkTimes();
        string times = hidParkInfo.Value.Substring(10, 2);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + Convert.ToInt32(times, 16);

        DataTable data = ASHelper.callQuery(context, "CheckParkNew", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            hidWarning.Value += "当前卡片是由老卡换卡售出，<br>且老卡已经是有效吴江旅游年卡。<br><br>老卡号:<span class='red'>"
                + data.Rows[0].ItemArray[0] + "</span>。<br>";
        }

        if (context.hasError()) return;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料

        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        btnSubmit.Enabled = hidWarning.Value.Length == 0;

        // 如果存在警告信息，则提示是否继续开卡



        if (hidWarning.Value.Length > 0)
        {
            hidWarning.Value += Server.HtmlDecode("<br>是否继续开卡?");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "warnScript",
                "warnConfirm();", true);
        }

    }

    // 对话框确认按钮处理



    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        if (hidWarning.Value == "yes")               // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
              selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("D006010002: 吴江旅游年卡前台写卡成功，年卡已经开通");
        }
        else if (hidWarning.Value == "writeFail")    // 写卡失败
        {
            context.AddError("A006010005: 吴江旅游年卡前台写卡失败，年卡开通失败");
        }

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = "";                       // 清除消息内容
    }

    // 提交校验
    private void submitValidate()
    {
        // 客户信息校验
        custInfoParkValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);
    }

    //客户信息校验
    protected void custInfoParkValidate(TextBox txtCustName, TextBox txtCustBirth,
           DropDownList selPaperType, TextBox txtPaperNo,
           DropDownList selCustSex, TextBox txtCustPhone,
           TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);
        valid.check(!Validation.isEmpty(txtCustName), "客户姓名不能为空", txtCustName);

        bool b = Validation.isEmpty(txtCustBirth);
        if (!b)
        {
            b = valid.fixedLength(txtCustBirth, 8, "A005010002: 出生日期必须为8位");
            if (b)
            {
                valid.beDate(txtCustBirth, "A005010003: 出生日期格式必须是yyyyMMdd");
            }
        }

        b = Validation.isEmpty(txtCustPost);
        if (!b)
        {
            b = valid.fixedLength(txtCustPost, 6, "A005010004: 邮政编码必须为6位");
            if (b)
            {
                valid.beNumber(txtCustPost, "A005010005: 邮政编码必须是数字");
            }
        }
        if (selPaperType.SelectedValue == "")
        {
            context.AddError("证件类型不能为空", selPaperType);
        }
        b = Validation.isEmpty(txtPaperNo);
        valid.check(!b, "证件号码不能为空", txtPaperNo);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20", txtPaperNo);
            //判断是否有客户信息查看权限

            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                }
            }
        }
        b = Validation.isEmpty(txtCustPhone);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtCustPhone.Text) <= 20, "A005010008: 联系电话位数必须小于等于20", txtCustPhone);
            //if (b)
            //{
            //    valid.beNumber(txtCustPhone, "A005010009: 联系电话必须是数字");
            //}
        }
        b = Validation.isEmpty(txtCustAddr);
        if (!b)
        {
            valid.check(Validation.strLen(txtCustAddr.Text) <= 50, "A005010010: 联系地址位数必须小于等于50", txtCustAddr);
        }

        valid.isEMail(txtCustEmail);

        b = Validation.isEmpty(txtRemark);
        if (!b)
        {
            valid.check(Validation.strLen(txtRemark.Text) <= 100, "A005010011: 备注位数必须小于等于100", txtRemark);
        }
    }





    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();

        string str = ASHelper.readTravelTimes(context);
        int usableTimes = int.Parse(str);
        //str = readParkEndDate();

        if (context.hasError()) return;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用园林年卡开卡存储过过程
        context.SPOpen();
        //ADD BY JIANGBB 2012-05-02
        context.AddField("p_usetag").Value = "1";   //前台调用的时候传入参数1

        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("p_tradeFee").Value = (int)(Double.Parse(hidAccRecv.Value) * 100);
        context.AddField("p_openTime").Value = DateTime.Now.ToString("yyyyMMdd");
        context.AddField("P_endTime").Value = DateTime.Now.AddYears(1).ToString("yyyyMMdd");
        context.AddField("p_operCardNo").Value = context.s_CardID; // 操作员卡
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566
        // 12位,年月日8位+标志位2位+次数2位



        // 园林年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制.
        context.AddField("p_oldEndDateNum").Value = hidParkInfo.Value;

        //update by jiangbb 2012-05-02
        //hidParkInfo.Value = str.Trim() + "01" + usableTimes.ToString("X2");
        hidParkInfo.Value = "03" + DateTime.Now.AddYears(1).ToString("yyyyMMdd") + usableTimes.ToString("X2");
        context.AddField("p_endDateNum").Value = hidParkInfo.Value;

        //add by jiangbb 2012-06-08 加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustSex.SelectedValue;
        context.AddField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.AddField("P_PAPERTYPE").Value = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = txtEmail.Text;
        context.AddField("P_REMARK").Value = txtRemark.Text;

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_TravelCardNew_BAT");
        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息



        if (ok)
        {
            // AddMessage("D005010001: 吴江旅游年卡后台开卡成功，等待写卡操作");
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startWjLvyou();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "吴江旅游年卡开通", "0.00"
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", hidAccRecv.Value);
        }
    }
    //查询身份证是否开通吴江旅游年卡功能 wdx 20111116
    protected void txtSearch_Click(object sender, EventArgs e)
    {
        //判读是否开通



        DataTable data = ASHelper.callQuery(context, "QueryPaperIsTravel", txtPaperNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            string temp = "已开通吴江旅游年卡功能的卡数量为：" + data.Rows.Count.ToString() + "。";
            foreach (DataRow dr in data.Rows)
            {
                temp += "卡号：" + dr[0].ToString() + ",有效期：" + dr[1].ToString() + ";";
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "checkResidentIsFirstSupply", "alert('" + temp + "');", true);
            //context.AddMessage( "该身份证号已经至少存在一张卡片已经开通园林功能");
        }
    }
}
