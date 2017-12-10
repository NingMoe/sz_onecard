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
 * 功能名: 专有账户_账户挂失
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/23    liuh			初次开发   2011/07/07    liuh           挂失和解挂分成两个功能
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_Block : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (CAHelper.HasNoPasswordPower(context))
            {
                div_password.Visible = false;
            }
            // 初始化集团客户
            GroupCardHelper.initGroupCustomer(context, selCorp);
            return;
        }
    }

    private void ClearGvResult()
    {
        //清空卡号信息
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    private void ClearAccount()
    {
        //清空账户信息
        gvAccount.DataSource = new DataTable();
        gvAccount.DataBind();
    }

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
        lblCorp.Text = "";
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearGvResult();
        ClearAccount();
        ClearUserInfo();
        btnSubmit.Enabled = false;

        //验证查询条件
        if (this.CheckQueryControl() == false)
        {
            return;
        }

        createGridViewDataSource(sender,e);

        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }
        
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource(sender,e);
    }

    private void createGridViewDataSource(object sender, EventArgs e)
    {
        List<string> vars = new List<string>();

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperno.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());
        vars.Add(this.txtCardNo.Text.Trim());
        StringBuilder strBuilder1 = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder1);
        vars.Add(strBuilder1.ToString());
        vars.Add(selCorp.SelectedValue.Trim());
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYACCTCUSTOMERBLOCKINFO", vars.ToArray());

        if (data.Rows.Count == 0)
        {
            context.AddError("A001090203:没有查询出对应信息");
            return;
        }
        else
        {
            gvResult.DataSource = data;
            gvResult.DataBind();
            gvResult.SelectedIndex = 0;
            gv_SelectedIndexChanged(sender, e);
        }
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
    /// 选择数据行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAccount();
        ClearUserInfo();

        // 得到选择行
        GridViewRow selectRow = gvResult.SelectedRow;
        string cardNo = selectRow.Cells[0].Text;

        #region 账户信息
        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", cardNo);
        UserCardHelper.resetData(gvAccount, data);
        string ACCT_ID;
        string cust_id;
        if (data != null && data.Rows.Count > 0)
        {
            cust_id = data.Rows[0]["CUST_ID"].ToString(); //取出客户标识
            ACCT_ID = data.Rows[0]["ACCT_ID"].ToString(); //取出账户标识
        }
        else
        {
            context.AddError("A001090102:未查出客户账户信息");
            return;
        }

        //取出所有账户标识
        ArrayList list = new ArrayList();
        for (int i = 0; i < data.Rows.Count; i++)
        {
            list.Add(data.Rows[i]["ACCT_ID"]);
        }
        ViewState["ACCT_ID"] = list;

        for (int i = 0; i < data.Rows.Count; i++)
        {
            if ((data.Rows[i]["STATE"]).ToString() != "A")
            {
                context.AddError("客户账户状态无效,不能挂失");
                this.btnSubmit.Enabled = false;
                return;
            }
        }

        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
        #endregion

        #region 用户信息
        listDDO = new Dictionary<String, DDOBase>();
        if (!CAHelper.GetCustInfo(context, cardNo, cust_id, out listDDO))
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

        #region 查询集团客户信息
        data = CAHelper.callQuery(context, "QRYCORPBYACCT", ACCT_ID);
        if (data != null && data.Rows.Count > 0)
        {
            lblCorp.Text = data.Rows[0]["CORPCODE"].ToString() + ":" + data.Rows[0]["CORPNAME"].ToString();
        }

        #endregion

        ////控制chk显示
        this.btnSubmit.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[2].Text.Trim() == "&nbsp;")
            {
                e.Row.Cells[2].Text = "";
            }
            if (e.Row.Cells[4].Text.Trim() == "&nbsp;")
            {
                e.Row.Cells[4].Text = "";
            }
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            e.Row.Cells[4].Text = DeEncrypt(e.Row.Cells[4].Text);
            if (!CommonHelper.HasOperPower(context))
            {
                e.Row.Cells[4].Text = CommonHelper.GetPaperNo(e.Row.Cells[4].Text);
            }
        }
    }

    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("请选择一行记录");
            return;
        }
        string cardNo = gvResult.SelectedRow.Cells[0].Text;

        if (!CAHelper.HasNoPasswordPower(context))
        {
            if (this.PassWD.Text.Trim() == "")
            {
                context.AddError("A001090202:请输入账户密码");
                return;
            }

            ArrayList list = (ArrayList)ViewState["ACCT_ID"];
            for (int i = 0; i < list.Count; i++)
            {
                //验证密码
                if (!CAHelper.CheckMultipleAccPWD(context, list[i].ToString(), PassWD.Text.Trim(), true))
                {
                    this.btnSubmit.Enabled = true;
                    return;
                }
            }
        }

        context.SPOpen();
        context.AddField("P_CARDNO").Value = cardNo;
        context.AddField("P_TRADETYPECODE").Value = "8E";

        bool ok = context.ExecuteSP("SP_CA_BLOCK");

        if (ok)
        {
            if (!context.hasError()) context.AddMessage("M001090111:账户挂失成功");

            btnPrintPZ.Enabled = true;

            //打印凭证
            ASHelper.preparePingZheng(ptnPingZheng, cardNo, lblCustName.Text, "专有账户挂失",
                "", "", "", lblPaperno.Text, "",
                "", "", context.s_UserID, context.s_DepartName,
                lblPapertype.Text, "0.00", "0.00");

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printdiv('ptnPingZheng1');", true);
            }
            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperno);
        bool isCardnoEmpty = Validation.isEmpty(this.txtCardNo);
        bool isNameEmpty = Validation.isEmpty(this.txtName);
        bool isCorpEmpty = (selCorp.SelectedValue.Trim().Length == 0);

        if (isPapernoEmpty && isCardnoEmpty && isNameEmpty && isCorpEmpty)
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

        if (isCardnoEmpty == false)
        {
            if (Validation.isNum(txtCardNo.Text.Trim()) == false)
            {
                context.AddError("A900010B93: 卡号必须是数字", txtCardNo);
                return false;
            }
            else if (this.txtCardNo.Text.Trim().Length != 16)
            {
                context.AddError("A900010B94: 卡号位数必须为16位", txtCardNo);
                return false;
            }
        }

        return true;
    }
}
