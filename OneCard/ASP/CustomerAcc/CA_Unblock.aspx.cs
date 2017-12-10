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
 * 功能名: 专有账户_账户解挂
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/07/07    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_Unblock : Master.Master 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            // 初始化集团客户
            GroupCardHelper.initGroupCustomer(context, selCorp);
            return;
        }
    }

    //清空查询列表
    private void ClearQueryList()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    //清空账户信息
    private void ClearAccountInfo()
    {
        gvAccount.DataSource = new DataTable();
        gvAccount.DataBind();
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
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearQueryList();
        ClearAccountInfo();
        ClearUserInfo();
        btnSubmit.Enabled = false;

        //验证查询条件
        if (this.CheckQueryControl() == false)
        {
            return;
        }
        createGridViewDataSource(sender, e);
        

       // btnSubmit.Enabled = false;
    }

    private void createGridViewDataSource(object sender, EventArgs e)
    {
        List<string> vars = new List<string>();

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperno.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());

        vars.Add(this.txtCardNo.Text.Trim());

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());
        vars.Add(selCorp.SelectedValue.Trim());
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYACCTCUSTOMERBLOCKTRANINFO", vars.ToArray());

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

    private void ShowAccountUserInfo(string cardNo)
    {
        
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource(sender, e);
    }

    protected void gv_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[2].Text == "&nbsp;")
            {
                e.Row.Cells[2].Text = "";
            }
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            if (e.Row.Cells[4].Text == "&nbsp;")
            {
                e.Row.Cells[4].Text = "";
            }
            e.Row.Cells[4].Text = DeEncrypt(e.Row.Cells[4].Text);
            if (!CommonHelper.HasOperPower(context))
            {
                e.Row.Cells[4].Text = CommonHelper.GetPaperNo(e.Row.Cells[4].Text);
            }
        }
    }

    /// <summary>
    /// 选择数据行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行
        GridViewRow selectRow = gvResult.SelectedRow;
        string cardNo = selectRow.Cells[0].Text;

        #region 账户信息
        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", cardNo);
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
        //取出所有客户标识
        ArrayList list = new ArrayList();
        for (int i = 0; i < data.Rows.Count; i++)
        {
            list.Add(data.Rows[i]["ACCT_ID"]);
        }
        ViewState["ACCT_ID"] = list;

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
            DeEncrypt(lblPaperno,((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(lblCustaddr,((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_ADDR);
            lblCustpost.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_POST;
            DeEncrypt(lblCustphone,((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_PHONE);
            DeEncrypt(lblCustTelphone,((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_TELPHONE);
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

        for (int i = 0; i < data.Rows.Count; i++)
        {
            if ((data.Rows[i]["STATE"]).ToString() != "F")
            {
                context.AddError("账户状态为：" + CAHelper.GetAccStateByCode((data.Rows[i]["STATE"]).ToString()) + "，不能解挂");
                this.btnSubmit.Enabled = false;
                return;
            }
        }
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

    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 得到选择行
        GridViewRow selectRow = gvResult.SelectedRow;
        if (selectRow == null)
        {
            context.AddError("A001090112:请选择一个挂失卡");
            return;
        }
        string cardNo = gvResult.SelectedRow.Cells[0].Text;

        context.SPOpen();
        context.AddField("P_CARDNO").Value = cardNo;
        context.AddField("P_TRADETYPECODE").Value = "8F";

        bool ok = context.ExecuteSP("SP_CA_BLOCK");

        if (ok)
        {
            if (!context.hasError()) context.AddMessage("M001090112:账户解挂成功");

            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isNameEmpty = Validation.isEmpty(this.txtName);
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperno);
        bool isCardnoEmpty = Validation.isEmpty(this.txtCardNo);
        bool isCorpEmpty = (selCorp.SelectedValue.Trim().Length == 0);

        if (isNameEmpty && isPapernoEmpty && isCardnoEmpty && isCorpEmpty)
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
