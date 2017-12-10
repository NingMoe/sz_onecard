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
using System.Collections.Generic;
using Master;
using TM;
using Common;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CustomerAcc;
using TDO.PersonalTrade;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_抹帐
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/07/05    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_Recover : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack == false)
        {
            setReadOnly(LabAsn, LabCardtype, cMoney, sDate, eDate);

            beginDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            endDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

            //设置GridView绑定的DataTable
            lvwSupplyQuery.DataSource = new DataTable();
            lvwSupplyQuery.DataBind();
            lvwSupplyQuery.SelectedIndex = -1;

            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
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
        lvwSupplyQuery.DataSource = new DataTable();
        lvwSupplyQuery.DataBind();

        SupplyMoney.Text = "";
        StaffName.Text = "";
        SupplyDate.Text = "";
        reCoverMoney.Text = "";

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

        //验证卡片有效性        if (ValidateCardAcc() == false)
        {
            return;
        }

        lvwSupplyQuery.DataSource = new DataTable();
        lvwSupplyQuery.DataBind();

        SupplyMoney.Text = "";
        StaffName.Text = "";
        SupplyDate.Text = "";
        reCoverMoney.Text = "";

        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        
    }

    /// <summary>
    /// 设置回退列隐藏
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwSupplyQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[6].Visible = false;
        }
    }

    /// <summary>
    /// 抹帐按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRecover_Click(object sender, EventArgs e)
    {
        if (hidCANCELTAG.Value == "1")//判断是否做过返销，1已返销，0未返销
        {
            context.AddError("A001009113");
            return;
        }

        string relBalance = getDataKeys2("REL_BALANCE");

        //add by liuhe200110907,添加判断：如果抹账金额大于账户余额则不能抹账
        if (Convert.ToDecimal(reCoverMoney.Text) > Convert.ToDecimal(relBalance))
        {
            context.AddError("A001009182:抹账金额大于账户余额，不能抹账");
            return;
        }

        string acctid = getDataKeys2("ACCT_ID");

        TF_B_TRADE_ACCOUNTTDO trade;
        if (!CAHelper.GetRollbackInfo(context, acctid, "8Y", "充值", out trade))
        {
            return;
        }

        if (StaffName.Text != context.s_UserName)
        {
            context.AddError("A001009110");
            return;
        }

        if (trade.ID.Trim() != hiddenSupplyid.Value.Trim())
        {
            context.AddError("A006015101:所选交易不是最后一笔业务");
            return;
        }
        string cardno = getDataKeys2("ICCARD_NO");

        context.SPOpen();
        context.AddField("P_ACCTID").Value = acctid;
        context.AddField("P_CARDNO").Value = cardno;
        context.AddField("P_ID").Value = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
        context.AddField("P_SUPPLYID").Value = hiddenSupplyid.Value.Trim();
        context.AddField("P_CANCELMONEY").Value = Convert.ToInt32(Convert.ToDecimal(reCoverMoney.Text) * 100);
        context.AddField("P_PREMONEY").Value = Convert.ToInt32(Convert.ToDecimal(relBalance) * 100);

        bool ok = context.ExecuteSP("SP_CA_RECOVER");

        if (ok)
        {

            btnRecover.Enabled = false;

            this.txtCardno.Text = "";

            AddMessage("M001090910:抹帐成功");
        }
    }


    /// <summary>
    /// 加载卡户、用户、账户信息    /// </summary>
    private void LoadDisplayInfo()
    {
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
        //listDDO = new Dictionary<String, DDOBase>();
        //if (!CAHelper.GetCustAcctInfo(context, txtCardno.Text, true, out listDDO))
        //{
        //    return;
        //}
        //else
        //{
        //    DDOBase ddoTF_F_CUST_ACCTOut;
        //    listDDO.TryGetValue("TF_F_CUST_ACCT", out ddoTF_F_CUST_ACCTOut);
        //    DDOBase ddoTF_F_ACCT_BALANCEOut;
        //    listDDO.TryGetValue("TF_F_ACCT_BALANCE", out ddoTF_F_ACCT_BALANCEOut);
            //this.lblUpperOnce.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LIMIT_EACHTIME)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblUpperDay.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LIMIT_DAYAMOUNT)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblEffDate.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).EFF_DATE.ToString("yyyy-MM-dd");
            //this.lblAccState.Text = CAHelper.GetAccStateByCode(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).STATE);
            //this.lblCreateDate.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).CREATE_DATE.ToString("yyyy-MM-dd");
            //this.lblRelBalance.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).REL_BALANCE)) / (Convert.ToDecimal(100))).ToString("0.00"); ;

            //this.lblTotalConsume.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_MONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblTotalConsumeTimes.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_TIMES.ToString();
            //this.lblLastConsumeTime.Text = (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_TIMES == 0) ? "" : ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LAST_CONSUME_TIME.ToString("yyyy-MM-dd");

            //this.lblTotalSupply.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_MONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblTotalSupplyTimes.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_TIMES.ToString();
            //this.lblLastSupplyTime.Text = (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_TIMES == 0) ? "" : ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LAST_SUPPLY_TIME.ToString("yyyy-MM-dd");
        //    cust_id = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).CUST_ID;
        //}
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

        //this.btnQuery.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
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
        btnRecover.Enabled = false;

        //验证查询条件
        if (this.txtCardno.Text == "")
        {
            return;
        }

        if (gvAccount.SelectedIndex < 0)
        {
            context.AddError("A001009114：请选择一个账户");
            return;
        }

        string cardno = getDataKeys2("ICCARD_NO");
        string acctid = getDataKeys2("ACCT_ID");
        List<string> vars = new List<string>();
        vars.Add(cardno);
        vars.Add(acctid);

        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYRECOVER", vars.ToArray());
        lvwSupplyQuery.DataSource = data;
        lvwSupplyQuery.DataBind();

        if (data.Rows.Count > 0)
        {
            lvwSupplyQuery.SelectedIndex = 0;

            GridViewRow gv = lvwSupplyQuery.Rows[0];

            hiddenSupplyid.Value = gv.Cells[0].Text;
            SupplyMoney.Text = gv.Cells[2].Text;
            StaffName.Text = gv.Cells[5].Text;
            SupplyDate.Text = gv.Cells[4].Text;
            reCoverMoney.Text = gv.Cells[2].Text;

            hidCANCELTAG.Value = gv.Cells[6].Text;

            btnRecover.Enabled = true;
        }

    }

    public String getDataKeys2(String keysname)
    {
        return gvAccount.DataKeys[gvAccount.SelectedIndex][keysname].ToString();
    }


}
