using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Web.UI;
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;
using TDO.UserManager;
using System.Data;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class ASP_PersonalBusiness_HYDROPOWER_CHARGE_ROLLBACK : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //HYDROPHelper.InitItemCodes(selItemCode, true);//缴费类别

            setReadOnly(txtCardno, LabAsn, LabCardtype, sDate, eDate, cMoney, RESSTATE);
            lvwSupplyQuery.DataSource = initEmptyDataTable();
            lvwSupplyQuery.DataBind();

            ScriptManager2.SetFocus(txtAccountId);
        }
    }

    /// <summary>
    /// 初始化页面
    /// </summary>
    private void InitControl()
    {
        context.ErrorMessage.Clear();
        context.NormalMessages.Clear();
        //清空卡片信息和用户信息的TextBox和 HiddenField
        initUserCardInfo();

        txtTotalPayFee.Text = "0.00";
        hidTotalPayFee.Value = "0";

        hidRollBackWay.Value = "";
        hidResponseTradeId.Value = "";
        hidRollBackWay.Value = "";

        lvwSupplyQuery.DataSource = initEmptyDataTable();
        lvwSupplyQuery.DataBind();
    }

    private void initUserCardInfo()
    {
        //清空卡片信息的TextBox和 HiddenField
        foreach (Control control in CardInfoContent.Controls)
        {
            if (control is TextBox)
            {
                ((TextBox)control).Text = "";
            }
            else if (control is HiddenField)
            {
                ((HiddenField)control).Value = "";
            }
        }
        openFunc.List = new ArrayList();
        hiddencMoney.Value = "0";
        hidRelBalance.Value = "0";

        //清空用户信息
        foreach (Control control in UserInfoContent.Controls)
        {
            if (control is Label)
            {
                ((Label)control).Text = "";
            }
        }

        btnSupply.Enabled = false;
        btnPrintPZ.Enabled = false;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("SEQNO", typeof (string));//交易流水号
        dt.Columns.Add("CUSTOMER_NO", typeof(string));//用户号
        dt.Columns.Add("CUSTOMER_NAME", typeof(string));//用户姓名
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("CHARGE_ITEM_TYPE_DISPLAY", typeof(string));//缴费项目
        dt.Columns.Add("CHARGE_TYPE_DISPLAY", typeof(string));//缴费方式
        dt.Columns.Add("BILL_MONTH", typeof(string));//账单月份
        dt.Columns.Add("REAL_AMOUNT", typeof(string));//缴费金额
        dt.Columns.Add("REQUEST_TIME", typeof(string));//缴费时间
        dt.Columns.Add("CHARGE_STATUS_DISPLAY", typeof(string));//缴费状态

        dt.Columns["SEQNO"].MaxLength = 10000;
        dt.Columns["CUSTOMER_NO"].MaxLength = 10000;
        dt.Columns["CUSTOMER_NAME"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["CHARGE_ITEM_TYPE_DISPLAY"].MaxLength = 10000;
        dt.Columns["CHARGE_TYPE_DISPLAY"].MaxLength = 10000;
        dt.Columns["BILL_MONTH"].MaxLength = 10000;
        dt.Columns["REAL_AMOUNT"].MaxLength = 10000;
        dt.Columns["REQUEST_TIME"].MaxLength = 10000;
        dt.Columns["CHARGE_STATUS_DISPLAY"].MaxLength = 10000;

        return dt;
    }

    public void btnQuery_OnClick(object sender, EventArgs e)
    {
        btnSupply.Enabled = false;
        btnPrintPZ.Enabled = false;
        InitControl();
        doBtnQuery();
        if (context.hasError())
        {
            return;
        }
        if (!string.IsNullOrEmpty(hidQueryTradeId.Value) && !string.IsNullOrEmpty(hiddentxtCardno.Value))
        {
            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
    }

    private void doBtnQuery()
    {
        string accountId = txtAccountId.Text.Trim();
        if (accountId.Length == 0)
        {
            ScriptManager2.SetFocus(btnQuery);
            context.AddError("用户号不能为空！");
            return;
        }

        //查询逻辑
        DataTable dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_FailAndException",
            accountId, context.s_UserID);
        if (dt.Rows.Count == 0)
        {
            context.AddError("未查询到缴费失败的记录");
            return;
        }
        DataRow fristRow = dt.Rows[0];
        hidQueryTradeId.Value = fristRow["SEQNO"].ToString();
        hidTotalPayFee.Value = fristRow["REAL_AMOUNT"].ToString();
        txtTotalPayFee.Text = (Convert.ToDouble(hidTotalPayFee.Value)/100).ToString("0.00");
        string chargeType = fristRow["CHARGE_TYPE"].ToString();
        if (chargeType == "0")
        {
            hidRollBackWay.Value = "1";//表示电子钱包返销
            hidTPTradeId.Value = fristRow["TP_TRADE_ID"].ToString();
        }
        else if (chargeType == "1")
        {
            hidRollBackWay.Value = "2";//表示专有账户返销
        }
        foreach (DataRow row in dt.Rows)
        {
            row["REAL_AMOUNT"] = (Convert.ToDouble(row["REAL_AMOUNT"])/100).ToString("0.00");
        }
        lvwSupplyQuery.DataSource = dt;
        lvwSupplyQuery.DataBind();
        lvwSupplyQuery.SelectedIndex = 0;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnSupply.Enabled = false;
        btnPrintPZ.Enabled = false;
        //initUserCardInfo();

        //# region for test
        //txtCardno.Text = "00427839505";
        //hiddentxtCardno.Value = "00427839505";
        //hiddentradeno.Value = "2222";
        //hiddenAsn.Value = "0000000427839505";
        //hiddencMoney.Value = "33560";
        //hiddeneDate.Value = "20170331";
        //hiddensDate.Value = "20130331";
        //hiddenLabCardtype.Value = "01";
        //#endregion
        btnReadCardProcess();
        if (context.hasError())
        {
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }
        if (!string.IsNullOrEmpty(hidQueryTradeId.Value) && !string.IsNullOrEmpty(hiddentxtCardno.Value))
        {
            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
    }

    protected void btnReadCardProcess()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据


            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

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

            //从用户卡库存表(TL_R_ICUSER)中读取数据


            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //从资源状态编码表中读取数据


            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //给页面显示项赋值


            LabAsn.Text = hiddenAsn.Value.Substring(4, hiddenAsn.Value.Length - 4);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
            eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
            CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

            //检验卡片是否已经启用


            if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0)
            {
                context.AddError("卡片尚未启用");
                return;
            }

            //性别显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
                Custsex.Text = "男";
            else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
                Custsex.Text = "女";
            else Custsex.Text = "";

            //出生日期显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
            {
                String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
                if (Bdate.Length == 8)
                {
                    CustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else CustBirthday.Text = Bdate;
            }
            else CustBirthday.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;

            //证件类型显示
            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                Papertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
            }
            else Papertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);
            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            bool IsOpenMonth = false;
            string openFuncStr = "本卡为";
            foreach (object list in openFunc.List)
            {
                if (list.ToString() == "学生月票")
                {
                    openFuncStr += "学生月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "老人月票")
                {
                    openFuncStr += "老人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "高龄卡")
                {
                    openFuncStr += "高龄卡、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "残疾人月票")
                {
                    openFuncStr += "残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港残疾人月票")
                {
                    openFuncStr += "张家港残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港老年人月票")
                {
                    openFuncStr += "张家港老年人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港公交员工卡")
                {
                    openFuncStr += "张家港公交员工卡、";
                    IsOpenMonth = true;
                }
            }

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }
            if (IsOpenMonth == true)
            {
                openFuncStr = openFuncStr.TrimEnd(new char[] { '、' });

                ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + openFuncStr + "');", true);
            }

            //查询是否有写卡失败记录
            DataTable dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_WriteCardFail", hiddentxtCardno.Value);
            if (dt != null && dt.Rows.Count > 0)
            {
                string lMoney = dt.Rows[0]["lMoney"].ToString();
                hidTotalPayFee.Value = lMoney;
                hidRollBackWay.Value = "0";//0.写卡失败返销
                hidQueryTradeId.Value = dt.Rows[0]["TRADEID"].ToString();
                txtTotalPayFee.Text = (Convert.ToDouble(lMoney)/100).ToString("0.00");
                context.AddMessage("将对缴费写卡进行返销，卡号：" + hiddentxtCardno.Value + "，返销金额：" + txtTotalPayFee.Text + " 元");
            }
        }
        else if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardno.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            //hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "writeCard();", true);
        }
        else if (hidWarning.Value == "yes")
        {
            btnSupply.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            //写卡成功，打印凭证
            context.AddMessage("前台写卡成功！");
            //打印凭证
            //自动打印凭证
            /*
            btnPrintPZ.Enabled = true;
            buildPingZhengContent();
            //如果是自动打印凭证，接着打印
            if (chkPingzheng.Checked)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "printWaterPingZheng1", "printInvoice();", true);
            }
            */
            context.AddMessage("写卡返销成功！");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "HYDROPOWER_CardWriteRollBackConfirm")
        {
            btnSupply.Enabled = false;
            context.SPOpen();
            context.AddField("p_TYPE").Value = "UPDATE";
            context.AddField("p_TRADEID").Value = hidQueryTradeId.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_TRADETYPECODE").Value = "";
            context.AddField("p_OPERCARDNO").Value = "";
            context.AddField("p_CARDNO").Value = "";
            context.AddField("p_LMONEY").Value = "0";
            context.AddField("p_LOLDMONEY").Value = "0";
            context.AddField("p_TERMNO").Value = "";
            bool isSpOk = context.ExecuteSP("SP_PB_AddCardTrade");
            if (isSpOk)
            {
                context.AddMessage("写卡执行存储过程成功！");
                context.AddMessage("写卡返销成功！");
                hidQueryTradeId.Value = "";
                hidRollBackWay.Value = "";
                //开始写卡 -- mark for bug 如果写卡失败，一般是卡没有扣成功，不写卡
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "chargeCardHYDROPOWER();", true);
            }
        }
        else if (hidWarning.Value == "HYDROPOWER_CardPayRollBackConfirm")//电子钱包返销，先存储过程，再写卡
        {
            Deduct(sender, e);
        }
        else if (hidWarning.Value == "HYDROPOWER_AccountPayRollBackConfirm")//专有账户返销，直接存储过程
        {
            Deduct(sender, e);
        }
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        supply_check();//提交前检查
        if (context.hasError())
        {
            return;
        }
        if (hidRollBackWay.Value == "0")//写卡失败返销
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "HYDROPOWER_CardWriteRollBack();", true);
        }
        if (hidRollBackWay.Value == "1")//电子钱包返销
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "HYDROPOWER_CardPayRollBack();", true);
        }
        else if (hidRollBackWay.Value == "2") //专有账户返销
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "HYDROPOWER_AccountPayRollBack();", true);
        }
    }

    private void Deduct(object sender, EventArgs e)
    {
        bool isSpOk = false;
        string currentTimeStr = DateTime.Now.ToString("yyyyMMddHHmmssfff");
        btnSupply.Enabled = false;
        if (hidRollBackWay.Value == "1")//电子钱包返销
        {
            //调用存储过程
            string p_ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);//18位;
            context.SPOpen();
            context.AddField("p_ID").Value = p_ID;
            context.AddField("p_TRADEID").Value = hidQueryTradeId.Value;
            context.AddField("p_TRADETYPECODE").Value = "X9";
            context.AddField("p_CARDNO").Value = hiddentxtCardno.Value;
            context.AddField("p_OPERCARDNO").Value = context.s_CardID;
            context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
            context.AddField("p_TERMNO").Value = "112233445566";
            context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
            context.AddField("p_CARDMONEY").Value = hiddencMoney.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_REAL_AMOUNT").Value = hidTotalPayFee.Value;
            context.AddField("p_TP_TRADE_ID").Value = hidTPTradeId.Value;
            isSpOk = context.ExecuteSP("SP_CS_HYDROPOWER_CARDRollBack");

            if (isSpOk)
            {
                context.AddMessage("电子钱包执行存储过程成功！");
                hidQueryTradeId.Value = "";
                hidRollBackWay.Value = "";
                //开始写卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "chargeCardHYDROPOWER();", true);
            }
        }
        else if (hidRollBackWay.Value == "2") //专有账户返销
        {
            //调用存储过程
            string p_ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);//18位;
            context.SPOpen();
            context.AddField("p_ID").Value = p_ID;
            context.AddField("p_TRADEID").Value = hidQueryTradeId.Value;
            context.AddField("p_TRADETYPECODE").Value = "X9";
            context.AddField("p_CARDNO").Value = hiddentxtCardno.Value;
            context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
            context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_REAL_AMOUNT").Value = hidTotalPayFee.Value;
            isSpOk = context.ExecuteSP("SP_CS_HYDROPOWER_ACCRollBack");

            if (isSpOk)
            {
                context.AddMessage("专有账户执行存储过程成功！");
                //自动打印凭证
                buildPingZhengContent();
                btnPrintPZ.Enabled = true;
                hidQueryTradeId.Value = "";
                hidRollBackWay.Value = "";
                //如果是自动打印凭证，接着打印
                if (chkPingzheng.Checked)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "printWaterPingZheng1", "printInvoice();", true);
                }
                context.AddMessage("返销成功！");
            }
        }
    }

    private void buildPingZhengContent()
    {
        HYDROPHelper.PreparePingZheng(hidQueryTradeId.Value, ptnPingZheng, context);
    }

    private void supply_check()
    {
        if (string.IsNullOrEmpty(hidQueryTradeId.Value))
        {
            context.AddError("请先查询出记录！");
            return;
        }
        if (string.IsNullOrEmpty(hiddentxtCardno.Value))
        {
            context.AddError("请先读卡！");
            return;
        }
        if (Convert.ToDouble(hidTotalPayFee.Value) <= 0)
        {
            context.AddError("返销金额不能小于或等于0！");
            return;
        }
        if (string.IsNullOrEmpty(hidRollBackWay.Value) || (hidRollBackWay.Value!="0" && hidRollBackWay.Value != "1" && hidRollBackWay.Value != "2"))
        {
            context.AddError("返销方式不正确！");
            return;
        }
    }

    private string GetSeq()
    {
        context.SPOpen();
        context.AddField("step").Value = 1;
        context.AddField("seq", "string", "Output", "16");
        context.ExecuteReader("SP_GetSeq");
        context.DBCommit();

        return "" + context.GetFieldValue("seq");
    }
}
