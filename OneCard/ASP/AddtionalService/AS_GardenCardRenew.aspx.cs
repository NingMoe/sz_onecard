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
using System.IO;

// 园林年卡续费
public partial class ASP_AddtionalService_AS_GardenCardRenew : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        Session["PicData"] = null;
        Session["PicDataOther"] = null;//单张导入照片的Session
        // 设置可读属性



        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";


        // 初始化费用列表

        initLoad(sender, e);

        tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414

    }

    private void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据


        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "10";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001004139", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金


            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");

             //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");

            //费用类型为年费


            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "08")
                hiddenAnnualFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        //费用赋值

        DepositFee.Text = hiddenDepositFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        annualFee.Text = hiddenAnnualFee.Value;

        decimal total = Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(annualFee.Text);
        Total.Text = total.ToString("0.00");

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
    }

    // 检查黑名单列表
    private void checkBlackList()
    {
        // 从园林卡黑名单信息表中查询


        DataTable data = ASHelper.callQuery(context, "ParkBlackList", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            return;
        }

        string levelFlag = (string)data.Rows[0].ItemArray[0];
        if (levelFlag == "0")
        {
            context.AddError("A00501A004: 当前卡片已经存在于黑名单中，禁止开通功能");
        }
        else if (levelFlag == "1")
        {
            hidWarning.Value += HttpUtility.HtmlEncode("当前卡片已经存在于黑名单中;\n");
        }
    }

    //检查黑名单维护页面的黑名单
    private void checkPaperNoBlackList()
    {
        if (!string.IsNullOrEmpty(txtPaperNo.Text))
        {
            //从苏州园林年卡黑名单表中查询

            StringBuilder strPaperNo = new StringBuilder();

            AESHelp.AESEncrypt(txtPaperNo.Text, ref strPaperNo);

            DataTable data = ASHelper.callQuery(context, "PaperNoBlackList", strPaperNo.ToString());
            if (data.Rows.Count == 0)
            {
                return;
            }

            string useTag = (string)data.Rows[0].ItemArray[0];
            if (useTag == "1")
            {
                context.AddError("A094780016：当前身份证号已存在于黑名单中，禁止开通功能");
            }
        }
    }

    // 检查园林年卡特征值



    void checkGardenFeature()
    {
        // 按照卡号读取结束日期
        DataTable data = ASHelper.callQuery(context, "ParkCardEndDate", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            context.AddError("该卡未开通过园林卡，不允许续费!");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (((string)row[0]).CompareTo(today) < 0)
        {
            return; // 卡片到期，允许续费


        }

        DataTable openDayDt = ASHelper.callQuery(context, "CheckParkOpenDay", txtCardNo.Text);

        if (openDayDt != null && openDayDt.Rows.Count > 0)
        {
            DateTime dt = (DateTime)openDayDt.Rows[0].ItemArray[0];
            if (dt.Year == DateTime.Today.Year
                && dt.Month == DateTime.Today.Month
                && dt.Day == DateTime.Today.Day)
            {
                context.AddError("园林年卡当日开通，不允许再次续费!");
            }
        }

        if (DateTime.Now.AddMonths(1).ToString("yyyyMMdd").CompareTo(row[0].ToString()) <= 0)
        {
            hidWarning.Value += Server.HtmlDecode(
          "卡片已是园林年卡，且未到期;<br>园林到期时间为:<span class='red'>" + row[0] + "</span><br>");
        }

    }


    // 读取园林年卡的结束日期



    private String readParkEndDate()
    {
        // 从全局参数表中读取园林年卡的结束日期设置
        DateTime dtNow=DateTime.Now;
        
        //取下一年当月最后一天
        string dtTime=new DateTime(dtNow.AddMonths(13).Year, dtNow.AddMonths(13).Month, 1).AddDays(-1).ToString("yyyyMMdd");
        

        return dtTime;

        //DataTable data = ASHelper.callQuery(context, "ParkTagEndDate");
        //if (data.Rows.Count == 0)
        //{
        //    context.AddError("S00501B001: 缺少系统参数-园林年卡结束日期");
        //    return "";
        //}
        //Object[] row = data.Rows[0].ItemArray;
        //return (string)row[0];
    }

    //重置收款信息和费用信息

    private void clearRadio(object sender, EventArgs e)
    {
        radioGeneral.Checked = false;
        radioXXGeneral.Checked = false;
        initLoad(sender, e);
        txtChanges.InnerHtml = "0.00";
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        hfPic.Value = "";
        Session["PicData"] = null;
        Session["PicDataOther"] = null;//add by youyue 2014/5/13
        preview_size_fake.Src = "";

        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        btnPrintPZ.Enabled = false;
        hidWarning.Value = "";
        clearRadio(sender, e);

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取帐户相关信息
        checkAccountInfo(txtCardNo.Text);

        // 读取客户资料
        readCustInfo(txtCardNo.Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        //读取照片信息
        readCardPic(txtCardNo.Text);

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

        // 检查黑名单
        checkBlackList();

        //检查身份证信息表黑名单
        checkPaperNoBlackList();


        // 判断卡片内园林功能是否到期，否则提示无需开通


        checkGardenFeature();

        // 读取当前园林结束日期
        // readParkEndDate();
        labGardenEndDate.Text = hidParkInfo.Value.Substring(0, 8);

        // 读取可用次数
        // readParkTimes();
        string times = hidParkInfo.Value.Substring(10, 2);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + Convert.ToInt32(times, 16);

        DataTable data = ASHelper.callQuery(context, "CheckParkNew", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            hidWarning.Value += "当前卡片是由老卡换卡售出，<br>且老卡已经是有效园林年卡。<br><br>老卡号:<span class='red'>"
                + data.Rows[0].ItemArray[0] + "</span>。<br>";
        }

        if (context.hasError())
        {
            //btnUpload.Enabled = false;
            btnSubmit.Enabled = false;
            return;
        }

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料


        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        //btnUpload.Enabled = hidWarning.Value.Length == 0;
        btnSubmit.Enabled = hidWarning.Value.Length == 0;

        // 如果存在警告信息，则提示是否继续开卡



        if (hidWarning.Value.Length > 0)
        {
            hidWarning.Value += Server.HtmlDecode("<br>是否需要续费?");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "warnScript",
                "warnConfirm();", true);
        }

    }

    // 对话框确认按钮处理



    protected void btnConfirm_Click(object sender, EventArgs e)
    {

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料


        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        if (hidWarning.Value == "yes")               // 是否继续
        {
            //btnUpload.Enabled = true;
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
              selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("园林年卡前台写卡成功，年卡已经续费");

            #region add by liuhe  20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion
        }
        else if (hidWarning.Value == "writeFail")    // 写卡失败
        {
            context.AddError("园林年卡前台写卡失败，年卡续费失败");
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
        //custInfoParkValidate(txtCustName, txtCustBirth,
        //    selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
        //    txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-11-14
        if (radioGeneral.Checked == false && radioXXGeneral.Checked == false)
        {
            context.AddError("A094780015:收款金额必须选择一项");
        }
    }

    //客户信息校验
    private void custInfoParkValidate(TextBox txtCustName, TextBox txtCustBirth,
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
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        submitValidate();

        //输入用户信息后需重新身份证验证黑名单
        checkPaperNoBlackList();

        string str = ASHelper.readParkTimes(context);
        int usableTimes = int.Parse(str);
        str = readParkEndDate();

        if (context.hasError()) return;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值

        //获取身份证Code
        string paperTypeCode = string.Empty;
        DataTable data = ASHelper.callQuery(context, "ReadPaperCode", selPaperType.Text);
        if (data.Rows.Count > 0)
        {
            paperTypeCode = (string)data.Rows[0].ItemArray[0];
        }

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用园林年卡开卡存储过过程
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("p_tradeFee").Value = (int)(Double.Parse(hidAccRecv.Value) * 100);
        context.AddField("p_operCardNo").Value = context.s_CardID; // 操作员卡
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566
        // 12位,年月日8位+标志位2位+次数2位


        // 园林年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制.
        context.AddField("p_oldEndDateNum").Value = hidParkInfo.Value;

        hidParkInfo.Value = str.Trim() + "01" + usableTimes.ToString("X2");
        context.AddField("p_endDateNum").Value = hidParkInfo.Value;

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();

        context.AddField("P_CUSTSEX").Value = selCustSex.Text == "男" ? "0" : "1";
        context.AddField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.AddField("P_PAPERTYPE").Value = paperTypeCode;

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

        //add by jiangbb 2012-08-21 
        context.AddField("P_PASSPAPERNO").Value = custPaperNo; //加密证件号码---2013-05-16 置为明文
        context.AddField("P_PASSCUSTNAME").Value = txtCustName.Text;//加密姓名---2013-05-16 置为明文

        //add by jiangbb 2012-11-13 增加园林同步接口RSRV1字段
        context.AddField("P_RSRV1").Value = (hidAccRecv.Value == "120.00" ? "01" : "02") + "," + "02";
        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_GardenCardRenew");
        //btnUpload.Enabled = false;
        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息


        if (ok)
        {

            ////保存照片 changed by youyue





            // AddMessage("D005010001: 园林年卡后台开卡成功，等待写卡操作");
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startPark();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "园林年卡续费", "0.00"
               , "0.00", "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
               context.s_DepartName,
               selPaperType.Text == "" ? "" : selPaperType.Text, "0.00", hidAccRecv.Value);
        }

        hfPic.Value = "";
        Session["PicData"] = null;
        Session["PicDataOther"] = null; //add by youyue 2014/5/13
        preview_size_fake.Src = "";

        txtChanges.InnerHtml = (Convert.ToDecimal(txtRealRecv.Text) - Convert.ToDecimal(hidAccRecv.Value)).ToString("0.00");
        readCardPic(txtCardNo.Text);
    }
    //查询身份证是否开通园林功能 wdx 20111116
    protected void txtSearch_Click(object sender, EventArgs e)
    {
        //判读是否开通

        StringBuilder strBuilder = new StringBuilder();
        string paperNo = "";
        if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
        {
            paperNo = txtPaperNo.Text.Trim();
        }
        else
        {
            paperNo = hidForPaperNo.Value;
        }
        AESHelp.AESEncrypt(paperNo, ref strBuilder);

        DataTable data = ASHelper.callQuery(context, "QueryPaperIsPark", strBuilder.ToString());
        if (data != null && data.Rows.Count > 0)
        {
            string temp = "已开通园林功能的卡数量为：" + data.Rows.Count.ToString() + "。";
            foreach (DataRow dr in data.Rows)
            {
                temp += "卡号：" + dr[0].ToString() + ",有效期：" + dr[1].ToString() + ";";
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "checkResidentIsFirstSupply", "alert('" + temp + "');", true);
            //context.AddMessage( "该身份证号已经至少存在一张卡片已经开通园林功能");
        }
    }

    protected void Radio_CheckedChanged(object sender, EventArgs e)
    {
        //普通120元选项卡勾选

        if (radioGeneral.Checked)
        {
            hidAccRecv.Value = "120.00";
            annualFee.Text = "120.00";
            txtRealRecv.Text = "120";
        }
        else
        {
            hidAccRecv.Value = "60.00";
            annualFee.Text = "60.00";
            txtRealRecv.Text = "60";
        }

        //本次应找
        txtChanges.InnerHtml = (Convert.ToDecimal(txtRealRecv.Text) - Convert.ToDecimal(hidAccRecv.Value)).ToString("0.00");

        //费用合计
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(annualFee.Text)).ToString("0.00");

    }

    //显示照片
    protected void BtnShowPic_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
        Session["PicDataOther"] = null;
        preview_size_fake.Src = "";

        string str = hfPic.Value;

        if (string.IsNullOrEmpty(str))
            return;

        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);

        Session["PicData"] = pic;
        preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
    }

    int HexStrToBytes(string strSou, ref byte[] BytDes, int bytCount)
    {
        int i;
        int len;
        int HighByte, LowByte;

        len = strSou.Length;
        if (bytCount * 2 < len) len = bytCount * 2;

        if ((len - len / 2 * 2) == 0)
        {
            for (i = 0; i < len; i += 2)
            {
                HighByte = (byte)strSou[i];
                LowByte = (byte)strSou[i + 1];

                if (HighByte > 0x39) HighByte -= 0x37;
                else HighByte -= 0x30;

                if (LowByte > 0x39) LowByte -= 0x37;
                else LowByte -= 0x30;

                BytDes[i / 2] = (byte)((HighByte << 4) | LowByte);
            }
            for (; i < bytCount * 2; i += 2)
            {
                BytDes[i / 2] = 0;
            }
            return (len / 2);
        }
        else
            return 0;
    }

    private void readCardPic(string cardNo)
    {
        byte[] imageData = ReadImage(cardNo);

        if (imageData != null)
        {
            Session["PicData"] = imageData;
            preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
            tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414
        }
        else
        {
            context.SPOpen();
            context.AddField("p_CARDNO").Value = cardNo;
            context.AddField("p_LENGTH", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_AS_SMK_PICTURELENGTH");
            if (ok)
            {
                string length = context.GetFieldValue("p_LENGTH").ToString().Trim();
                if (length != "1")
                {
                    tdMsg.Visible = true;//如果卡管里也不存在用户照片，则提示采集照片提示信息add by youyue20140512
                }
                else
                {
                    tdMsg.Visible = false;
                }

            }
        }
    }

    private byte[] ReadImage(string cardNo)
    {
        string selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where CARDNO=:CARDNO";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = cardNo;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }

    private void SavePic()
    {
        string str = hfPic.Value;

        if (string.IsNullOrEmpty(str) && Session["PicDataOther"] == null)//如果二代身份证照片和单张导入照片都不存在
            return;

        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);

        context.DBOpen("Select");
        context.AddField(":p_cardNo").Value = txtCardNo.Text.Trim();
        DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTO_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");

        string sql = "";
        if (dt.Rows.Count == 0)
        {
            context.DBOpen("Insert");
            sql = "INSERT INTO TF_F_CARDPARKPHOTO_SZ (CARDNO  , PICTURE ,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO) VALUES(:p_cardNo, :BLOB,:OPERATETIME,:OPERATEDEPARTID,:OPERATESTAFFNO)";
        }
        else
        {
            context.DBOpen("Update");
            sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";

        }

        context.AddField(":p_cardNo", "String").Value = txtCardNo.Text.Trim();
        context.AddField(":BLOB", "Blob").Value = pic;
        context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
        context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
        context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;

        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

    /// <summary>
    /// 获取图片二进制流文件 add by youyue 20140414
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M,文件上传失败");
            return null;
        }

        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;

    }
    /// <summary>
    /// 导入或更新照片
    /// </summary>
    /// <param name="p_cardno">cardno</param>
    /// <param name="buff">图片二进制流文件</param>
    private void UpdateParkImg(string p_cardno, byte[] buff)
    {
        if (buff != null)
        {

            context.DBOpen("Select");
            context.AddField(":p_cardNo").Value = txtCardNo.Text.Trim();
            DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTO_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");

            string sql = "";
            if (dt.Rows.Count == 0)
            {
                context.DBOpen("BatchDML");
                sql = "INSERT INTO TF_F_CARDPARKPHOTO_SZ (CARDNO  , PICTURE ,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO) VALUES(:p_cardNo, :BLOB,:OPERATETIME,:OPERATEDEPARTID,:OPERATESTAFFNO)";
            }
            else
            {
                context.DBOpen("BatchDML");
                sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";

            }

            context.AddField(":p_cardNo", "String").Value = txtCardNo.Text.Trim();
            context.AddField(":BLOB", "BLOB").Value = buff;
            context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
            context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
            context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;

            context.ExecuteNonQuery(sql);
            context.DBCommit();


        }
    }
}
