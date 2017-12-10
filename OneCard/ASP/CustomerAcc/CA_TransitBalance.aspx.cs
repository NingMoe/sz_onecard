using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CustomerAcc;
using System.Data;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_转账
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/07/12    董翔			初次开发
 * 2012/11       殷华荣         修改成多账户
 ****************************************************************/

public partial class ASP_CustomerAcc_CA_TransitBalance : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging)
            {
                setReadOnly(OtxtCardno);
                setReadOnly(ItxtCardno);
            }

            Money.Attributes["onfocus"] = "this.select();";
            Money.Attributes["onkeyup"] = "changeTransitmoney(this);";

            gvOutAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

            gvInAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

        }
    }


    /// <summary>
    /// 读转出卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //加载卡户、用户、账户信息
        LoadDisplayInfo(false, OtxtCardno, null, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, null, null
            , null, null, null, null, OhidAccID, gvOutAccount);

        gvOutAccount.SelectedIndex = -1;
        ViewState["oaccttype"] = null;
        btnTransAcc.Enabled = false;
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, null, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, null, null
               , null, null, null, null, IhidAccID, gvInAccount);

            if (IhidAccID.Value != "" && OhidAccID.Value != "")
                btnTransAcc.Enabled = true;

            gvInAccount.SelectedIndex = -1;
            ViewState["iaccttype"] = null;
            btnTransAcc.Enabled = false;
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做转账操作");
        }
    }

    /// <summary>
    /// 转账按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (ViewState["oaccttype"].ToString() != ViewState["iaccttype"].ToString())
        {
            context.AddError("A006001315:账户类型不同,不能互转");
            return;
        }

        //转出卡账户余额
        string oRelBalance = getDataKeys2(gvOutAccount, "REL_BALANCE");

        //验证充值金额
        if (!Validation.isNum(Money.Text.Trim()))
            context.AddError("A006001330:转账金额不为数字");
        else if (Money.Text.Trim() == "")
            context.AddError("A006001331:转账金额不能为空");
        else if (!Validation.isPosRealNum(Money.Text.Trim()))
            context.AddError("A006001332:转账金额不为数字");
        else if (Convert.ToDecimal(Money.Text.Trim()) == 0)
            context.AddError("A006001333:转账金额不能为0");
        else if (Convert.ToDecimal(Money.Text.Trim()) > Convert.ToDecimal(oRelBalance))
            context.AddError("A006001314:转账金额不能大于转出卡帐户余额");

        if (this.PassWD.Text.Trim() == "")
        {
            context.AddError("A001090202:请输入账户密码");
            return;
        }

        string oAcctID = getDataKeys2(gvOutAccount, "ACCT_ID");

        #region 验证密码
        if (!CAHelper.CheckMultipleAccPWD(context, oAcctID, PassWD.Text.Trim(), true, true, true))
            return;
        #endregion

        string iAcctID = getDataKeys2(gvInAccount, "ACCT_ID");

        if (!context.hasError())
        {
            context.SPOpen();
            context.AddField("P_OACCT_ID").Value = oAcctID;
            context.AddField("P_IACCT_ID").Value = iAcctID;
            context.AddField("P_TRANSITMONEY").Value = Convert.ToInt32((Convert.ToDecimal(Money.Text)) * 100).ToString();
            context.AddField("P_ID").Value = DealString.GetRecordID(OtxtCardno.Text.Substring(12, 4), OtxtCardno.Text);
            bool ok = context.ExecuteSP("SP_CA_TRANSITBALANCE");

            if (ok)
            {
                if (!context.hasError()) context.AddMessage("M001090115:转账成功");

                btnPrintPZ.Enabled = true;

                ////打印凭证
                //ASHelper.preparePingZheng(ptnPingZheng, this.lblCardno.Text, this.lblCustName.Text, strTradetypeName,
                //    "0.00", "", "", this.lblPaperno.Text, "", "0.00",
                //    "0.00", context.s_UserName, "", this.lblPapertype.Text, "0.00",
                //    "");
                if (chkPingzheng.Checked && btnPrintPZ.Enabled)
                {
                    ScriptManager.RegisterStartupScript(
                        this, this.GetType(), "writeCardScript",
                        "printdiv('ptnPingZheng1');", true);
                }
                this.btnTransAcc.Enabled = false;
            }
        }
    }



    /// <summary>
    /// 读转入卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard2_Click(object sender, EventArgs e)
    {
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, null, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, null, null
                , null, null, null, null, IhidAccID, gvInAccount);

            if (IhidAccID.Value != "" && OhidAccID.Value != "")
                btnTransAcc.Enabled = true;

            gvInAccount.SelectedIndex = -1;
            ViewState["iaccttype"] = null;
            btnTransAcc.Enabled = false;
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做转账操作");
        }
    }

    /// <summary>
    /// 加载用户、账户信息
    /// </summary>
    private void LoadDisplayInfo(bool CheckAccState, Control cardno, Control relBalance, Control cusname, Control custphone, Control papertype,
       Control custpaperno, Control accState, Control createDate, Control totalConsume, Control totalSupply, Control UpperType,
        Control upper, Control accid, GridView gv)
    {
        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", ((TextBox)cardno).Text, "0");
        UserCardHelper.resetData(gv, data);

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
        if (!CAHelper.GetCustInfo(context, ((TextBox)cardno).Text, cust_id, out listDDO))
        {
            return;
        }
        else
        {
            DDOBase ddoTF_F_CUSTOut;
            listDDO.TryGetValue("TF_F_CUST", out ddoTF_F_CUSTOut);
            DDOBase ddoTD_M_PAPERTYPEOut;
            listDDO.TryGetValue("TD_M_PAPERTYPE", out ddoTD_M_PAPERTYPEOut);

            DeEncrypt(cusname, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_NAME);
            //证件类型显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE != "")
            {
                ((Label)papertype).Text = ((TD_M_PAPERTYPETDO)ddoTD_M_PAPERTYPEOut).PAPERTYPENAME;
            }
            else
            {
                ((Label)papertype).Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE;
            }
            DeEncrypt(custpaperno, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(custphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_PHONE);

            if (!CommonHelper.HasOperPower(context))
            {
                ((Label)custpaperno).Text = CommonHelper.GetPaperNo(((Label)custpaperno).Text);
                ((Label)custphone).Text = CommonHelper.GetCustPhone(((Label)custphone).Text);
            }
        }
        #endregion
        //this.btnChargeAcc.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    protected void gvOutAccount_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOutAccount','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvOutAccount_SelectedIndexChanged(object sender, EventArgs e)
    {
        ViewState["oaccttype"] = getDataKeys2(gvOutAccount, "ACCT_TYPE_NO");
        if (ViewState["oaccttype"] != null && ViewState["iaccttype"] != null)
        {
            this.btnTransAcc.Enabled = true;
        }
    }

    protected void gvInAccount_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvInAccount','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvInAccount_SelectedIndexChanged(object sender, EventArgs e)
    {
        ViewState["iaccttype"] = getDataKeys2(gvInAccount, "ACCT_TYPE_NO");
        if (ViewState["oaccttype"] != null && ViewState["iaccttype"] != null)
        {
            this.btnTransAcc.Enabled = true;
        }
    }

    public String getDataKeys2(GridView gv, String keysname)
    {
        return gv.DataKeys[gv.SelectedIndex][keysname].ToString();
    }
}