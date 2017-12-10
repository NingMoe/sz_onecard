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

/**********************************
 * 世乒旅游卡换卡
 * 2015-3-30
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_SPTravelCardChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(OsDate,  LabCardtype, NsDate);

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
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "E1";

        //TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        //for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        //{
        //    //"10"为卡费
        //    if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
        //        hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        //}
        //费用赋值

        hiddenCardcostFee.Value = "0.00";
        CardcostFee.Text = "0.00";
        FunctionFee.Text = "0.00";

        decimal total = Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(FunctionFee.Text);
        Total.Text = total.ToString("0.00");

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
       
        btnReadNCard.Enabled = false;
        Change.Enabled = false;
    }

    //换卡类型改变时,读卡和读数据库按钮是否可用改变
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
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

        //验证卡片是否世乒旅游卡，如果不是，则不允许在该页面换卡

        if (txtOCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("非世乒旅游卡不能在此页面换卡");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

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

            //从用户卡库存表(TL_R_ICUSER)中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //获取旧卡售卡方式  世乒卡售卡中限制了只能卡费售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value != "01" && hidOSaletype.Value != "02")
            {
                context.AddError("未找到正确的旧卡售卡方式");
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

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            OCardcost.Text=(Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST)/(Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");

            //从套餐表里面读套餐的功能费
            DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtOCardno.Text);
            if (dt.Rows.Count == 0)
            {
                context.AddError("旧卡没有开通世乒旅游卡不能在此页面换卡");
                ScriptManager2.SetFocus(btnReadCard);
                return;
            }
            if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
            {
                txtOpenLine.Text = "东线A";
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
            {
                txtOpenLine.Text = "西线B";
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
            {
                txtOpenLine.Text = "东线A和西线B";
            }
            txtOldFunFee.Text = (Convert.ToDecimal(dt.Rows[0]["PACKAGEFEE"].ToString()) / 100).ToString("0.00");//功能费

            //读旧卡标志

            hidCardnoForCheck.Value = txtOCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            hidCardReaderToken.Value = cardReader.createToken(context); 
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "lockCard();", true);

            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;

            hidLockFlag.Value = "true";
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "changeShiPingCard();", true);
        }
        if (hidWarning.Value == "yes")
        {
            btnReadNCard.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            if (hidLockFlag.Value == "true")
            {
                AddMessage("旧卡锁定成功");
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

                #region add by liuhe  20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                //int opMoney = Convert.ToInt32(Convert.ToDecimal(FunctionFee.Text) * 100)
                //    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);
                int opMoney = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);//换卡没有功能费
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

        //验证卡片是否世乒旅游卡，如果是不是，则不允许在该页面换卡

        if (txtOCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("非世乒旅游卡不能在此页面换卡");
            ScriptManager2.SetFocus(btnReadCard);
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
            //获取旧卡售卡方式  世乒卡售卡中限制了只能卡费售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value != "01" && hidOSaletype.Value != "02")
            {
                context.AddError("未找到正确的旧卡售卡方式");
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

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            hiddenAsn.Value = ddoTF_F_CARDRECOut.ASN;
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;

            OCardcost.Text=(Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST)/(Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / 100).ToString("0.00");

            //读旧卡景点标志
            //从最近的一条记录中读,没有写默认值
            DataTable data = ASHelper.callQuery(context, "SPTravelTradesRight", txtOCardno.Text);
            if (data.Rows.Count > 0)
            {
                hiddenShiPingTag.Value = data.Rows[0]["TRAVELSIGN"].ToString();
            }
            else
            {
                hiddenShiPingTag.Value = "";
            }

            //从套餐表里面读套餐的功能费
            DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtOCardno.Text);
            if (dt.Rows.Count == 0)
            {
                context.AddError("旧卡没有开通世乒旅游卡不能在此页面换卡");
                ScriptManager2.SetFocus(btnReadCard);
                return;
            }
            if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
            {
                txtOpenLine.Text = "东线A";
                if (hiddenShiPingTag.Value == "")
                {
                    hiddenShiPingTag.Value = "15053101010101FFFFFF";
                }
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
            {
                txtOpenLine.Text = "西线B";
                if (hiddenShiPingTag.Value == "")
                {
                    hiddenShiPingTag.Value = "150531FFFFFFFF010101";
                }
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
            {
                txtOpenLine.Text = "东线A和西线B";
                if (hiddenShiPingTag.Value == "")
                {
                    hiddenShiPingTag.Value = "15053101010101010101";
                }
            }
            txtOldFunFee.Text = (Convert.ToDecimal(dt.Rows[0]["PACKAGEFEE"].ToString()) / 100).ToString("0.00");//功能费

            hiddentxtCardno.Value = txtOCardno.Text;

            //读新卡按钮可用
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
       
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

        //验证卡片是否世乒旅游卡，如果不是，则不允许在该页面换卡

        if (txtNCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("非世乒旅游卡不能在此页面换卡");
            ScriptManager2.SetFocus(btnReadCard);
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
        if (hidSaletype.Value != "01")
        {
            context.AddError("世乒卡为卡费售卡,新卡不是正确的售卡方式");
        }

        //从套餐表里面读套餐的功能费
        DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtNCardno.Text);
        if (dt.Rows.Count > 0)
        {
            context.AddError("新卡已经开通过世乒卡业务,不能换卡");
            ScriptManager2.SetFocus(btnReadNCard);
            return;
        }
        txtNewFunFee.Text = txtOldFunFee.Text;//新卡功能费和旧卡一样

        //给页面显示项赋值
        hidCardprice.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
        txtNCardno.Text = txtNCardno.Text;


        NCardcost.Text = (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE) / 100).ToString("0.00");

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

    //根据换卡类型决定有没有卡费
    protected void FeeCount(object sender, EventArgs e)
    {
        //该类型卡只有卡费售卡方式

        //换卡类型为自然损坏卡时
        if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
        {
            decimal paymoney;
            paymoney = Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100 - Convert.ToDecimal(OCardcost.Text);
            CardcostFee.Text = (paymoney > 0 ? paymoney : 0).ToString("0.00");
        }
            //换卡类型为人为损坏卡时
        else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
        {
            CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
        }
        Total.Text =Convert.ToDecimal(CardcostFee.Text).ToString("0.00");

    }

   

    protected void Change_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);
                   
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
        //新卡标志为旧卡标志
        //hidSPTravelLine.Value = hidOSPTravelLine.Value;

        //读取审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);


        //存储过程赋值
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_CUSTRECTYPECODE").Value = CUSTRECTYPECODE.Value; //记名非记名

        context.AddField("p_CARDCOST").Value = Convert.ToInt32(Convert.ToDecimal(hiddenCardcostFee.Value) * 100 + Convert.ToDecimal(hidCardprice.Value));

        context.AddField("p_NEWCARDNO").Value = txtNCardno.Text;
        context.AddField("p_OLDCARDNO").Value = txtOCardno.Text;
        
        context.AddField("p_ONLINECARDTRADENO").Value = hiddentradeno.Value; //最近联机交易序号
        context.AddField("p_CHANGECODE").Value = selReasonType.SelectedValue; //换卡原因
        context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
        context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
        context.AddField("p_SELLCHANNELCODE").Value = "01";//售卡渠道
        context.AddField("p_TRADETYPECODE").Value ="E3";
        context.AddField("p_PREMONEY").Value = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
        context.AddField("p_TERMNO").Value = "112233445566";
        context.AddField("p_OPERCARDNO").Value = context.s_CardID;


        //换卡类型为可读自然损坏卡
        if (selReasonType.SelectedValue == "13")
        {
            context.AddField("p_DEPOSIT", "Int32").Value = 0; //押金
            context.AddField("p_SERSTARTTIME", "DateTime").Value = Convert.ToDateTime(SERSTARTIME.Value);//服务开始时间
            context.AddField("p_SERVICEMONE", "Int32").Value = Convert.ToInt32(OSERVICEMOENY.Value);//实收卡服务费
            context.AddField("p_CARDACCMONEY", "Int32").Value = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY; //账户余额
            context.AddField("p_NEWSERSTAKETAG").Value = SERTAKETAG.Value; //服务费收取标志
            context.AddField("p_SUPPLYREALMONEY", "Int32").Value = 0; //充值金额
            context.AddField("p_TOTALSUPPLYMONEY", "Int32").Value = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            context.AddField("p_OLDDEPOSIT", "Int32").Value = 0;
            context.AddField("p_SERSTAKETAG").Value = "3";
            context.AddField("p_NEXTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            context.AddField("p_CURRENTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            context.AddField("p_CHECKSTAFFNO").Value = context.s_UserID;
            context.AddField("p_CHECKDEPARTNO").Value =context.s_DepartID;
            hidSupplyMoney.Value = (Convert.ToDecimal(OldcMoney.Text) * 100).ToString();
        }
        //换卡类型为可读人为损坏卡
        else if (selReasonType.SelectedValue == "12")
        {
            context.AddField("p_DEPOSIT").Value = 0;
            context.AddField("p_SERSTARTTIME", "DateTime").Value = DateTime.Now;
            context.AddField("p_SERVICEMONE").Value = 0;
            context.AddField("p_CARDACCMONEY").Value = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            context.AddField("p_NEWSERSTAKETAG").Value = "0";
            context.AddField("p_SUPPLYREALMONEY").Value = 0;
            context.AddField("p_TOTALSUPPLYMONEY").Value = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            context.AddField("p_OLDDEPOSIT").Value = 0;
            context.AddField("p_SERSTAKETAG").Value = "2";
            context.AddField("p_NEXTMONEY").Value = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            context.AddField("p_CURRENTMONEY").Value = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            context.AddField("p_CHECKSTAFFNO").Value = context.s_UserID;
            context.AddField("p_CHECKDEPARTNO").Value = context.s_DepartID;
            hidSupplyMoney.Value = (Convert.ToDecimal(OldcMoney.Text) * 100).ToString();
            
        }
        //换卡类型为不可读人为损坏卡

        else if (selReasonType.SelectedValue == "14")
        {
            context.AddField("p_DEPOSIT", "Int32").Value = 0;
            context.AddField("p_SERSTARTTIME", "DateTime").Value = DateTime.Now;
            context.AddField("p_SERVICEMONE", "Int32").Value = 0;
            context.AddField("p_CARDACCMONEY", "Int32").Value = 0;
            context.AddField("p_NEWSERSTAKETAG").Value = "0";
            context.AddField("p_SUPPLYREALMONEY", "Int32").Value = 0;
            context.AddField("p_TOTALSUPPLYMONEY", "Int32").Value = 0;
            context.AddField("p_OLDDEPOSIT", "Int32").Value = 0;
            context.AddField("p_SERSTAKETAG").Value = "2";
            context.AddField("p_NEXTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            context.AddField("p_CURRENTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            context.AddField("p_CHECKSTAFFNO").Value = context.s_UserID;
            context.AddField("p_CHECKDEPARTNO").Value = context.s_DepartID;

            hidSupplyMoney.Value = (Convert.ToDecimal(NewcMoney.Text) * 100).ToString();
        }
        //换卡类型为不可读自然损坏卡

        else if (selReasonType.SelectedValue == "15")
        {
            context.AddField("p_DEPOSIT", "Int32").Value = 0;
            context.AddField("p_SERSTARTTIME", "DateTime").Value = Convert.ToDateTime(SERSTARTIME.Value);
            context.AddField("p_SERVICEMONE", "Int32").Value = Convert.ToInt32(OSERVICEMOENY.Value);
            context.AddField("p_CARDACCMONEY", "Int32").Value = 0;
            context.AddField("p_NEWSERSTAKETAG").Value = SERTAKETAG.Value;
            context.AddField("p_SUPPLYREALMONEY", "Int32").Value = 0;
            context.AddField("p_TOTALSUPPLYMONEY", "Int32").Value = 0;
            context.AddField("p_OLDDEPOSIT", "Int32").Value = 0;
            context.AddField("p_SERSTAKETAG").Value = "3";
            context.AddField("p_NEXTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            context.AddField("p_CURRENTMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            context.AddField("p_CHECKSTAFFNO").Value = context.s_UserID;
            context.AddField("p_CHECKDEPARTNO").Value = context.s_DepartID;
            hidSupplyMoney.Value = (Convert.ToDecimal(NewcMoney.Text) * 100).ToString();
        }
        context.AddField("p_CURRENTTIME", "DateTime", "Output", "");
        context.AddField("p_TRADEID", "String", "Output", "16");
        context.AddField("p_TRADEID2", "String", "Output", "16");
        string writeCardScript = "SPTRAVELChangeCard('" + DateTime.Now.ToString("yyyyMMdd")
             + "', " + hiddenShiPingTag.Value
             + ");";
        context.AddField("p_WRITECARDSCRIPT").Value = writeCardScript;

        bool ok = context.ExecuteSP("SP_AS_SPTRAVELCHANGECARD");

        if (ok)
        {
            hidCardnoForCheck.Value = txtNCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

           
          
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "changeShiPingCard();", true);
            btnPrintPZ.Enabled = true;

            string deposit = string.Empty;

            deposit = (Convert.ToDecimal(hiddenCardcostFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString() + "(卡费)";



            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "世乒赛-换卡", "0.00"
                , "", txtNCardno.Text, hidPaperno.Value, (Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", Total.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, CardcostFee.Text, "0.00");

            ASHelper.prepareShouJu(ptnShouJu, txtNCardno.Text, context.s_UserName, "0");

          
            initLoad(sender, e);
            Change.Enabled = false;
        }
    }

    
}
