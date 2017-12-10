using System;
using System.Web.UI;
using System.Data;
using System.Collections.Generic;
using TM;
using Common;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CustomerAcc;
using TDO.PersonalTrade;
using Master;
using System.Web.UI.WebControls;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_开户返销
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/30    董翔			初次开发
 ****************************************************************/

public partial class ASP_CustomerAcc_CA_OpenAccRollback : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);

            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
        }
    }

    /// <summary>
    /// 卡账户有效性检验
    /// 可提取静态方法到用户卡帮助类
    /// </summary>
    /// <param name="cradno">卡号</param>
    private bool CheckCardVaild(string cradno)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        return TMStorePModule.Excute(context, pdo);
    }

    /// <summary>
    //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
    /// </summary>
    private void ReadFromCard()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        if (!CheckCardVaild(txtCardno.Text))
        {
            return;
        }

        //卡片信息（从卡片里读出的数据）
        ReadFromCard();

        #region 卡户信息
        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
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

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text);
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

            this.hidPapertype.Value = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE;

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
            hidPaperno.Value = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO;

            if (!CommonHelper.HasOperPower(context))
            {
                lblPaperno.Text = CommonHelper.GetPaperNo(lblPaperno.Text);
                lblCustphone.Text = CommonHelper.GetCustPhone(lblCustphone.Text);
                lblCustTelphone.Text = CommonHelper.GetCustPhone(lblCustTelphone.Text);
                lblCustaddr.Text = CommonHelper.GetCustAddress(lblCustaddr.Text);
            }
        }
        #endregion

    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }


    /// <summary>
    /// 开户返销操作
    /// </summary>
    protected void btnOpenAccRollback_Click(object sender, EventArgs e)
    {
        if (CheckOpenAccRoolback())
        {
            context.SPOpen();
            string acctid = getDataKeys2("ACCT_ID");
            context.AddField("P_ACCTID").Value = acctid;
            context.AddField("P_CARDNO").Value = txtCardno.Text;
            context.AddField("P_TRADE_ID").Value = hidTradeID.Value;
            context.AddField("P_PAPERTYPECODE").Value = hidPapertype.Value;
            context.AddField("P_PAPERNO").Value = hidPaperno.Value;
            if (context.ExecuteSP("SP_CA_OPENACCROLLBACK"))
            {
                btnPrintPZ.Enabled = true;
                //ASHelper.preparePingZheng,待补充
                if (chkPingzheng.Checked && btnPrintPZ.Enabled)
                {
                    ScriptManager.RegisterStartupScript(
                        this, this.GetType(), "writeCardScript",
                        "printdiv('ptnPingZheng1');", true);
                }
                btnOpenAccRollback.Enabled = false;
                this.txtCardno.Text = "";

                AddMessage("M001090110:开户返销成功");
            }
        }
    }

    /// <summary>
    /// 检查是否是当前营业员最后一笔操作操作是否是开户操作    /// </summary>
    private bool CheckOpenAccRoolback()
    {
        this.btnOpenAccRollback.Enabled = false;
        TF_B_TRADE_ACCOUNTTDO trade;
        string acctid = getDataKeys2("ACCT_ID");
        if (!CAHelper.GetRollbackInfo(context, acctid, "8X", "开户", out trade))
        {
            return false;
        }
        else
        {
            hidTradeID.Value = trade.TRADEID;

            this.btnOpenAccRollback.Enabled = true;
        }
        return true;
    }

    /// <summary>
    /// 初始化账户信息
    /// </summary>
    /// <returns>账户是否存在</returns>
    private bool InitAccInfo()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //客户账户
        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
        ddoTF_F_CUST_ACCTIn.ICCARD_NO = txtCardno.Text;

        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);

        if (ddoTF_F_CUST_ACCTOut == null)
        {
            context.AddError("A001090102:未查出客户账户信息");
            return false;
        }

        //余额账本
        TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEIn = new TF_F_ACCT_BALANCETDO();
        ddoTF_F_ACCT_BALANCEIn.ICCARD_NO = txtCardno.Text;
        ddoTF_F_ACCT_BALANCEIn.ACCT_ID = ddoTF_F_CUST_ACCTOut.ACCT_ID;

        TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEOut = (TF_F_ACCT_BALANCETDO)tmTMTableModule.selByPK(context, ddoTF_F_ACCT_BALANCEIn, typeof(TF_F_ACCT_BALANCETDO), null, "TF_F_ACCT_BALANCE", null);

        if (ddoTF_F_ACCT_BALANCEOut == null)
        {
            context.AddError("A001090104:未查出余额账本信息");
            return false;
        }
      
        #region 用户信息

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTTDO ddoTF_F_CUSTIn = new TF_F_CUSTTDO();
        ddoTF_F_CUSTIn.CUST_ID = ddoTF_F_CUST_ACCTOut.CUST_ID;

        TF_F_CUSTTDO ddoTF_F_CUSTOut = (TF_F_CUSTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTIn, typeof(TF_F_CUSTTDO), null, "TF_F_CUST_BYID", null);

        if (ddoTF_F_CUSTOut == null)
        {
            context.AddError("A001107112");
            return false;
        }

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
        this.hidPapertype.Value = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;

        //证件类型显示
        if (ddoTF_F_CUSTOut.PAPER_TYPE_CODE != "")
        {
            lblPapertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else
        {
            lblPapertype.Text = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
        }


        //性别显示
        if (ddoTF_F_CUSTOut.CUST_SEX == "0")
            lblCustsex.Text = "男";
        else if (ddoTF_F_CUSTOut.CUST_SEX == "1")
            lblCustsex.Text = "女";
        else lblCustsex.Text = "";

        //出生日期显示
        if (ddoTF_F_CUSTOut.CUST_BIRTH != "")
        {
            String Bdate = ddoTF_F_CUSTOut.CUST_BIRTH;
            if (Bdate.Length == 8)
            {
                lblCustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
            }
            else
            {
                lblCustBirthday.Text = Bdate;
            }
        }
        DeEncrypt(lblCustName, ddoTF_F_CUSTOut.CUST_NAME);
        DeEncrypt(lblPaperno, ddoTF_F_CUSTOut.PAPER_NO);
        hidPaperno.Value = ddoTF_F_CUSTOut.PAPER_NO;
        DeEncrypt(lblCustaddr, ddoTF_F_CUSTOut.CUST_ADDR);
        lblCustpost.Text = ddoTF_F_CUSTOut.CUST_POST;
        DeEncrypt(lblCustphone, ddoTF_F_CUSTOut.CUST_PHONE);
        DeEncrypt(lblCustTelphone, ddoTF_F_CUSTOut.CUST_TELPHONE);
        lblEmail.Text = ddoTF_F_CUSTOut.CUST_EMAIL;
        #endregion

        return true;
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
        if (CheckOpenAccRoolback())//同时加载账户信息和用户信息
        {
            this.btnOpenAccRollback.Enabled = true;
        }
    }

    public String getDataKeys2(String keysname)
    {
        return gvAccount.DataKeys[gvAccount.SelectedIndex][keysname].ToString();
    }

}
