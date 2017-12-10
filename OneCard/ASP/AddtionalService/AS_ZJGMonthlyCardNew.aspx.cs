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
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;
using TDO.CardManager;
using Master;

// wdx 20111117张家港月票卡售卡
public partial class ASP_AddtionalService_AS_ZJGMonthlyCardNew : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        hidReissue.Value = Request.Params["Reissue"];
        labTitle.Text = hidReissue.Value != "true" ? "月售" : "月补";
        labSubTitle.Text = hidReissue.Value != "true" ? "月票卡售卡" : "月票卡补卡";

        if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

        // 设置可读属性

        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";
        
        // 初始化月票类型
        initMonthlyCardTypeList(selMonthlyCardType);

        // 行政区域
        //selMonthlyCardDistrict.Items.Add(new ListItem("---请选择---", ""));

        // 初始化证件类型
        ASHelper.initPaperTypeList(context, selPaperType);
        
        // 初始化性别
        ASHelper.initSexList(selCustSex);
        
        // 初始化费用列表
        initGridView();
    }
    //张家港的，写入到卡片中，残疾人爱心卡的标志为11，老年人免费卡的标志为12 wdx 20111116
    public static void initMonthlyCardTypeList(DropDownList lst)
    {
        lst.Items.Add(new ListItem("---请选择---", ""));
        lst.Items.Add(new ListItem("11:残疾人爱心卡", "11"));
        lst.Items.Add(new ListItem("12:老年人免费卡", "12"));
        lst.Items.Add(new ListItem("16:公交公司员工卡", "16"));
        lst.Items.Add(new ListItem("17:志愿者卡", "17"));//add by youyue 20140610增加'17：志愿者卡'优惠票种
    }

    // 初始化费用项gridview
    private void initGridView()
    {
        // 业务类型编码表：8A张家港残疾人爱心卡开卡，8B张家港老年人免费卡开卡
        string type = selMonthlyCardType.SelectedValue;

        // 根据月票类型得到换卡的业务类型编码
        if (hidReissue.Value != "true")
        {
            hidTradeTypeCode.Value
                = type == "11" ? "8A" // 张家港残疾人爱心卡开卡

                : type == "12" ? "9E" // 张家港老年人免费卡开卡

                : type == "16" ? "9H" // 9H公交公司员工卡开卡
                : type == "17" ? "9M" // 9M志愿者卡开卡  add by youyue 20140610
                : "";
        }
        else
        {
            pnlOld.Visible = true;
            btnReadCard.Enabled = false;
            hidTradeTypeCode.Value
                = type == "11" ? "8B" // 张家港残疾人爱心卡补卡

                : type == "12" ? "9B" //  张家港老年人免费卡补卡

                : type == "16" ? "9I" //  张家港老年人免费卡补卡
                : type == "17" ? "9N" //  9N志愿者卡补卡  add by youyue 20140610

                : "";
        }

        initFeeItem(gvResult, hidTradeTypeCode.Value, hidDeposit, 
            hidCardPost, hidOtherFee, hidAccRecv,
            txtRealRecv, false, 0, 0);
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {

        //if (txtCardno.Text.Substring(0, 6) != "215016")//张家港卡
        //{
        //    context.AddError("卡号前6位必须是215016");
        //    return;
        //}

        //modified by liuhe20120106  
        //补卡页面，旧卡开通功能不是16(公交公司员工卡)的情况下,新卡卡号必须以215016开头
        if (hidReissue.Value.Equals("true") 
            && !hidMonthlyFlag.Value.Equals("16") 
            && txtCardno.Text.Substring(0, 6) != "215016")
        {
            context.AddError("卡号前6位必须是215016");
        }

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
     
        #endregion

         //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            // 读取卡片类型
            readCardType(txtCardno.Text, labCardType);

            // 读取卡片状态


            ASHelper.readCardState(context, txtCardno.Text, txtCardState);
            //checkCardState(txtCardno.Text);

            // 检查新卡卡内余额

            //if (txtCardBalance.Text != "0.00")
            //{
            //    context.AddError("A001001144");
            //}

            btnPrintSJ.Enabled = false;

            btnSubmit.Enabled = !context.hasError();
        }
        else if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardno.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            return;
        }
    }

    // 确认对话框确认处理
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {

            #region 如果是前台黑名单锁卡
            //前台锁卡没有写写卡台账

            if (this.hidLockBlackCardFlag.Value == "yes")
            {
                AddMessage("黑名单卡已锁");
                clearCustInfo(txtCardno);
                this.hidLockBlackCardFlag.Value = "";
                return;
            }
            #endregion

            clearCustInfo(selMonthlyCardType,
               txtCardno, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage(hidReissue.Value != "true" 
                ? "D005090002: 月票卡前台写卡成功，月票卡售卡成功"
                : "D005100002: 月票卡前台写卡成功，月票卡补卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {           
            context.AddError(hidReissue.Value != "true"  
                ?"A00509C001: 月票卡前台写卡失败，月票卡售卡失败"
                : "A00510C001: 月票卡前台写卡失败，月票卡补卡失败");
        }

        if (chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printShouJu();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    // 提交判断
    private void submitValidate()
    {
        // 校验客户信息
        custInfoForValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        valid.check(selMonthlyCardType.SelectedValue != "", "A005090001: 月票类型必须选择", selMonthlyCardType);
        //valid.check(selMonthlyCardDistrict.SelectedValue != "", "A005090002: 行政区域必须选择", selMonthlyCardDistrict);
        //valid.check(selCustSex.SelectedValue != "", "A005090003: 性别必须选择", selCustSex);
    }

    private void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);

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

        b = Validation.isEmpty(txtPaperNo);
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


    // 刷新行政区域选择
    protected void selMonthlyCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        initGridView();
    }
    //查询旧卡的月票功能和有效期

    protected void btnSearchOld_Click(object sender, EventArgs e)
    {
        DataTable data = ASHelper.callQuery(context, "QueryZJGOldCardMonth", txtOldCardno.Text);

        if (data.Rows.Count != 1)
        {
            context.AddError("未查询到旧卡的月票类型");
            return;
        }
        lblENDDATE.Text = data.Rows[0]["ENDTIME"].ToString();
        hidMonthlyFlag.Value = data.Rows[0]["APPTYPE"].ToString();
        if (lblENDDATE.Text.Length != 8)
        {
            context.AddError("未查询到旧卡的有效期");
            return;
        }
        if (hidMonthlyFlag.Value != "11" && hidMonthlyFlag.Value != "12" && hidMonthlyFlag.Value != "16" && hidMonthlyFlag.Value != "17")//增加'17：志愿者卡'优惠票种
        {
            context.AddError("旧卡的月票不符合要求");
            return;
        }
        //查询开通功能

        PBHelper.openFunc(context, openFunc, txtOldCardno.Text);
        btnReadCard.Enabled = !context.hasError();
        selMonthlyCardType.SelectedValue = hidMonthlyFlag.Value;


        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtOldCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase; 
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return;
        }

        //性别显示
        if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
            selCustSex.SelectedValue = "0";
        else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
            selCustSex.SelectedValue = "1";
        else selCustSex.SelectedValue = "";

        //出生日期显示
        txtCustBirth.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
        //证件类型显示
        selPaperType.SelectedValue = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
        txtCustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        txtPaperNo.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
        txtCustAddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
        txtCustPost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
        txtCustPhone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
        txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
        txtRemark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

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
    }
    // 月票卡售卡提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        
        submitValidate();
        //checkCardState(txtCardno.Text);

        //modified by liuhe20120106  
        //月票开通页面，开通功能不是16(公交公司员工卡)的情况下,卡号必须以215016开头
        if (hidReissue.Value.Equals("true"))
        {
            if (!selMonthlyCardType.SelectedValue.Equals(hidMonthlyFlag.Value))
            {
                context.AddError("旧卡月票类型与所选月票类型不一致");
            }
        }
        else
        {
            if (!selMonthlyCardType.SelectedValue.Equals("16") && txtCardno.Text.Substring(0, 6) != "215016")
            {
                context.AddError("卡号前6位必须是215016");
            }
        }

        if (context.hasError()) return;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用月票卡售卡存储过程
        SP_AS_ZJGMonthlyCardNewPDO pdo = new SP_AS_ZJGMonthlyCardNewPDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardno.Text;

        pdo.deposit = (int)(Double.Parse(hidDeposit.Value) * 100);
        pdo.cardCost = (int)(Double.Parse(hidCardPost.Value) * 100);
        pdo.otherFee = (int)(Double.Parse(hidOtherFee.Value) * 100); 

        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.asn = hidAsn.Value.Substring(4, 16);
        pdo.cardMoney = (int)(Double.Parse(txtCardBalance.Text) * 100);
        pdo.sellChannelCode = "01";
        pdo.serTakeTag = "3";
        pdo.tradeTypeCode = hidTradeTypeCode.Value;
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        StringBuilder strBuilder = new StringBuilder();
        pdo.custName = txtCustName.Text;
        //ADD BY JIANGBB 2012-04-19加密  
        
        AESHelp.AESEncrypt(pdo.custName, ref strBuilder);
        pdo.custName = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        pdo.custPhone = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        pdo.custAddr = strBuilder.ToString();

        pdo.custBirth = txtCustBirth.Text;
        pdo.paperType = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        pdo.paperNo = strBuilder.ToString();

        pdo.custSex = selCustSex.SelectedValue;
        pdo.custPost = txtCustPost.Text;
        pdo.custEmail = txtEmail.Text;
        pdo.remark = txtRemark.Text;
        pdo.custRecTypeCode = "0";
        pdo.appType = selMonthlyCardType.SelectedValue;
        pdo.assignedArea = "";
        pdo.currCardNo = context.s_CardID;
        //增加是否是补换卡页面标识 add by youyue 20150215
        pdo.isChangeCard = hidReissue.Value == "true" ? "1" : "0";
        pdo.oldCardNo = hidReissue.Value == "true" ? txtOldCardno.Text : "";
        //hidMonthlyFlag.Value = pdo.assignedArea + (pdo.custSex == "0" ? "C1" : "C0");
        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;
        // 存储过程执行成功，显示成功消息
        if (ok)
        {            
            // 准备收据打印数据
            ASHelper.prepareShouJu(ptnShouJu, txtCardno.Text, context.s_UserName, hidAccRecv.Value);
            btnPrintSJ.Enabled = true;
            hidZJGMonthlyFlag.Value = selMonthlyCardType.SelectedValue + context.GetField("p_ENDDATE").Value;
            if (hidReissue.Value == "true")
            {
                btnReadCard.Enabled = false;
                hidZJGMonthlyFlag.Value = hidMonthlyFlag.Value+ lblENDDATE.Text;
            }
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startZJGMonthlyInfo();", true);
            btnSubmit.Enabled = false;
            
        }
    }
}
