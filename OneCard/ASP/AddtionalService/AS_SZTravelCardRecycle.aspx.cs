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
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using TDO.UserManager;
using TDO.ResourceManager;
using System.Collections.Generic;
using Master;
using System.Text;


/***************************************************************
 * 功能名: 附加业务_旅游卡-回收
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/09/23    liuhe			初次开发
 ****************************************************************/
public partial class ASP_AddtionalService_AS_SZTravelCardRecycle : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);
            setReadOnly(LabAsn, sDate, eDate, cMoney);

            TMTableModule tmTMTableModule = new TMTableModule();
            //从退换卡原因编码表(TD_M_REASONTYPE)中读取数据，放入下拉列表中
            TD_M_REASONTYPETDO tdoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
            TD_M_REASONTYPETDO[] tdoTD_M_REASONTYPEOutArr = (TD_M_REASONTYPETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), "S001007122");
            ControlDeal.SelectBoxFill(selReasonType.Items, tdoTD_M_REASONTYPEOutArr, "REASON", "REASONCODE", false);

            selPurPoseType.Items.Add(new ListItem("---请选择---", ""));
            selPurPoseType.Items.Add(new ListItem("1:对公", "1"));
            selPurPoseType.Items.Add(new ListItem("2:对私", "2"));
            selPurPoseType.SelectedValue = "2";

            initLoad(sender, e);
        }
    }


    /// <summary>
    /// 退卡类型改变时,读卡和读数据库按钮是否可用改变
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnReturnCard.Enabled = false;

        initLoad(sender, e);

        //退卡类型为可读卡时,读卡按钮可用,读数据库按钮不可用
        if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "13")
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);
            btnReadCard.Enabled = true;
            txtCardno.CssClass = "labeltext";
            btnDBRead.Enabled = false;
            divRFTitle.Visible = false;
            divRFInfo.Visible = false;
        }
        //退卡类型为不可读卡时,读卡按钮不可用,读数据库按钮可用
        else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            txtCardno.Attributes.Remove("readonly");
            btnReadCard.Enabled = false;
            btnDBRead.Enabled = true;
            txtCardno.CssClass = "input";
            divRFTitle.Visible = true;
            divRFInfo.Visible = true;
        }
    }

    /// <summary>
    /// 读卡
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnReturnCard.Enabled = false;
        if (txtCardno.Text.Substring(4, 4).ToString() != "5101")
        {
            context.AddError("A001001901：卡片不是旅游卡");
            return;
        }
        int cardnonum=Convert.ToInt32(txtCardno.Text.Trim().Substring(8, 8));
        //限制回收卡控制
        if (cardnonum>= 29000001 && cardnonum <= 29000150)
        {
            context.AddError("A001001902：这批漫游卡的押金已开票给苏州市旅游局,不能回收!");
            return;
        }
        //限制回收卡控制
        else if (cardnonum >= 29001059 && cardnonum <= 29001065)
        {
            context.AddError("A001001903：这批卡售卡业务办错,不能回收!");
            return;
        }
        else if (cardnonum == 29001054)
        {
            context.AddError("A001001903：这批卡售卡业务办错,不能回收!");
            return;
        }
        if (cardnonum >= 29000180 && cardnonum <= 29000185)
        {
            context.AddError("A001001904：这批卡不能回收!");
            return;
        }

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TMTableModule tmTMTableModule = new TMTableModule();

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }
            if (ddoTL_R_ICUSEROut.RESSTATECODE != "06")
            {
                context.AddError("A094570356:不是售出状态的卡不能回收");
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

            //页面显示项赋值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
            eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

            //从卡资料表(TF_F_CARDREC)中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            hidSERSTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            hidDEPOSIT.Value = (-Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            hidService.Value = (Convert.ToDecimal(ddoTF_F_CARDRECOut.SERVICEMONEY) / 100).ToString("0.00");
            txtDeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            //退卡类型为自然损坏卡时,计算退押金
            int a = ddoTF_F_CARDRECOut.DEPOSIT - ddoTF_F_CARDRECOut.SERVICEMONEY;

            if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "13")
            {
                if (a > 0)
                {
                    CancelDepositFee.Text = (Convert.ToDecimal(hidCancelDepositFee.Value) - Convert.ToDecimal(a) / 100).ToString("0.00");
                }
                else CancelDepositFee.Text = "0.00";
            }

            //从IC卡电子钱包退值表中读取数据

            TF_F_CARDEWALLETACC_BACKTDO ddoTF_F_CARDEWALLETACC_BACKIn = new TF_F_CARDEWALLETACC_BACKTDO();
            ddoTF_F_CARDEWALLETACC_BACKIn.CARDNO = txtCardno.Text;
            ddoTF_F_CARDEWALLETACC_BACKIn.USETAG = "0";

            TF_F_CARDEWALLETACC_BACKTDO ddoTF_F_CARDEWALLETACC_BACKOut = (TF_F_CARDEWALLETACC_BACKTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACC_BACKIn, typeof(TF_F_CARDEWALLETACC_BACKTDO), null, "TF_F_CARDEWALLETACC_BACK", null);
            //IC卡电子钱包退值表中没有记录时,计算退充值

            if (ddoTF_F_CARDEWALLETACC_BACKOut == null)
            {
                CancelSupplyFee.Text = (Convert.ToDecimal(hidCancelSupplyFee.Value) - Convert.ToDecimal(cMoney.Text)).ToString("0.00");
            }

            Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;

            //从系统参数表中读取数据

            TD_M_TAGTDO ddoTD_M_TAGIn = new TD_M_TAGTDO();
            ddoTD_M_TAGIn.TAGCODE = "MONEY_REMIND";
            TD_M_TAGTDO ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);
            //判断是否超过最大退充值金额



            if (-Convert.ToDecimal(CancelSupplyFee.Text) * 100 > Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE))
            {
                hidWarning.Value = "余额过大!<br><br>是否继续退卡?";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warnScript", "warnConfirm();", true);
            }

            btnReturnCard.Enabled = !context.hasError();

            btnPrintPZ.Enabled = false;

            //写卡参数圈提金额赋值

            hidUnSupplyMoney.Value = hiddencMoney.Value;
        }

    }


    /// <summary>
    /// 读数据库
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBRead_Click(object sender, EventArgs e)
    {
        btnReturnCard.Enabled = false;
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        if (txtCardno.Text.Substring(4, 4).ToString() != "5101")
        {
            context.AddError("A001001901：卡片不是旅游卡");
            return;
        }

        int cardnonum = Convert.ToInt32(txtCardno.Text.Trim().Substring(8, 8));
        //限制回收卡控制
        if (cardnonum >= 29000001 && cardnonum <= 29000150)
        {
            context.AddError("A001001902：这批漫游卡的押金已开票给苏州市旅游局,不能回收!");
            return;
        }
        //限制回收卡控制
        else if (cardnonum >= 29001059 && cardnonum <= 29001065)
        {
            context.AddError("A001001903：这批卡售卡业务办错,不能回收!");
            return;
        }
        else if (cardnonum == 29001054)
        {
            context.AddError("A001001903：这批卡售卡业务办错,不能回收!");
            return;
        }

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TMTableModule tmTMTableModule = new TMTableModule();
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }
            if (ddoTL_R_ICUSEROut.RESSTATECODE != "06")
            {
                context.AddError("A094570356:不是售出状态的卡不能回收");
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

            //从卡资料表(TF_F_CARDREC)中读取数据
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            hidDEPOSIT.Value = (-Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            hidService.Value = (Convert.ToDecimal(ddoTF_F_CARDRECOut.SERVICEMONEY) / 100).ToString("0.00");
            txtDeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");

            //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据
            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //给页面显示项赋值
            hidSERSTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            hiddenLabCardtype.Value = ddoTF_F_CARDRECOut.CARDTYPECODE;
            LabAsn.Text = ddoTF_F_CARDRECOut.ASN;
            sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
            eDate.Text = Vdate.Substring(0, 4) + "-" + Vdate.Substring(4, 2) + "-" + Vdate.Substring(6, 2);

            Decimal cardMoney = Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
            cMoney.Text = (cardMoney / 100).ToString("0.00");

            //退卡类型为不可读自然损坏卡时,计算退押金
            CancelDepositFee.Text = "0.00";
            Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;

            if (context.hasError())
            {
                return;
            }
            //从系统参数表中读取数据
            TD_M_TAGTDO ddoTD_M_TAGIn = new TD_M_TAGTDO();
            ddoTD_M_TAGIn.TAGCODE = "MONEY_REMIND";
            TD_M_TAGTDO ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);
            //判断是否超过退充值金额
            if (Convert.ToDecimal(cMoney.Text) * 100 > Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE))
            {
                hidWarning.Value = "余额过大!<br><br>是否继续退卡?";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warnScript", "warnConfirm();", true);
                btnReturnCard.Enabled = (hidWarning.Value.Length == 0);
            }
            btnReturnCard.Enabled = !context.hasError();

            btnPrintPZ.Enabled = false;
        }
    }

    /// <summary>
    /// 回收按钮提交
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReturnCard_Click(object sender, EventArgs e)
    {
        //判断卡号是否为空
        if (txtCardno.Text.Trim() == "")
        {
            context.AddError("A001008100", txtCardno);
            return;
        }

        if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            if (CheckRFInfo() == false)
                return;
        }

        //库内余额为负时,不能进行退卡
        if (Convert.ToDecimal(ReturnSupply.Text) > 0)
        {
            context.AddError("A001008115");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //读取审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;
        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        #region 存储过程调用
        string strId;
        string strCardTradeno;
        string strCheckStaffno;
        string strCheckDepartno;

        if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            strId = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
            strCardTradeno = LabAsn.Text.Substring(12, 4);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108"); return;
            }
            strCheckStaffno = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            strCheckDepartno = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        else
        {
            strId = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
            strCardTradeno = hiddentradeno.Value;
            strCheckStaffno = context.s_UserID;
            strCheckDepartno = context.s_DepartID;
        }
        StringBuilder strBuilder = new StringBuilder();

        context.SPOpen();
        context.AddField("p_ID").Value = strId;
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_ASN").Value = LabAsn.Text;
        context.AddField("p_CARDTRADENO").Value = strCardTradeno;
        context.AddField("p_STARTDATE").Value = sDate.Text.Replace("-", "");
        context.AddField("p_ENDDATE").Value = eDate.Text.Replace("-", "");
        context.AddField("p_REASONCODE").Value = selReasonType.SelectedValue;
        context.AddField("p_CARDMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        context.AddField("p_REFUNDMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(CancelSupplyFee.Text) * 100);
        context.AddField("p_REFUNDDEPOSIT", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(CancelDepositFee.Text) * 100);
        context.AddField("p_TRADEPROCFEE", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(ProcedureFee.Text) * 100);
        AESHelp.AESEncrypt(txtCusname.Text.Trim(), ref strBuilder);
        context.AddField("p_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("p_PAPERTYPECODE").Value = selPapertype.SelectedValue;
        AESHelp.AESEncrypt(txtCustpaperno.Text.Trim(), ref strBuilder);
        context.AddField("p_PAPERNO").Value = strBuilder.ToString();
        AESHelp.AESEncrypt(txtCustphone.Text.Trim(), ref strBuilder);
        context.AddField("p_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("p_BANKNAME").Value = txtBankname.Text.Trim();
        context.AddField("p_BANKNAMESUB").Value = txtBanknamesub.Text.Trim();
        context.AddField("p_BANKACCNO").Value = txtBankAccno.Text.Trim();
        context.AddField("p_PURPOSETYPE").Value = selPurPoseType.SelectedValue;
        context.AddField("p_REMARK").Value = txtRemark.Text.Trim();
        context.AddField("p_OPERCARDNO").Value = context.s_CardID;
        context.AddField("p_CHECKSTAFFNO").Value = context.s_UserID;
        context.AddField("p_CHECKDEPARTNO").Value = context.s_DepartID;
        context.AddField("p_TRADEID", "String", "output", "16", null);

        bool ok = context.ExecuteSP("SP_AS_SZTravelCardRecycle");
        #endregion

        if (ok)
        {
            hidoutTradeid.Value = "" + context.GetField("p_TRADEID").Value;
            string strAccmoney = "0.00";

            if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "13")
            {
                strAccmoney = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "unchargeCard();", true);
            }
            else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
            {
                AddMessage("回收成功,财务会在十五个工作日内将卡押金及卡内余额退回至购卡人指定银行卡!");
            }
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, "", "旅游卡回收", Total.Text
               , CancelDepositFee.Text, "", "", strAccmoney, hidService.Value,
               Total.Text, context.s_UserID, context.s_DepartName, "", ProcedureFee.Text, "0.00");

            initLoad(sender, e);
            btnReturnCard.Enabled = false;
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中
        ASHelper.initPaperTypeList(context, selPapertype);

        if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "13")
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //从前台业务交易费用表中读取数据
            TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
            ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "7K";

            TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

            for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
            {
                if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                    ProcedureFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            }
        }
        else
        {
            ProcedureFee.Text = "0.00";
        }
        hidCancelDepositFee.Value = "0.00";
        hidCancelSupplyFee.Value = "0.00";
        CancelDepositFee.Text = hidCancelDepositFee.Value;
        CancelSupplyFee.Text = hidCancelSupplyFee.Value;
        Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }


    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnReturnCard.Enabled = true;
            return;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.TRADEID = hidoutTradeid.Value;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok)
            {
                AddMessage("回收退卡成功");
                clearCustInfo(txtCardno);
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
                "printInvoice();", true);
        }
    }

    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验
        if (txtCardno.Text.Trim() == "")
            context.AddError("A001008100", txtCardno);
        else
        {
            if ((txtCardno.Text.Trim()).Length != 16)
                context.AddError("A001008101", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001008102", txtCardno);
        }

        return !(context.hasError());
    }

    /// <summary>
    /// 不可读时校验退款信息
    /// </summary>
    /// <returns></returns>
    private bool CheckRFInfo()
    {
        //对用户姓名进行非空、长度检验
        if (txtCusname.Text.Trim().Length == 0)
            context.AddError("A001001111", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("A001001113", txtCusname);

        if (txtCustphone.Text.Trim().Length == 0)
            context.AddError("A001019802:未输入联系电话", txtCustphone);

        if (txtBankname.Text.Trim().Length == 0)
            context.AddError("A001019801:未输入开户银行", txtBankname);

        //对银行账户做非空,长度,数字检验
        if (txtBankAccno.Text == "")
            context.AddError("A001016105", txtBankAccno);
        else if (Validation.strLen(txtBankAccno.Text) > 30)
            context.AddError("A001016106", txtBankAccno);
        else if (!Validation.isNum(txtBankAccno.Text))
            context.AddError("A001016107", txtBankAccno);

        //对收款人账户类型做非空校验
        if (selPurPoseType.SelectedValue == "")
            context.AddError("A008100020", selPurPoseType);

        return !(context.hasError());
    }
}
