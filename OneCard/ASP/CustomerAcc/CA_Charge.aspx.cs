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
using System.Text;

/***************************************************************
 * 功能名: 专有账户_账户充值
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/22    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_Charge : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            setReadOnly(LabAsn, LabCardtype, cMoney, sDate, eDate);

            Money.Attributes["onfocus"] = "this.select();";
            Money.Attributes["onkeyup"] = "changemoney(this);";

            #region  初始化费用信息
            TMTableModule tmTMTableModule = new TMTableModule();

            //从前台业务交易费用表中读取数据
            TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
            ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "8Y";//账户充值

            TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), null, "TD_M_TRADEFEE", null);

            for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
            {
                if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                {//费用类型为充值
                    SupplyFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
                }
                else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                {//费用类型为其他费用
                    OtherFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
                }
            }
            Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

            #endregion
        }
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
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
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
        #endregion

        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardno, false);
        if (context.hasError())
        {
            return;
        }

        //清空卡内信息
        LabCardtype.Text = "";
        LabAsn.Text = "";
        sDate.Text = "";
        eDate.Text = "";
        cMoney.Text = "";

        //验证卡片有效性
        if (ValidateCardAcc() == false)
        {
            return;
        }

        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    /// <summary>
    /// 充值校验事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void submitConfirm_Click(object sender, EventArgs e)
    {
        //验证充值金额
        if (Money.Text.Trim() == "" || Convert.ToDecimal(Money.Text.Trim()) == 0)
            context.AddError("A001002126");
        else if (!Validation.isPosRealNum(Money.Text.Trim()))
            context.AddError("A001002127");

        if (context.hasError())
        {
            return;
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm();", true);
    }

    /// <summary>
    /// 充值按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCharge_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        string acctid = getDataKeys2("ACCT_ID");
        context.AddField("P_CARDNO").Value = this.HiddetxtCardno.Value;
        context.AddField("P_ACCID").Value = acctid;
        context.AddField("P_SUPPLYMONEY").Value = Convert.ToInt32((Convert.ToDecimal(Money.Text)) * 100).ToString();
        context.AddField("P_NEEDTRADEFEE").Value="1";
        context.AddField("P_TRADETYPECODE").Value = "8Y";
        context.AddField("p_TRADEID", "String", "output", "16").Value = "";
        bool ok = context.ExecuteSP("SP_CA_CHARGE");

        if (ok)
        {
            btnPrintPZ.Enabled = true;

            //ASHelper.preparePingZheng,待补充

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printdiv('ptnPingZheng1');", true);
            }

            this.btnChargeAcc.Enabled = false;

            this.txtCardno.Text = "";
            this.Money.Text = "";

            AddMessage("M001090120:充值成功");
        }

    }

    /// <summary>
    /// 加载卡户、用户、账户信息
    /// </summary>
    private void LoadDisplayInfo()
    {
        #region 卡户信息
        Dictionary<String,DDOBase> listDDO = new Dictionary<String,DDOBase>();
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
        
        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text);//修改成可以给所有类型的账户充值
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

            if (!CommonHelper.HasOperPower(context))
            {
                lblPaperno.Text = CommonHelper.GetPaperNo(lblPaperno.Text);
                lblCustphone.Text = CommonHelper.GetCustPhone(lblCustphone.Text);
                lblCustTelphone.Text = CommonHelper.GetCustPhone(lblCustTelphone.Text);
                lblCustaddr.Text = CommonHelper.GetCustAddress(lblCustaddr.Text);
            }

            lblEmail.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_EMAIL;
        }
        #endregion

        HiddetxtCardno.Value = txtCardno.Text;

        //this.btnChargeAcc.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
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
        string acctitemtype = getDataKeys2("ACCT_ITEM_TYPE"); //账目类别 0 现金账户 1 积分账户
        string cardno = getDataKeys2("ICCARD_NO"); //获取卡号
        string acctid = getDataKeys2("ACCT_ID");   //账户ID
        //if (acctitemtype == "1")
        //{
        //    context.AddError("A001090107:积分账户不允许充值");
        //    this.btnChargeAcc.Enabled = false;
        //}
        //else
        //{
            if (!CAHelper.GetCustAcctInfo(context, cardno, acctid, true, true))
            {
                return;
            }
            this.btnChargeAcc.Enabled = true;
        //}
    }

    public String getDataKeys2(String keysname)
    {
        return gvAccount.DataKeys[gvAccount.SelectedIndex][keysname].ToString();
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
}
