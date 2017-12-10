using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using TM;
using Common;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CustomerAcc;
using TDO.UserManager;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_圈存
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/24    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_FontCharge : FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            setReadOnly(LabAsn, LabCardtype, cMoney, sDate, eDate);

            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

        }
    }

    //清空卡户信息
    private void ClearCardInfo()
    {
        lblResState.Text = "";
        lblAsn.Text = "";
        lblCardtype.Text = "";
        lblSellDate.Text = "";
        lblEndDate.Text = "";
        openFunc.List = null;
    }

    //清空用户信息
    private void ClearUserInfo()
    {
        lblCustName.Text = "";
        lblCustBirthday.Text = "";
        lblPapertype.Text = "";
        lblPaperno.Text = "";
        lblCustsex.Text = "";
        lblCustphone.Text = "";
        lblCustTelphone.Text = "";
        lblCustpost.Text = "";
        lblEmail.Text = "";
        lblCustaddr.Text = "";
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {

        ClearUserInfo();
        ClearCardInfo();

        #region 账户信息
        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text, "0");
        UserCardHelper.resetData(gvAccount, data);
        string cust_id;
        if (data != null && data.Rows.Count > 0)
        {
            cust_id = data.Rows[0]["CUST_ID"].ToString(); //取出客户标识
        }
        else
        {
            context.AddError("A001090102:未查出客户账户信息");
            return;
        }

        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();

        #endregion

        //验证卡片有效性
        if (ValidateCardAcc() == false)
        {
            return;
        }

        #region 卡片信息（从卡片里读出的数据）
        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoCARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        LabCardtype.Text = ddoCARDTYPEOut.CARDTYPENAME;

        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
        #endregion

        #region 卡户信息
        if (!CAHelper.GetCardInfo(context, txtCardno.Text, out listDDO))
        {
            return;
        }
        else
        {
            DDOBase ddoTL_R_ICUSEROut;
            listDDO.TryGetValue("TL_R_ICUSER", out ddoTL_R_ICUSEROut);
            DDOBase ddoTD_M_RESOURCESTATEOut;
            listDDO.TryGetValue("TD_M_RESOURCESTATE", out ddoTD_M_RESOURCESTATEOut);
            DDOBase ddoTD_M_CARDTYPEOut;
            listDDO.TryGetValue("TD_M_CARDTYPE", out ddoTD_M_CARDTYPEOut);
            DDOBase ddoTF_F_CARDEWALLETACCOut;
            listDDO.TryGetValue("TF_F_CARDEWALLETACC", out ddoTF_F_CARDEWALLETACCOut);
            DDOBase ddoTF_F_CARDRECOut;
            listDDO.TryGetValue("TF_F_CARDREC", out ddoTF_F_CARDRECOut);
            #region lblResState库存状态
            if (ddoTD_M_RESOURCESTATEOut == null)
                lblResState.Text = ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut).RESSTATECODE;
            else
                lblResState.Text = ((TD_M_RESOURCESTATETDO)ddoTD_M_RESOURCESTATEOut).RESSTATE;
            #endregion
            this.lblCardtype.Text = ((TD_M_CARDTYPETDO)ddoTD_M_CARDTYPEOut).CARDTYPENAME;//卡类型
            this.lblAsn.Text = ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut).ASN;//asn
            //this.lblCardccMoney.Text = ((Convert.ToDecimal(((TF_F_CARDEWALLETACCTDO)ddoTF_F_CARDEWALLETACCOut).CARDACCMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            this.lblSellDate.Text = ((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).SELLTIME.ToString("yyyy-MM-dd");
            this.lblEndDate.Text = ASHelper.toDateWithHyphen(((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).VALIDENDDATE);
        }

        //查询卡片开通功能并显示
        PBHelper.openFunc(context, openFunc, txtCardno.Text);
        #endregion

        #region 用户信息
        listDDO = new Dictionary<String, DDOBase>();
        if (!CAHelper.GetCustInfo(context, txtCardno.Text, cust_id, out listDDO))
        {
            return;
        }
        else
        {
            DDOBase ddoTF_F_CUSTOut;
            listDDO.TryGetValue("TF_F_CUST", out ddoTF_F_CUSTOut);
            DDOBase ddoTD_M_PAPERTYPEOut;
            listDDO.TryGetValue("TD_M_PAPERTYPE", out ddoTD_M_PAPERTYPEOut);

            //证件类型显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE != "")
            {
                lblPapertype.Text = ((TD_M_PAPERTYPETDO)ddoTD_M_PAPERTYPEOut).PAPERTYPENAME;
            }
            else
            {
                lblPapertype.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE;
            }

            //性别显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_SEX == "0")
                lblCustsex.Text = "男";
            else if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_SEX == "1")
                lblCustsex.Text = "女";
            else lblCustsex.Text = "";

            //出生日期显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH != "")
            {
                String Bdate = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH;
                if (Bdate.Length == 8)
                {
                    lblCustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else
                {
                    lblCustBirthday.Text = Bdate;
                }
            }

            DeEncrypt(lblCustName, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_NAME);
            DeEncrypt(lblPaperno, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(lblCustaddr, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_ADDR);
            lblCustpost.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_POST;
            DeEncrypt(lblCustphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_PHONE);
            DeEncrypt(lblCustTelphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_TELPHONE);
            lblEmail.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_EMAIL;

            if (!CommonHelper.HasOperPower(context))
            {
                lblPaperno.Text = CommonHelper.GetPaperNo(lblPaperno.Text);
                lblCustphone.Text = CommonHelper.GetCustPhone(lblCustphone.Text);
                lblCustTelphone.Text = CommonHelper.GetCustPhone(lblCustTelphone.Text);
                lblCustaddr.Text = CommonHelper.GetCustAddress(lblCustaddr.Text);
            }
        }
        #endregion

        this.btnCharge.Enabled = true;
        this.btnPrintPZ.Enabled = false;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    /// <summary>
    /// 圈存按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCharge_Click(object sender, EventArgs e)
    {
        if (gvAccount.SelectedIndex < 0)
        {
            context.AddError("A001090403:请选择一个圈存账户");
            return;
        }
        //add by jiang 2017年11月21日 只允许一卡通专有账户圈存
        if (getDataKeys2("ACCT_TYPE_NO") != "0001")
        {
            context.AddError("A009956400:只允许一卡通专有账户圈存");
            return;
        }
        string relBalance = getDataKeys2("REL_BALANCE");
        //验证金额
        if (txtSupplyFee.Text.Trim() == "")
            context.AddError("A001002126");
        else if (!Validation.isPosRealNum(txtSupplyFee.Text.Trim()))
            context.AddError("A001002127");
        else if (Convert.ToDecimal(txtSupplyFee.Text.Trim()) == 0)
            context.AddError("A001002126");
        else if (Convert.ToDecimal(this.txtSupplyFee.Text) > Convert.ToDecimal(relBalance))
        {
            context.AddError("A001090402:圈存金额不能大于账户余额");
        }
        if (context.hasError())
        {
            return;
        }
        string accid = getDataKeys2("ACCT_ID");
        string cardno = getDataKeys2("ICCARD_NO");
        #region 验证密码
        if (this.PassWD.Text.Trim() == "")
        {
            context.AddError("A001090202:请输入账户密码");
            return;
        }
        //校验密码
        if (!CAHelper.CheckMultipleAccPWD(context, accid, PassWD.Text.Trim(), true))
        {
            return;
        }
        #endregion

        //从IC卡电子钱包账户表中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text;
        context.AddField("P_ACCID").Value = accid;
        context.AddField("P_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
        context.AddField("p_CARDMONEY", "Int32").Value = Convert.ToInt32(hiddencMoney.Value);
        context.AddField("p_CARDACCMONEY", "Int32").Value = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
        context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
        context.AddField("P_OPERCARDNO").Value = context.s_CardID;
        context.AddField("P_SUPPLYMONEY", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(txtSupplyFee.Text) * 100);
        hidSupplyMoney.Value = Convert.ToString(Convert.ToInt32(Convert.ToDecimal(txtSupplyFee.Text) * 100));


        bool ok = context.ExecuteSP("SP_CA_FONTCHARGE");

        if (ok)
        {
            hidCardReaderToken.Value = cardReader.createToken(context);

            ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript",
               "chargeCard();", true);


            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, lblCustName.Text, "专有账户圈存",
               (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100.0))).ToString("0.00")
               , "", "", lblPaperno.Text, (Convert.ToDecimal(Convert.ToInt32(hiddencMoney.Value) + Convert.ToInt32(hidSupplyMoney.Value)) / (Convert.ToDecimal(100.0))).ToString("0.00"),
               "", (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100.0))).ToString("0.00"), context.s_UserID, context.s_DepartName,
               lblPapertype.Text, "0.00", "0.00");

            btnPrintPZ.Enabled = true;
            this.btnCharge.Enabled = false;

        }
    }

    /// <summary>
    /// 写卡后调用
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnCharge.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            clearCustInfo(txtCardno);
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printdiv('ptnPingZheng1');", true);
        }
        hidWarning.Value = "";
    }

    protected void gvAccount_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvAccount','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvAccount_SelectedIndexChanged(object sender, EventArgs e)
    {
       
    }

    /// <summary>
    /// 验证卡片有效性
    /// </summary>
    /// <returns></returns>
    private bool ValidateCardAcc()
    {
        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        return ok;
    }

    public String getDataKeys2(String keysname)
    {
        return gvAccount.DataKeys[gvAccount.SelectedIndex][keysname].ToString();
    }

}
