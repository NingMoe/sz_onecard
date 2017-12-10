using System;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;

// 惠民亲子卡开通处理


public partial class ASP_AddtionalService_AS_AffectCardNew : Master.FrontMaster
{
    // 页面装载
    #region pageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        hidStaffNo.Value = Session["STAFF"].ToString();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "js",
               "loadWebcam();", true);

        if (radioGeneral.Checked)
        {
            annualFee.Text = "379.00";
            Total.Text = "379.00";
        }
        else if (radioXXGeneral.Checked)
        {
            annualFee.Text = "479.00";
            Total.Text = "479.00";
        }

        if (Page.IsPostBack) return;

        Session["PicData"] = null;
        Session["PicDataOther"] = null;
        // 设置可读属性

        if (!context.s_Debugging)
        {
            txtCardNo.Attributes["readonly"] = "true";
        }

        setReadOnly(txtCardBalance, txtStartDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "recvChanging();";

        txtDiscount.Attributes["onfocus"] = "this.select();";
        txtDiscount.Attributes["onkeyup"] = "recvChanging();";

        radioGeneral.Attributes["onfocus"] = "this.select();";
        radioGeneral.Attributes["onclick"] = "setGeneral(this);";

        radioXXGeneral.Attributes["onfocus"] = "this.select();";
        radioXXGeneral.Attributes["onclick"] = "setXXGeneral(this);";



        // 初始化证件类型


        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        // 初始化费用列表
        initLoad(sender, e);

        //decimal total = initFeeList(gvResult, "25", 7);

        //txtRealRecv.Text = total.ToString("0");
        //hidAccRecv.Value = total.ToString("n");

        Session["PicData"] = null;

        tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414



        //有效期限
        context.DBOpen("Select");
        string sql = @"SELECT substr(trim(TAGVALUE), 1, 8) FROM  TD_M_TAG 
                            WHERE   TAGCODE = 'AffectPARK_ENDDATE' AND USETAG = '1'";
        DataTable table = context.ExecuteReader(sql);
        cardUseEndTime = Convert.ToString(table.Rows[0][0]);
    }
    #endregion

    #region Button Click

    protected void selChargeType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selChargeType.SelectedValue == "01") //现金
        {
            labPrompt.Visible = false;
            txtPrompt.Visible = false;
            labPromptFor.Visible = false;
            radioGeneral.Enabled = radioXXGeneral.Enabled = true;
        }
        else
        {
            txtPrompt.Text = "";
            labPrompt.Visible = true;
            txtPrompt.Visible = true;
            labPromptFor.Visible = true;
            radioGeneral.Enabled = radioXXGeneral.Enabled = false;
        }
        radioGeneral.Checked = radioXXGeneral.Checked = false;
        txtRealRecv.Text = "";
        txtDiscount.Text = "";
        annualFee.Text = "0.00";
        Total.Text = "0.00";
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        hfPic.Value = "";
        Session["PicData"] = null;
        //preview_size_fake.Src = "";

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
        #endregion

        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        #region 卡账户有效性检验 黑名单卡则锁卡
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardNo.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardNo.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            return;
        }
        #endregion

        checkRelaxIsInvalid();//判断当前卡是否是是休闲账户表中无效的卡 add by youyue 20141229

        checkParkIsInvalid();//判断当前卡是否是有效的休闲年卡

        btnPrintPZ.Enabled = false;
        hidWarning.Value = "";
        clearRadio(sender, e);

        //判断是否是市民卡，是则不能读二代证和修改姓名、证件类型、证件号码
        if (txtCardNo.Text.Substring(0, 6) == "215018")
        {
            txtReadPaper.Enabled = false;
            txtCustName.Enabled = false;
            selPaperType.Enabled = false;
            txtPaperNo.Enabled = false;
        }
        else
        {
            txtReadPaper.Enabled = true;
            txtCustName.Enabled = true;
            selPaperType.Enabled = true;
            txtPaperNo.Enabled = true;
        }

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

        // 判断卡片内园林功能是否到期，否则提示无需开通


        checkRelaxFeature();

        // 读取惠民休闲年卡结束日期
        // readXXParkEndDate();
        labGardenEndDate.Text = hidParkInfo.Value.Substring(0, 8);

        // 读取可用次数
        // readXXParkTimes();
        string times = hidParkInfo.Value.Substring(10, 2);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + Convert.ToInt32(times, 16);

        DataTable data = ASHelper.callQuery(context, "CheckXXParkNew", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            hidWarning.Value += "当前卡片是由老卡换卡售出，<br>且老卡已经是有效惠民亲子卡。<br><br>老卡号:<span class='red'>"
                + data.Rows[0].ItemArray[0] + "</span>。<br>";
        }

        if (context.hasError()) return;

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
            hidWarning.Value += Server.HtmlDecode("<br>是否继续开卡?");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "warnScript",
                "warnConfirm();", true);
        }

    }

    // 对话框确认按钮处理
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        //add by jiangbb 2012-10-09 市民卡不能修改客户资料

        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        if (hidWarning.Value == "yes")                // 是否继续
        {
            //btnUpload.Enabled = true;
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")  // 写卡成功
        {
            #region 如果是前台黑名单锁卡
            //前台锁卡没有写写卡台账

            if (this.hidLockBlackCardFlag.Value == "yes")
            {
                AddMessage("黑名单卡已锁");
                clearCustInfo(txtCardNo);
                this.hidLockBlackCardFlag.Value = "";
                return;
            }
            #endregion

            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
                selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("D005050003: 惠民亲子卡前台写卡成功，年卡已经开通");

            #region add by liuhe  20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion
        }
        else if (hidWarning.Value == "writeFail")     // 写卡失败
        {
            context.AddError("A00505C001: 惠民亲子卡前台写卡失败，年卡开通失败");
        }

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = "";                       // 清除消息内容
    }


    /// <summary>
    /// 照片导入
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (FileUpload1.PostedFile.FileName != "")       //导入方式
        {
            System.IO.Stream fileStream = Stream.Null;
            int flag = validateForPicture(FileUpload1, out fileStream);
            if (flag == -1) return;
            string path = HttpContext.Current.Server.MapPath("../../tmp/pic_thu_" + Session["STAFF"].ToString() + ".jpg");
            bool bl = GetPicThumbnail(fileStream, path, flag);
            Session["PicData"] = GetPicture(path);
        }

        if (Session["PicData"] == null)
        {
            context.AddError("没有照片信息！");
            return;
        }

        //ValidatePicFormat();
        preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
        context.AddMessage("照片已导入，点击提交按钮后生效！");

        return;
    }


    protected void txtPrompt_Changed(object sender, EventArgs e)
    {
        if (txtPrompt.Text.Trim().Length == 16)
        {
            string strCliper = "";
            //兑换卡密码加密
            int ret = -1;
            int ret2 = -1;
            string token;
            int epochSeconds;
            string plain = txtPrompt.Text.Trim();//明文
            StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位

            //打开服务
            ret = RMEncryptionHelper.Open();
            if (ret != 0)
            {
                context.AddError("打开服务失败！");
                return;
            }
            else
            {
                context.AddError("打开服务成功");
            }

            //获得TOKEN值
            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable data = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)data.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
            epochSeconds = (int)epochTime.TotalSeconds;

            // 加密
            ret2 = RMEncryptionHelper.EncodeString(context.s_CardID, token, epochSeconds, 0, plain, cliper);
            if (ret2 != 0)
            {
                context.AddError("加密失败!");
                RMEncryptionHelper.Close();
                return;
            }
            else
            {
                strCliper = cliper.ToString();
            }
            RMEncryptionHelper.Close();

            DataTable dt = ASHelper.callQuery(context, "QueryXFCardMoney", strCliper);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("兑换卡数据为空");
                return;
            }
            if (dt.Rows[0][1].ToString() == "37900")
            {
                hidFuncType.Value = "E3";
                txtRealRecv.Text = "379";
                txtDiscount.Text = "0";
                radioGeneral.Checked = true;
                radioXXGeneral.Checked = false;
                radioGeneral.Enabled = radioXXGeneral.Enabled = false;
                labPromptFor.Text = "兑换卡为379套餐";
            }
            else if (dt.Rows[0][1].ToString() == "47900")
            {
                hidFuncType.Value = "E4";
                txtRealRecv.Text = "479";
                txtDiscount.Text = "0";
                radioGeneral.Checked = false;
                radioXXGeneral.Checked = true;
                radioGeneral.Enabled = radioXXGeneral.Enabled = false;
                labPromptFor.Text = "兑换卡为479套餐";
            }
            Page_Load(sender, e);
        }
    }

    //读二代证后存入Session
    protected void BtnShowPic_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
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
        
        string str = ASHelper.readAffectParkTimes(context);
        int usableTimes = int.Parse(str);
        str = readAffectParkEndDate();

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        StringBuilder strPaperNoBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strPaperNoBuilder);

        if (context.hasError()) return;

        hidNewCardNo.Value = txtCardNo.Text;

        // 惠民休闲年卡的套餐的标志位为E3或者E4.次数都是16进制.
        string strParkInfo = str.Trim() + hidFuncType.Value + usableTimes.ToString("X2");

        if (strParkInfo.Trim().Length != 12)
        {
            context.AddError("写卡数据有误");
            return;
        }

        //获取套餐类型
        string tradeFee = string.Empty;
        string packageTypeCode = string.Empty;
        string strCliper = "";
        if (selChargeType.SelectedValue == "01") // 现金类型
        {
            tradeFee = (Double.Parse(hidAccRecv.Value) * 100).ToString();
            packageTypeCode = radioGeneral.Checked ? "E3" : "E4";
        }
        //兑换卡类型
        else
        {
            hidAccRecv.Value = "0.00";
            packageTypeCode = hidFuncType.Value;
            if (hidFuncType.Value == "E3")
            {
                tradeFee = "37900";
            }
            else if (hidFuncType.Value == "E4")
            {
                tradeFee = "47900";
            }
            else
            {
                context.AddError("兑换卡类型错误！");
                return;
            }

            //兑换卡密码加密
            int ret = -1;
            int ret2 = -1;
            string token;
            int epochSeconds;
            string plain = txtPrompt.Text.Trim();//明文
            StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位

            // 打开服务
            ret = RMEncryptionHelper.Open();
            if (ret != 0)
            {
                context.AddError("打开服务失败！");
                return;
            }
            else
            {
                context.AddError("打开服务成功");
            }

            // 获得TOKEN值


            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable data = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)data.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
            epochSeconds = (int)epochTime.TotalSeconds;

            // 加密
            ret2 = RMEncryptionHelper.EncodeString(context.s_CardID, token, epochSeconds, 0, plain, cliper);
            if (ret2 != 0)
            {
                context.AddError("加密失败!");
                RMEncryptionHelper.Close();
                return;
            }
            else
            {
                strCliper = cliper.ToString();
            }
            RMEncryptionHelper.Close();
        }

        // 调用惠民休闲年卡开卡存储过过程
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("p_tradeFee").Value = tradeFee;
        context.AddField("P_discount").Value = (Double.Parse(txtDiscount.Text) * 100).ToString();
        context.AddField("p_operCardNo").Value = context.s_CardID; // 操作员卡
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566
        // 12位,年月日8位+标志位2位+次数2位


        // 卡片历史参数数据
        context.AddField("p_oldEndDateNum").Value = hidParkInfo.Value;

        //卡片新写入参数数据
        hidParkInfo.Value = strParkInfo;
        context.AddField("p_endDateNum").Value = hidParkInfo.Value;

        context.AddField("p_ACCOUNTTYPE").Value = "1";      //账户类型 0：线下开通 1：线上开通
        context.AddField("p_PACKAGETPYECODE").Value = packageTypeCode;    //套餐类型

        //add by jiangbb 加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustSex.SelectedValue;
        context.AddField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.AddField("P_PAPERTYPE").Value = selPaperType.SelectedValue;

        context.AddField("P_PAPERNO").Value = strPaperNoBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = txtEmail.Text;
        context.AddField("P_REMARK").Value = txtRemark.Text;
        if (selChargeType.SelectedValue == "02")    //选择的是充值卡类型录入充值密码
        {
            context.AddField("P_PASSWD").Value = strCliper;
        }
        else
        {
            context.AddField("P_PASSWD").Value = "";
        }

        context.AddField("p_passPaperNo").Value = custPaperNo;          //明文证件号码
        context.AddField("p_passCustName").Value = txtCustName.Text;    //明文姓名
        context.AddField("p_CITYCODE").Value = "2150";    //城市代码

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_AffectCardNew_BAT");

        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息


        if (ok)
        {
            //上传照片
            try
            {
                SavePic();
                readCardPic(txtCardNo.Text);
                context.AddMessage("照片上传成功");
                hidPicType.Value = null;
                Session["PicData"] = null;
            }
            catch
            {
                context.AddMessage("S00501B014：保存照片失败");//系统是否存在照片不做为园林开通/续费的必要条件
            }

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startXXPark();", true);

            btnPrintPZ.Enabled = true;


            ASHelper.preparePingZheng(ptnPingZheng, context.s_DepartName, context.s_UserID,
                "亲子卡开通", DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value),
                hidAccRecv.Value, hidAccRecv.Value, txtCardNo.Text, cardUseEndTime);
        }

        hfPic.Value = "";
        Session["PicData"] = null;
        hidNewCardNo.Value = "";
        preview_size_fake.Src = "";
        readCardPic(txtCardNo.Text);

        //清除信息
        radioGeneral.Checked = false;
        radioXXGeneral.Checked = false;
        annualFee.Text = "0.00";
        Total.Text = "0.00";
        txtRealRecv.Text = "0";
        txtDiscount.Text = "0";
        txtChanges.InnerHtml = "0.00";
        txtPrompt.Text = "";
        labPromptFor.Text = "";
    }
    #endregion

    #region Private
    private static string cardUseEndTime = "";

    #region validation

    // 提交校验
    private void submitValidate()
    {
        // 客户信息校验
        custInfoForValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-11-14
        if (radioGeneral.Checked == false && radioXXGeneral.Checked == false)
        {
            context.AddError("A094780015:请选择一项亲子卡套餐");
        }
        if (selChargeType.SelectedValue == "02" && txtPrompt.Text.Trim().Length != 16)
        {
            context.AddError("A094780059:兑换卡密码长度有误");
        }

        context.SPOpen();
        context.AddField("p_CARDNO").Value = txtCardNo.Text;
        context.AddField("p_LENGTH", "String", "output", "16", null);
        bool ok = context.ExecuteSP("SP_AS_SMK_PICTURELENGTH");
        string length = "";
        if (ok)
        {
            length = context.GetFieldValue("p_LENGTH").ToString().Trim();
        }

        if (Session["PicData"] == null && length != "1")
        {
            context.AddError("该卡没有上传照片，请先上传照片");
        }
    }

    //客户信息校验
    private void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
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

        //只有证件类型为身份证时才对证件号码作验证
        if (selPaperType.SelectedValue == "00")
        {
            if (!b)
            {
                b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20", txtPaperNo);
                b = valid.check(Validation.strLen(txtPaperNo.Text) == 18, "A094570237：身份证号码长度必须为18位", txtPaperNo);
                //判断是否有客户信息查看权限

                if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
                {
                    if (b)
                    {
                        valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                    }
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

    // 检查黑名单列表
    private void checkBlackList()
    {
        // 从休闲卡黑名单信息表中查询


        DataTable data = ASHelper.callQuery(context, "XXParkBlackList", txtCardNo.Text);
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

    // 检查惠民休闲年卡特征值


    private void checkRelaxFeature()
    {
        // 按照卡号读取结束日期
        DataTable data = ASHelper.callQuery(context, "XXParkCardEndDate", txtCardNo.Text);
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

        DataTable openDayDt = ASHelper.callQuery(context, "CheckAffectParkOpenDay", txtCardNo.Text);

        if (openDayDt != null && openDayDt.Rows.Count > 0)
        {
            DateTime dt = (DateTime)openDayDt.Rows[0].ItemArray[0];
            if (dt.Year == DateTime.Today.Year
                && dt.Month == DateTime.Today.Month
                && dt.Day == DateTime.Today.Day)
            {
                context.AddError("惠民亲子卡当日开通，不允许再次开通!");
            }
        }

        // 卡片未到期，提醒用户无需开卡。MESSAGEBOX，惠民休闲年卡未到期，是否继续开卡


        if (((string)row[0]).Substring(0, 6) == today.Substring(0, 6))
        {
            return;//卡片当月到期,不需要提示


        }
        hidWarning.Value += Server.HtmlDecode(
            "卡片已是惠民亲子卡，且未到期;<br>亲子卡到期时间为:<span class='red'>" + row[0] + "</span><br>");
    }


    //查询新卡是否是休闲账户表中无效状态的卡(即通过功能补换页面将旧卡置为无效的卡)
    private void checkRelaxIsInvalid()
    {
        // 从休闲卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "RelaxCardUseIsInvalid", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005020002: 当前卡已经是休闲账户表中无效的卡，不可再次开通");
        }
    }

    //查询新卡是否是有效的休闲年卡
    private void checkParkIsInvalid()
    {
        // 从休闲卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "ParkCardInfo", txtCardNo.Text);
        if (data.Rows.Count != 0)
        {
            string packageTypeCode = data.Rows[0][0].ToString();
            string endDate = data.Rows[0][1].ToString();
            if ((packageTypeCode != "E3" && packageTypeCode != "E4") &&
                DateTime.ParseExact(endDate, "yyyyMMdd", null) > DateTime.ParseExact(DateTime.Now.ToString("yyyyMMdd"), "yyyyMMdd", null))
            {
                context.AddError("A005020003:当前卡片已经是有效的休闲年卡，且未到期，不可再次开通亲子卡");
            }
        }
    }
    #endregion


    #region photoinfo
    /// <summary>
    /// 校验上传图片的大小以及各式
    /// </summary>
    /// <param name="file">FileUpload控件</param>
    /// <returns></returns>
    private int validateForPicture(FileUpload file, out Stream fileStream)
    {

        string[] strPics = { ".jpg", ".bmp", ".jpeg", ".png" };
        fileStream = Stream.Null;
        int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
        if (index == -1)
        {
            context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png");
            return -1;
        }
        fileStream = file.PostedFile.InputStream;
        int len = file.FileBytes.Length;
        if (len < 1024 * 10)
        {
            context.AddError("A094780014：上传文件不能小于10KB");
        }
        else if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件不能大于5M");
        }

        //文件大小返回不同压缩等级
        if (len >= 1024 * 500 && len < 1024 * 1024)
        {
            return 30;
        }
        else if (len >= 1024 * 1024 && len < 1024 * 1024 * 2)
        {
            return 10;
        }
        else if (len >= 1024 * 1024 * 2 && len < 1024 * 1024 * 5)
        {
            return 5;
        }
        else if (len >= 1024 * 10 && len < 1024 * 500)
        {
            return 50;
        }
        else
        {
            return -1;
        }
    }

    /// <summary>
    /// 获取图片二进制流文件 add by youyue 20140414
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(string path)
    {
        FileStream file = new FileStream(path, FileMode.Open, FileAccess.Read);

        byte[] buffer = new byte[file.Length];
        file.Read(buffer, 0, (int)file.Length);

        file.Dispose();
        FileInfo fi = new FileInfo(path);
        fi.Delete();
        return buffer;

    }


    /// <summary>
    /// 图片压缩
    /// </summary>
    /// <param name="sFile">图片原路径</param>
    /// <param name="outPath">图片输出路径</param>
    /// <param name="flag">压缩比例1-100</param>
    /// <returns></returns>
    private bool GetPicThumbnail(Stream fileStream, string outPath, int flag)
    {
        //FileStream fs = new FileStream(FileUpload1.PostedFile.InputStream, FileMode.Open, FileAccess.Read);
        System.Drawing.Image iSource = System.Drawing.Image.FromStream(fileStream);
        //System.Drawing.Image iSource = System.Drawing.Image.FromFile(sFile);
        ImageFormat tFormat = iSource.RawFormat;

        //以下代码为保存图片时，设置压缩质量  
        EncoderParameters ep = new EncoderParameters();
        long[] qy = new long[1];
        qy[0] = flag;//设置压缩的比例1-100  
        EncoderParameter eParam = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, qy);
        ep.Param[0] = eParam;
        try
        {
            ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();
            ImageCodecInfo jpgICIinfo = null;
            for (int x = 0; x < arrayICI.Length; x++)
            {
                if (arrayICI[x].FormatDescription.Equals("JPEG"))
                {
                    jpgICIinfo = arrayICI[x];
                    break;
                }
            }

            if (jpgICIinfo != null)
            {
                int width = (int)Math.Round((decimal)320 * iSource.Width / iSource.Height, 0);
                int height = 320;   //定高 宽度按照原始图片比例缩小
                Bitmap map = new Bitmap(width, height);
                Graphics gra = Graphics.FromImage(map);

                gra.DrawImage(iSource, new Rectangle(0, 0, width, height), new Rectangle(0, 0, iSource.Width, iSource.Height), GraphicsUnit.Pixel);
                iSource.Dispose();
                //gra.Clear(Color.Transparent);
                gra.Dispose();
                map.Save(outPath, jpgICIinfo, ep);
                map.Dispose();
            }
            else
            {
                iSource.Save(outPath, tFormat);
            }
            return true;
        }
        catch
        {
            return false;
        }
        finally
        {
            iSource.Dispose();
            iSource.Dispose();
        }
    }

    /// <summary>
    /// 校验图片格式，并且转换成JPG
    /// </summary>
    private void ValidatePicFormat()
    {
        MemoryStream ms = new MemoryStream((byte[])Session["PicData"]);

        System.Drawing.Image img = System.Drawing.Image.FromStream(ms);

        //判断图片是否是JPG格式
        if (img.RawFormat.Guid != ImageFormat.Jpeg.Guid)
        {
            using (MemoryStream mstream = new MemoryStream())
            {
                Bitmap bit = new Bitmap(img);
                bit.Save(mstream, ImageFormat.Jpeg);

                Session["PicData"] = mstream.ToArray();
                mstream.Dispose();
            }
        }
        img.Dispose();
        ms.Dispose();
    }


    private int HexStrToBytes(string strSou, ref byte[] BytDes, int bytCount)
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
        else if (cardNo.Substring(0, 6) == "215018")
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
        else
        {
            Session["PicData"] = null;
            preview_size_fake.Src = "../../nom.jpg";
            tdMsg.Visible = true;
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
        //string str = hfPic.Value;

        if (Session["PicData"] == null)
            return;

        ValidatePicFormat();

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
            InsertCardHistory();

            context.DBOpen("Update");
            sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";

        }

        context.AddField(":p_cardNo", "String").Value = txtCardNo.Text.Trim();
        context.AddField(":BLOB", "Blob").Value = Session["PicData"];
        context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
        context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
        context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;

        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

    private void InsertCardHistory()
    {
        context.DBOpen("Insert");
        StringBuilder strBuilder = new StringBuilder();
        strBuilder.Append("Insert Into TB_F_CARDPARKPHOTO_SZ(CARDNO,PICTURE,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO) ");
        strBuilder.Append("Select CARDNO,PICTURE,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO From TF_F_CARDPARKPHOTO_SZ WHERE CARDNO =:p_cardNo");

        context.AddField(":p_cardNo", "String").Value = txtCardNo.Text.Trim();
        context.ExecuteNonQuery(strBuilder.ToString());
        context.DBCommit();
    }
    #endregion

    #region getinfo
    // 从全局参数表中读取亲子卡的结束日期设置
    private String readAffectParkEndDate()
    {
        DataTable data = ASHelper.callQuery(context, "AffectParkTagEndDate");
        if (data.Rows.Count == 0)
        {
            context.AddError("S00501B004: 缺少系统参数-亲子卡结束日期");
            return "";
        }
        Object[] row = data.Rows[0].ItemArray;
        return (string)row[0];
    }


    private void initLoad(object sender, EventArgs e)
    {
        DepositFee.Text = "0.00";
        ProcedureFee.Text = "0.00";
        annualFee.Text = "0.00";

        decimal total = Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(annualFee.Text);
        Total.Text = total.ToString("0.00");

        txtRealRecv.Text = total.ToString("0");
        txtDiscount.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
    }



    private void clearRadio(object sender, EventArgs e)
    {
        radioGeneral.Checked = false;
        radioXXGeneral.Checked = false;
        initLoad(sender, e);
        txtChanges.InnerHtml = "0.00";
    }
    #endregion

    #endregion

}