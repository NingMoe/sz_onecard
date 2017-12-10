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
using TDO.CardManager;
using TM;
using Common;
using TDO.BusinessCode;
using PDO.PersonalBusiness;
using TDO.CustomerAcc;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_（后台）密码重置 
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/08/11    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_ResetPasswordBg : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "false";

            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
            // 初始化集团客户
            GroupCardHelper.initGroupCustomer(context, selCorp);
        }
    }

    //清空用户信息
    private void ClearUseInfo()
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

    //清空账户信息
    private void ClearAccountInfo()
    {
        gvAccount.DataSource = new DataTable();
        gvAccount.DataBind();
    }

    private void ClearGvResult()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearAccountInfo();
        ClearUseInfo();
        ClearGvResult();

        //验证查询条件
        if (this.CheckQueryControl() == false)
        {
            return;
        }
        createGridViewDataSource();

        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }
        btnSubmit.Enabled = false;
    }

    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isNameEmpty = Validation.isEmpty(this.txtName);
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperno);
        bool isCardNoEmpty = Validation.isEmpty(this.txtInputCardNo);
        bool isCorpEmpty = (selCorp.SelectedValue.Trim().Length == 0);

        if (isPapernoEmpty && isNameEmpty && isCardNoEmpty && isCorpEmpty)
        {
            context.AddError("A900010B91: 查询条件不可为空");
            return false;
        }

        if (isPapernoEmpty == false && Validation.isCharNum(txtPaperno.Text.Trim()) == false)
        {
            context.AddError("A900010B92: 证件号必须是半角英文或数字", txtPaperno);
            return false;
        }

        if (isPapernoEmpty == false && Validation.strLen(txtPaperno.Text.Trim()) > 20)
        {
            context.AddError("A001001123", txtPaperno);
            return false;
        }

        return true;
    }

    private void createGridViewDataSource()
    {
        List<string> vars = new List<string>();

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperno.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());
        vars.Add(this.txtInputCardNo.Text.Trim());
        StringBuilder strBuilder1 = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder1);
        vars.Add(strBuilder1.ToString());
        vars.Add(selCorp.SelectedValue.Trim());
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYACCTCUSTOMERINFO", vars.ToArray());

        if (data.Rows.Count == 0)
        {
            context.AddError("A001090203:没有查询出对应信息");
            //btnConfirm.Enabled = false;
            return;
        }

        gvResult.DataSource = data;
        gvResult.DataBind();

        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 选择数据行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAccountInfo();
        ClearUseInfo();
        txtCardno.Text = gvResult.Rows[gvResult.SelectedIndex].Cells[0].Text.Trim();
        btnReadCard_Click(sender, e);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[1].Text = DeEncrypt(e.Row.Cells[1].Text);
            e.Row.Cells[3].Text = DeEncrypt(e.Row.Cells[3].Text);
            if (!CommonHelper.HasOperPower(context))
            {
                e.Row.Cells[3].Text = CommonHelper.GetPaperNo(e.Row.Cells[3].Text);
            }
        }
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource();
    }

    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    protected void gv_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ClearUseInfo();
        ClearAccountInfo();

        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardno, false);
        if (context.hasError())
        {
            return;
        }

        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text);
        UserCardHelper.resetData(gvAccount, data);

        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
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
        //if (!CAHelper.GetCustAcctInfo(context, txtCardno.Text, false, out listDDO))
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

        //    if (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).STATE.Equals("A") == false
        //       || ((TF_F_ACCT_BALANCETDO)ddoTF_F_ACCT_BALANCEOut).STATE.Equals("A") == false)
        //    {
        //        context.AddMessage("A001090103:客户账户或余额账本状态无效，重置密码前请认真核对用户信息");
        //    }

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

        this.btnSubmit.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    /// <summary>
    /// 密码重置按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        if (txtCardno.Text == "")
        {
            context.AddError("A005001100");
            return;
        }
        string sessionid = Session.SessionID;
        CAHelper.FillAccIDList(context, gvAccount, sessionid);

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = sessionid;
        context.AddField("P_CARDNO").Value = txtCardno.Text;


        StringBuilder szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt("111111", ref szOutput);

        context.AddField("P_PWD").Value = szOutput.ToString();

        bool ok = context.ExecuteSP("SP_CA_RESETPASSWORD");

        if (ok)
        {
            AddMessage("M004111100");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            btnSubmit.Enabled = false;
        }
    }
}
