using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using TDO.CustomerAcc;
using TDO.PersonalTrade;
using TM;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_转账
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/07/13    董翔			初次开发
 ****************************************************************/

public partial class ASP_CustomerAcc_CA_TransitBalanceRollback : Master.Master
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
            gvOutAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

            gvInAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

            ViewState["iacctid"] = new List<string>(); //记录转入卡账户ID
            ViewState["cardno"] = new List<string>(); //记录转入卡卡号

        }
    }


    /// <summary>
    /// 读转出卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        List<string> iacctids = (List<string>)ViewState["iacctid"];
        iacctids.Clear();
        List<string> icardnos = (List<string>)ViewState["cardno"];
        icardnos.Clear();

        //加载卡户、用户、账户信息
        LoadDisplayInfo(false, OtxtCardno, OlblRelBalance, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, null, null
            , null, null, null, null, OhidAccID, gvOutAccount);


        List<string> cardnos = (List<string>)ViewState["cardno"];
        if (cardnos.Count > 0)
        {
            ItxtCardno.Text = icardnos[0];
            //加载用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, IlblRelBalance, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, IlblAccState, IlblCreateDate
                , IlblUpperDay, IlblUpperOnce, IlblUpperType, IlblUpper, IhidAccID, gvInAccount);

        }
        else
        {
            gvInAccount.DataSource = new DataTable();
            gvInAccount.DataBind();
            gvInAccount.SelectedIndex = -1;
            context.AddError("A006001317:未找到账户互转信息");
        }
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        if (OhidAccID.Value == "")
        {
            context.AddError("A006001316:请先读转出卡");
            return;
        }
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, IlblRelBalance, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, IlblAccState, IlblCreateDate
                , IlblUpperDay, IlblUpperOnce, IlblUpperType, IlblUpper, IhidAccID, gvInAccount);
            if (IhidAccID.Value != "" && OhidAccID.Value != "")
                btnTransAcc.Enabled = true;
            LoadRollbackInfo();
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做转账操作");
        }
    }


    /// <summary>
    /// 转账返销按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (this.PassWD.Text.Trim() == "")
        {
            context.AddError("A001090202:请输入账户密码");
            return;
        }
        string oAcctID = getDataKeys2(gvOutAccount, "ACCT_ID");
        string iAcctID = getDataKeys2(gvInAccount, "ACCT_ID");
        #region 验证密码
        if (!CAHelper.CheckMultipleAccPWD(context, oAcctID, PassWD.Text.Trim(), true, true, true))
            return;
        #endregion

        if (!context.hasError() && hidTradeID.Value != "")
        {
            context.SPOpen();
            context.AddField("P_OACCT_ID").Value = oAcctID;
            context.AddField("P_IACCT_ID").Value = iAcctID;
            context.AddField("P_TRADE_ID").Value = hidTradeID.Value;
            context.AddField("P_TRANSITMONEY").Value = Convert.ToInt32((Convert.ToDecimal(labTranBalance.Text)) * 100).ToString();
            context.AddField("P_ID").Value = DealString.GetRecordID(OtxtCardno.Text.Substring(12, 4), OtxtCardno.Text);
            bool ok = context.ExecuteSP("SP_CA_TRANSITBALANCEROLLBACK");

            if (ok)
            {
                if (!context.hasError()) context.AddMessage("M001090116:转账返销成功");

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
        if (OhidAccID.Value == "")
        {
            context.AddError("A006001316:请先读转出卡");
            return;
        }
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, IlblRelBalance, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, IlblAccState, IlblCreateDate
                , IlblUpperDay, IlblUpperOnce, IlblUpperType, IlblUpper, IhidAccID, gvInAccount);
            if (IhidAccID.Value != "" && OhidAccID.Value != "")
                btnTransAcc.Enabled = true;
            LoadRollbackInfo();
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做转账操作");
        }
    }

    /// <summary>
    /// 加载用户、账户信息
    /// </summary>
    private void LoadRollbackInfo()
    {
        this.btnTransAcc.Enabled = false;
        TF_B_TRADE_ACCOUNTTDO trade;
        string oacctid = getDataKeys2(gvOutAccount, "ACCT_ID");
        string iacctid = getDataKeys2(gvInAccount, "ACCT_ID");
        if (oacctid != null && iacctid != null)
        {
            if (!CAHelper.GetRollbackInfo(context, oacctid, iacctid, "8T", "账户互转", out trade))
            {
                return;
            }
            else
            {
                hidTradeID.Value = trade.TRADEID;
                labTranBalance.Text = (((Decimal)trade.CURRENTMONEY) / (Convert.ToDecimal(-100))).ToString("0.00");
                labTranDate.Text = trade.OPERATETIME.ToShortDateString();
                labTranPer.Text = context.s_UserName;
                this.btnTransAcc.Enabled = true;
            }
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

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", ((TextBox)cardno).Text);
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
            ((Label)papertype).Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE;
            DeEncrypt(custpaperno,((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(custphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_TELPHONE);

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
        string acctype = gvOutAccount.DataKeys[gvOutAccount.SelectedIndex]["ACCT_TYPE_NO"].ToString();
        for (int i = 0; i < gvInAccount.Rows.Count; i++)
        {
            if (gvInAccount.DataKeys[i]["ACCT_TYPE_NO"].ToString() == acctype)
            {
                gvInAccount.SelectedIndex = i;
                break;
            }
        }
        LoadRollbackInfo();
    }

    protected void gvOutAccount_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        string oAcctID = gvOutAccount.DataKeys[e.Row.RowIndex]["ACCT_ID"].ToString(); //转出卡账户ID
        TMTableModule tmTMTableModule = new TMTableModule();
        string strTradeid = @"SELECT ACCTID,CARDNO FROM TF_B_TRADE_ACCOUNT
                              WHERE TRADEID IN (
                                               SELECT TRADEID
                                                 FROM (SELECT TRADEID
                                                          FROM TF_B_TRADE_ACCOUNT
                                                         WHERE ACCTID = '" + oAcctID + @"'
                                                           AND TRADETYPECODE = '8T'
                                                           AND CANCELTAG = '0' AND CURRENTMONEY < 0
                                                         ORDER BY OPERATETIME DESC)
                                                WHERE ROWNUM <= 1)
                               AND ACCTID != '" + oAcctID + @"'
                            ";
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        DataTable dt = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTradeid, 0);
        if (dt.Rows.Count == 1)
        {
            List<string> iacctids = (List<string>)ViewState["iacctid"];
            iacctids.Add(dt.Rows[0][0].ToString());
            List<string> icardnos = (List<string>)ViewState["cardno"];
            icardnos.Add(dt.Rows[0][1].ToString());
        }
        else
        {
            e.Row.Visible = false;
        }
    }

    protected void gvInAccount_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        string iAcctID = gvInAccount.DataKeys[e.Row.RowIndex]["ACCT_ID"].ToString();
        List<string> iacctids = (List<string>)ViewState["iacctid"];
        if (!iacctids.Contains(iAcctID))
        {
            e.Row.Visible = false;  //隐藏没有转账的账户信息
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
        string acctype = gvInAccount.DataKeys[gvInAccount.SelectedIndex]["ACCT_TYPE_NO"].ToString();
        for (int i = 0; i < gvOutAccount.Rows.Count; i++)
        {
            if (gvOutAccount.DataKeys[i]["ACCT_TYPE_NO"].ToString() == acctype)
            {
                gvOutAccount.SelectedIndex = i;
                break;
            }
        }
        LoadRollbackInfo();
    }

    public String getDataKeys2(GridView gv, String keysname)
    {
        if (gv.SelectedIndex < 0) return null;
        return gv.DataKeys[gv.SelectedIndex][keysname].ToString();
    }
}