using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Common;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BalanceChannel;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;
using System.Collections.Specialized;
using System.Xml;

public partial class ASP_PersonalBusiness_PB_ChangeCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // btnDBRead.Attributes["onclick"] = "warnCheck()";

            setReadOnly(OsDate, ODeposit, OldcMoney, LabCardtype, NsDate, NewcMoney, NDeposit);

            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this,'test', 'hidAccRecv');";
            if (!context.s_Debugging) setReadOnly(txtOCardno);
            if (!context.s_Debugging) txtNCardno.Attributes["readonly"] = "true";

            //初始化换卡类型

            ASHelper.setChangeReason(selReasonType, false);

            initLoad(sender, e);
            hidAccRecv.Value = Total.Text;
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "03";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001004139", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金

            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为卡费

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        //费用赋值

        DepositFee.Text = hiddenDepositFee.Value;
        CardcostFee.Text = hiddenCardcostFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        //卡费选项不可见,押金选中,读新卡按钮不可用,换卡按钮不可用

        //Cardcost.Visible = false;
        //Deposit.Checked = true;
        btnReadNCard.Enabled = false;
        Change.Enabled = false;
    }

    //换卡类型改变时,读卡和读数据库按钮是否可用改变

    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        //foreach (Control con in this.Page.Controls)
        //{
        //    ClearControl(con);
        //}

        initLoad(sender, e);
        //换卡类型为可读卡时,读数据库按钮不可用,读卡按钮可用
        if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "12")
        {
            if (!context.s_Debugging) setReadOnly(txtOCardno);
            btnReadCard.Enabled = true;
            btnDBRead.Enabled = false;
            txtOCardno.CssClass = "labeltext";
        }
        //换卡类型为不可读卡时,读卡不可用,读数据库可用
        else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            txtOCardno.Attributes.Remove("readonly");
            btnReadCard.Enabled = false;
            btnDBRead.Enabled = true;
            txtOCardno.CssClass = "input";
        }
    }

    //判断是否企服卡,是企服卡时显示卡费卡押金选项
    //protected void GroupJudge(object sender, EventArgs e)
    //{
    //    TMTableModule tmTMTableModule = new TMTableModule();

    //    //从企服卡可充值账户表中读取数据

    //    TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCIn = new TF_F_CARDOFFERACCTDO();
    //    ddoTF_F_CARDOFFERACCIn.CARDNO = txtOCardno.Text;
    //    ddoTF_F_CARDOFFERACCIn.USETAG = "1";

    //    TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCOut = (TF_F_CARDOFFERACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDOFFERACCIn, typeof(TF_F_CARDOFFERACCTDO), null);

    //    if (ddoTF_F_CARDOFFERACCOut != null)
    //        Cardcost.Visible = true;
    //}

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion 

        TMTableModule tmTMTableModule = new TMTableModule();

        //添加对市民卡的验证

        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtOCardno.Text;
        bool smkok = TMStorePModule.Excute(context, smkpdo);
        if (smkok == false)
        {
            return;
        }

        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面换卡

        //bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5101");
        //if (cardTypeOk == false)
        //{
        //    return;
        //}

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        //卡账户有效性检验
        // txtOCardno.Text = hiddentxtCardno.Value;
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            // 查询月票卡应用类型，区域名称，区域代码

            //DataTable data = ASHelper.callQuery(context, "CardAppInfo", txtOCardno.Text);
            //if (data.Rows.Count > 0)
            //{
            //    context.AddError("当前卡片为月票卡，不允许换卡！");
            //    return;
            //}

            //从IC卡资料表中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
            
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //获取旧卡售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value != "01" && hidOSaletype.Value != "02")
            {
                context.AddError("未找到正确的旧卡售卡方式");
                return;
            }
            if (hidOSaletype.Value.Equals("02"))
                labOSaleType.Text = "押金";
            else
                labOSaleType.Text = "卡费";

            //从资源状态编码表中读取数据

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            //txtOCardno.Text = hiddentxtCardno.Value;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00");
            OCardcost.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / (Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hidCardnoForCheck.Value = txtOCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            //GroupJudge(sender, e);
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "lockCard();", true);

            //btnReadNCard.Enabled = (hidWarning.Value.Length == 0);
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            //btnPrintSJ.Enabled = false;

            hidLockFlag.Value = "true";
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnReadNCard.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            if (hidLockFlag.Value == "true")
            {
                AddMessage("旧卡锁定成功");
                //add by youyue 2014-10-10 提示卡号是否有效换乘中奖信息
                string winnerInfo = TLHelper.queryWinnerInfo(context, txtOCardno.Text);
                if (winnerInfo != string.Empty)
                {
                    context.AddError(winnerInfo);
                }
            }
            else
            {
                if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
                {
                    AddMessage("换卡成功,请于" + DateTime.Today.AddDays(7).ToString("yyyy-MM-dd") + "后来办理转值业务!");
                }
                else
                {
                    AddMessage("前台写卡成功");
                }
                if (!string.IsNullOrEmpty(hidWriteCardFailInfo.Value))
                {
                    context.AddError("获取轨交次数失败,请更新控件后补写卡");
                }

                #region 换卡成功，张家港衍生卡信息同步

                if (hidOldCardIDZJG.Value.Length >= 6 && hidNewCardIDZJG.Value.Length >= 6 && hidOldCardIDZJG.Value.Substring(0, 6) == "215061" && hidNewCardIDZJG.Value.Substring(0, 6) == "215061")
                {
                    string tradeID = hidTradeIDZJG.Value;
                    string syncCardID = hidNewCardIDZJG.Value;
                    string[] parm = new string[2];
                    parm[0] = tradeID;
                    parm[1] = syncCardID;
                    DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardChangeInfoSync", parm);
                    CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO" }));
                    string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
                    switch (npaperType)
                    {
                        case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证

                        case "01": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证

                        case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证

                        case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                        case "06": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证

                        case "07": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿

                        case "08": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//武警证

                        case "09": syncData.Rows[0]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证

                        case "99": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//其它类型证件
                        default: break;
                    }
                    SyncRequest syncRequest;
                    bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
                    if (sync == true)
                    {
                        SyncRequest syncResponse;
                        string msg;
                        bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
                        if (!succ)
                        {
                            context.AddError("调用接口失败:" + msg);
                        }
                        else
                        {
                            context.AddMessage("调用接口成功!");
                        }
                    }
                    else
                    {
                        context.AddError("调用接口转换错误!");
                    }
                }
                #endregion
                #region add by liuhe  20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);

                DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                #endregion 

                clearCustInfo(txtOCardno, txtNCardno);
            }
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "submit")
        {
            btnDBRead_Click(sender, e);
        }

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printAll();", true);
        }
        else if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidLockFlag.Value = "";
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
        hidOldCardIDZJG.Value = "";
        hidTradeIDZJG.Value = "";
        hidNewCardIDZJG.Value = "";//add by hzl 20131205
    }

    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验

        if (txtOCardno.Text.Trim() == "")
            context.AddError("A001004113", txtOCardno);
        else
        {
            if ((txtOCardno.Text.Trim()).Length != 16)
                context.AddError("A001004114", txtOCardno);
            else if (!Validation.isNum(txtOCardno.Text.Trim()))
                context.AddError("A001004115", txtOCardno);
        }

        return !(context.hasError());
    }

    protected void btnDBRead_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        //对输入卡号进行检验

        if (!DBreadValidation())
            return;

        //添加对市民卡的验证

        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtOCardno.Text;
        bool smkok = TMStorePModule.Excute(context, smkpdo);
        if (smkok == false)
        {
            return;
        }

        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面换卡

        //bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5101");
        //if (cardTypeOk == false)
        //{
        //    return;
        //}

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡资料表中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从IC卡电子钱包账户表中读取数据

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //获取旧卡售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;
            if (hidOSaletype.Value != "01" && hidOSaletype.Value != "02")
            {
                context.AddError("未找到正确的旧卡售卡方式");
                return;
            }
            if (hidOSaletype.Value.Equals("02"))
                labOSaleType.Text = "押金";
            else
                labOSaleType.Text = "卡费";

            //从资源状态编码表中读取数据

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            hiddenAsn.Value = ddoTF_F_CARDRECOut.ASN;
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            OCardcost.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / (Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / 100).ToString("0.00");

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hiddentxtCardno.Value = txtOCardno.Text;
            //GroupJudge(sender, e);

            //读新卡按钮可用

            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            //btnPrintSJ.Enabled = false;

        }
        //add by youyue 2014-10-10 提示卡号是否有效换乘中奖信息
        string winnerInfo = TLHelper.queryWinnerInfo(context, txtOCardno.Text);
        if (winnerInfo != string.Empty)
        {
            context.AddError(winnerInfo);
        }

    }

    protected void btnReadNCard_Click(object sender, EventArgs e)
    {

        //添加对市民卡的验证

        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtNCardno.Text;
        bool smkok = TMStorePModule.Excute(context, smkpdo);
        if (smkok == false)
        {
            return;
        }

        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面换卡

        //bool cardTypeOk = CommonHelper.allowCardtype(context, txtNCardno.Text, "5101");
        //if (cardTypeOk == false)
        //{
        //    return;
        //}

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        // txtNCardno.Text = hiddentxtCardno.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //从用户卡库存表(TL_R_ICUSER)中读取数据

        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtNCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        //获取新卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value != "01" && hidSaletype.Value != "02")
        {
            context.AddError("未找到正确的新卡售卡方式");
            return;
        }


        //如果是旅游卡年卡,新卡和旧卡售卡方式要一致
        if ((txtNCardno.Text.Substring(4, 4) == "5101" && txtOCardno.Text.Substring(4, 4) != "5101") ||
           (txtNCardno.Text.Substring(4, 4) != "5101" && txtOCardno.Text.Substring(4, 4) == "5101"))
        {
            context.AddError("新卡和旧卡类型不一致");
            return;
        }

        if (txtNCardno.Text.Substring(4, 4) == "5101" && txtOCardno.Text.Substring(4, 4) == "5101")
        {
            //旧卡为押金方式，新卡为卡费方式
            if (hidOSaletype.Value.Equals("02") && hidSaletype.Value.Equals("01"))
            {
                context.AddError("旧卡售卡方式是押金,新卡售卡方式是卡费,请更换新卡");
                return;
            }

            //旧卡为卡费方式，新卡为押金方式
            if (hidOSaletype.Value.Equals("01") && hidSaletype.Value.Equals("02"))
            {
                context.AddError("旧卡售卡方式是卡费,新卡售卡方式是押金,请更换新卡");
                return;
            }
        }

        if (hidSaletype.Value.Equals("02"))
            labNSaleType.Text = "-->押金";
        else
            labNSaleType.Text = "-->卡费";

        //给页面显示项赋值

        hidCardprice.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
        txtNCardno.Text = txtNCardno.Text;

        if (hidSaletype.Value.Equals("01"))
        {
            //售卡方式为卡费

            NCardcost.Text = (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE) / 100).ToString("0.00");
            NDeposit.Text = "0.00";
        }
        else
        {
            //售卡方式为押金

            NCardcost.Text = "0.00";
            NDeposit.Text = (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE) / 100).ToString("0.00");
        }
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        NsDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
        NewcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / 100).ToString("0.00");

        FeeCount(sender, e);

        hidAccRecv.Value = Total.Text;
        txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            return;
        }

        //换卡按钮可用
        Change.Enabled = true;

        btnPrintPZ.Enabled = false;
        //btnPrintSJ.Enabled = false;
    }

    //根据换卡类型和选择押金类型确定费用
    protected void FeeCount(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_CALLINGSTAFFTDO ddoTD_M_CALLINGSTAFFIn = new TD_M_CALLINGSTAFFTDO();
        ddoTD_M_CALLINGSTAFFIn.OPERCARDNO = txtOCardno.Text;
        TD_M_CALLINGSTAFFTDO[] ddoTD_M_CALLINGSTAFFOut = (TD_M_CALLINGSTAFFTDO[])tmTMTableModule.selByPKArr(context,
            ddoTD_M_CALLINGSTAFFIn, typeof(TD_M_CALLINGSTAFFTDO), null, "TD_M_CALLINGSTAFF_BY_CARDNO", null);

        //老卡不是司机卡
        if (ddoTD_M_CALLINGSTAFFOut == null || ddoTD_M_CALLINGSTAFFOut.Length == 0)
        {
            //换卡类型为自然损坏卡时
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                decimal paymoney;
                //旧卡为押金方式，新卡为卡费方式

                if (hidOSaletype.Value.Equals("02") && hidSaletype.Value.Equals("01"))
                {
                    //应退金额
                    paymoney = Convert.ToDecimal(ODeposit.Text) - Convert.ToDecimal(OSERVICEMOENY.Value) / 100 - Convert.ToDecimal(hiddenCardcostFee.Value) - Convert.ToDecimal(hidCardprice.Value) / 100;
                    CardcostFee.Text = (paymoney > 0 ? -paymoney : 0).ToString("0.00");
                    DepositFee.Text = hiddenDepositFee.Value;

                    //判断是否开通了残疾人爱心卡
                    string sql = "select 1 from TF_F_CARDCOUNTACC where cardno = '" + txtOCardno.Text + "' and USETAG ='1' and APPTYPE = '04'";
                    context.DBOpen("Select");
                    DataTable data = context.ExecuteReader(sql);
                    if (data.Rows.Count > 0)
                    {
                        DepositFee.Text = "-30";
                        CardcostFee.Text = "0.00";
                    }
                }
                //旧卡为押金方式，新卡为押金方式

                if (hidOSaletype.Value.Equals("02") && hidSaletype.Value.Equals("02"))
                {
                    paymoney = Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100 - Convert.ToDecimal(ODeposit.Text);
                    DepositFee.Text = (paymoney > 0 ? paymoney : 0).ToString("0.00");
                    CardcostFee.Text = hiddenCardcostFee.Value;
                }
                //旧卡为卡费方式，新卡为卡费方式

                if (hidOSaletype.Value.Equals("01") && hidSaletype.Value.Equals("01"))
                {
                    paymoney = Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100 - Convert.ToDecimal(OCardcost.Text);
                    CardcostFee.Text = (paymoney > 0 ? paymoney : 0).ToString("0.00");
                    DepositFee.Text = hiddenDepositFee.Value;

                    //判断是否开通了残疾人爱心卡
                    string sql = "select 1 from TF_F_CARDCOUNTACC where cardno = '" + txtOCardno.Text + "' and USETAG ='1' and APPTYPE = '04'";
                    context.DBOpen("Select");
                    DataTable data = context.ExecuteReader(sql);
                    if (data.Rows.Count > 0)
                    {
                        DepositFee.Text = "0.00";
                        CardcostFee.Text = "0.00";
                    }
                }
                //旧卡为卡费方式，新卡为押金方式

                if (hidOSaletype.Value.Equals("01") && hidSaletype.Value.Equals("02"))
                {
                    context.AddError("旧卡售卡方式为卡费，不能换卡成押金方式");
                    return;
                }
            }
            //换卡类型为人为损坏卡时
            else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
            {
                //旧卡为押金方式，新卡为卡费方式

                if (hidOSaletype.Value.Equals("02") && hidSaletype.Value.Equals("01"))
                {
                    DepositFee.Text = hiddenDepositFee.Value;
                    CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");

                    //判断是否开通了残疾人爱心卡
                    string sql = "select 1 from TF_F_CARDCOUNTACC where cardno = '" + txtOCardno.Text + "' and USETAG ='1' and APPTYPE = '04'";
                    context.DBOpen("Select");
                    DataTable data = context.ExecuteReader(sql);
                    if (data.Rows.Count > 0)
                    {
                        DepositFee.Text = "0.00";
                        CardcostFee.Text = "0.00";
                    }
                }
                //旧卡为押金方式，新卡为押金方式

                if (hidOSaletype.Value.Equals("02") && hidSaletype.Value.Equals("02"))
                {
                    DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                    CardcostFee.Text = hiddenCardcostFee.Value;
                }
                //旧卡为卡费方式，新卡为卡费方式

                if (hidOSaletype.Value.Equals("01") && hidSaletype.Value.Equals("01"))
                {
                    DepositFee.Text = hiddenDepositFee.Value;
                    CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                }
                //旧卡为卡费方式，新卡为押金方式

                if (hidOSaletype.Value.Equals("01") && hidSaletype.Value.Equals("02"))
                {
                    context.AddError("旧卡售卡方式为卡费，不能换卡成押金方式");
                    return;
                }
            }
        }
        //老卡是司机卡
        else if (ddoTD_M_CALLINGSTAFFOut.Length > 0)
        {
            //换卡类型为自然损坏卡
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = hiddenCardcostFee.Value;
            }
            //换卡类型为人为损坏卡
            else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = (Convert.ToDecimal(hidOldCardcost.Value) / 100).ToString("0.00");
            }
        }

        //add by jiangbb 2013-11-14 旧卡类型为吴江B卡、换卡类型是自然损的卡押金和卡费都为0
        if (txtOCardno.Text.ToString().Substring(0, 6) == "215031" && (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15"))
        {
            DepositFee.Text = "0.00";
            CardcostFee.Text = "0.00";
        }

        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

    }

    //更改押金类型时更新费用信息

    //protected void Deposit_Changed(object sender, EventArgs e)
    //{
    //    string change;
    //    if (Deposit.Checked == true)
    //    {
    //        change = CardcostFee.Text;
    //        CardcostFee.Text = DepositFee.Text;
    //        DepositFee.Text = change;
    //    }
    //}

    ////更改卡费用类型时,改变费用
    //protected void Cardcost_Changed(object sender, EventArgs e)
    //{
    //    string change;
    //    if ( Cardcost.Checked == true)
    //    {
    //        change = DepositFee.Text;
    //        DepositFee.Text = CardcostFee.Text;
    //        CardcostFee.Text = change;
    //    }
    //}

    protected void Change_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        //判断售卡权限
        checkCardState(txtNCardno.Text);
        if (context.hasError()) return;

        if (txtRealRecv.Text == null)
        {
            context.AddError("A001001143");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }


        //读取审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        //获取轨交换乘次数
        string writeCardScript = null;//轨交需要记录在写卡记录表中
        int railTimes = 0;
        try
        {

            //礼金卡不需要执行该操作,针对新卡为市民卡结构
            if (hiddenLabCardtype.Value != "05")
            {
                //请求集合
                NameValueCollection values = new NameValueCollection();
                values.Add("id", "00215000" + txtOCardno.Text.Trim().Substring(8, 8));

                //发起请求
                PostSubmitter postSubmit = new PostSubmitter("http://172.10.0.110:8080/WebServiceSX.asmx/GetYKTCount", values);
                postSubmit.Type = Common.PostSubmitter.PostTypeEnum.Post;

                //获取返回信息
                string response = postSubmit.Post();
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(response);

                if (xmlDoc != null && !string.IsNullOrEmpty(xmlDoc.InnerText))
                {
                    string str = xmlDoc.InnerText.Substring(xmlDoc.InnerText.Length - 2, 2);
                    railTimes = Convert.ToInt32(str, 16);
                    //给写卡JS控件赋值
                    hiddenTradeNum.Value = xmlDoc.InnerText;

                    writeCardScript = "changeCardRail('" + DateTime.Now.ToString("yyyyMMdd") + "', " + xmlDoc.InnerText + ");";

                }

            }
        }
        catch (Exception ex)
        {

            context.AddError(ex.Message);
        }

     
        SP_PB_ChangeCard_COMMITPDO pdo = new SP_PB_ChangeCard_COMMITPDO();
        //存储过程赋值
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenASn.Value.Substring(16, 4);
        pdo.CUSTRECTYPECODE = CUSTRECTYPECODE.Value;
        //新卡为卡费方式

        if (hidSaletype.Value.Equals("01"))
        {
            //如果是卡费方式，卡费为卡价格
            pdo.CARDCOST = Convert.ToInt32(Convert.ToDecimal(hiddenCardcostFee.Value) * 100 + Convert.ToDecimal(hidCardprice.Value));
        }
        //新卡为押金方式

        if (hidSaletype.Value.Equals("02"))
        {
            //如果是押金方式，卡费为0
            pdo.CARDCOST = Convert.ToInt32(Convert.ToDecimal(hiddenCardcostFee.Value) * 100);
        }
        pdo.NEWCARDNO = txtNCardno.Text;
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.ONLINECARDTRADENO = hiddentradeno.Value;
        pdo.CHANGECODE = selReasonType.SelectedValue;
        pdo.ASN = hiddenAsn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.SELLCHANNELCODE = "01";
        pdo.TRADETYPECODE = "03";
        pdo.PREMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        //最近卡充值实际余额为本次交易前卡内余额
        pdo.SUPPLYREALMONEY = 0;
        pdo.WRITECARDSCRIPT = writeCardScript;

        //StringBuilder szOutput = new System.Text.StringBuilder(256);
        //CAEncryption.CAEncrypt("111111", ref szOutput);
        //pdo.PWD = szOutput.ToString();

        //换卡类型为可读自然损坏卡
        if (selReasonType.SelectedValue == "13")
        {
            //新卡为卡费方式

            if (hidSaletype.Value.Equals("01"))
            {
                //如果是卡费方式，押金为0
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100);
            }
            //新卡为押金方式

            if (hidSaletype.Value.Equals("02"))
            {
                //如果是押金方式，押金为卡价格
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100 + Convert.ToDecimal(hidCardprice.Value));
            }
            pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
            pdo.SERVICEMONE = Convert.ToInt32(OSERVICEMOENY.Value);
            //pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130723 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            //add by gl 20160627 可读卡换卡,新卡卡余额,库余额均为旧卡卡余额
            pdo.CARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text)*100);
            pdo.NEWSERSTAKETAG = SERTAKETAG.Value;
            //pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
            pdo.SERSTAKETAG = "3";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为可读人为损坏卡
        else if (selReasonType.SelectedValue == "12")
        {
            //新卡为卡费方式

            if (hidSaletype.Value.Equals("01"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100);
            }
            //新卡为押金方式

            if (hidSaletype.Value.Equals("02"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100);
            }
            pdo.SERSTARTTIME = DateTime.Now;
            pdo.SERVICEMONE = 0;
            //pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130723  Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            //add by gl 20160627 可读卡换卡,新卡卡余额,库余额均为旧卡卡余额
            pdo.CARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.NEWSERSTAKETAG = "0";
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            //pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730  Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = 0;
            pdo.SERSTAKETAG = "2";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为不可读人为损坏卡
         
        else if (selReasonType.SelectedValue == "14")
        {
            //新卡为卡费方式

            if (hidSaletype.Value.Equals("01"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100);
            }
            //新卡为押金方式

            if (hidSaletype.Value.Equals("02"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100);
            }
            pdo.SERSTARTTIME = DateTime.Now;
            pdo.SERVICEMONE = 0;
            pdo.CARDACCMONEY = 0;
            pdo.NEWSERSTAKETAG = "0";
            //pdo.SUPPLYREALMONEY = 0;
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = 0;
            pdo.SERSTAKETAG = "2";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        //换卡类型为不可读自然损坏卡

        else if (selReasonType.SelectedValue == "15")
        {
            //新卡为卡费方式

            if (hidSaletype.Value.Equals("01"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100);
            }
            //新卡为押金方式

            if (hidSaletype.Value.Equals("02"))
            {
                pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100 + Convert.ToDecimal(hidCardprice.Value));
            }
            pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
            pdo.SERVICEMONE = Convert.ToInt32(OSERVICEMOENY.Value);
            pdo.CARDACCMONEY = 0;
            pdo.NEWSERSTAKETAG = SERTAKETAG.Value;
            //pdo.SUPPLYREALMONEY = 0;
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
            pdo.SERSTAKETAG = "3";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtOCardno.Text;

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
        hidCustname.Value = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        hidPaperno.Value = ddoTF_F_CUSTOMERRECOut.PAPERNO;

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //证件类型赋值

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            hidPapertype.Value = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else hidPapertype.Value = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;


        hidSupplyMoney.Value = "" + pdo.CURRENTMONEY;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {

            //AddMessage("M001004001");
            hidCardnoForCheck.Value = txtNCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            if (!string.IsNullOrEmpty(hiddenTradeNum.Value))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "changeCardGj();", true);
                context.AddMessage(" 轨交次数" + railTimes + "次成功转移至新卡，有疑问可以向轨交咨询和修改次数");
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "changeCard();", true);
            }
            btnPrintPZ.Enabled = true;
            //btnPrintSJ.Enabled = true;

            //add by jiangbb 2012-05-14
            string deposit = string.Empty;
            if (hidSaletype.Value == "01")   //售卡方式为卡费    
            {
                //旧卡为吴江B卡 
                if (txtOCardno.Text.ToString().Substring(0, 6) == "215031" && (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15"))
                {
                    deposit = "0" + "(卡费)";
                }
                else
                {
                    deposit = (Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString() + "(卡费)";
                }
            }
            else
            {
                deposit = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString();
            }

            #region 原Coding 注释 update by jiangbb 2012-05-14 卡押金方式调整

            //ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "换卡", "0.00"
            //                , DepositFee.Text, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(pdo.NEXTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
            //                "", Total.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, ProcedureFee.Text, "0.00");
            #endregion

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "换卡", "0.00"
                , deposit, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(pdo.NEXTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", Total.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, ProcedureFee.Text, "0.00", railTimes.ToString());

            ASHelper.prepareShouJu(ptnShouJu, txtNCardno.Text, context.s_UserName, (Convert.ToDecimal(pdo.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00"));

            //foreach (Control con in this.Page.Controls)
            if (pdo.NEWCARDNO.Substring(0, 6) == "215061" && pdo.OLDCARDNO.Substring(0, 6) == "215061")
            {
                string tradeID = ((SP_PB_ChangeCard_COMMITPDO)pdoOut).TRADEID;
                hidTradeIDZJG.Value = tradeID;
                hidOldCardIDZJG.Value = pdo.OLDCARDNO.ToString();
                hidNewCardIDZJG.Value = pdo.NEWCARDNO.ToString();
            }
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            Change.Enabled = false;
        }
    }


}
