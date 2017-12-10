using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TDO.UserManager;
using Common;
using TDO.BusinessCode;
using System.Collections;
/***************************************************************
 * 功能名: 专有账户  账单查询及维护
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/03/21    尤悦			初次开发
 ****************************************************************/
public partial class ASP_GroupCard_GC_AccountQueryAndMaintain : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();

        }
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvAccountList.DataSource = new DataTable();
        gvAccountList.DataBind();
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void Init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化录入员工
        InitStaffList(selStaff, "");
        //初始化账单状态
        InitStatus();
        if (HasOperPower("201013")) //如果操作权限是公司主管 add by yy 2013/5/22
        {
            detail.Visible=true;
        }
        else
        {
            detail.Visible=false;
        }

    }
    /// <summary>
    /// 判断操作权限 add by yy 2013/5/22
    /// </summary>
    /// <param name="powerCode"></param>
    /// <returns></returns>
    private bool HasOperPower(string powerCode)
    {
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }
    /// <summary>
    /// 初始化录入员工下拉选框
    /// </summary>
    /// <param name="ddl">控件名称</param>
    /// <param name="deptNo">部门编码</param>
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(ddl, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    //初始化账单状态
    private void InitStatus()
    {
        ddlAccountState.Items.Add(new ListItem("---请选择---", ""));
        ddlAccountState.Items.Add(new ListItem("1:录入", "1"));
        ddlAccountState.Items.Add(new ListItem("2:部分使用", "2"));
        ddlAccountState.Items.Add(new ListItem("3:完成使用", "3"));
        ddlAccountState.Items.Add(new ListItem("4:作废", "4"));
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        gvAccountList.DataSource = query();
        gvAccountList.DataBind();
        gvAccountList.SelectedIndex = -1;
        Clear();
    }
    /// <summary>
    /// 查询户名
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void queryAccountName(object sender, EventArgs e)
    {
        queryCompany(txtAccountName, selAccountName);
    }
    private void queryCompany(TextBox txtCompanyPar, DropDownList selCompanyPar)
    {
        //模糊查询户名，并在列表中赋值
        string name = txtCompanyPar.Text.Trim();
        if (name == "")
        {
            selCompanyPar.Items.Clear();
            context.DBOpen("Select");
            string sql = @"SELECT  DISTINCT ACCOUNTNAME FROM TF_F_CHECK  WHERE USETAG ='1' AND ACCOUNTNAME IS NOT NULL";
            DataTable table = context.ExecuteReader(sql);
            if (table.Columns.Count > 0)
            {

                selCompanyPar.DataSource = table;
                selCompanyPar.DataTextField = table.Columns[0].ColumnName;
                selCompanyPar.DataValueField = table.Columns[0].ColumnName;
                selCompanyPar.DataBind();
                selCompanyPar.Items.Insert(0, new ListItem("---请选择---", "0"));
                selCompanyPar.SelectedIndex = -1;
            }
            else
            {
                selCompanyPar.Items.Add(new ListItem("---请选择---", ""));
            }
            return;
        }
        else
        {
            string accountname = "%" + name + "%";
            selCompanyPar.Items.Clear();
            context.DBOpen("Select");
            string sql = @"SELECT DISTINCT ACCOUNTNAME FROM TF_F_CHECK  WHERE USETAG ='1' AND ACCOUNTNAME LIKE '" + accountname + "' ";
            DataTable table = context.ExecuteReader(sql);
            if (table.Columns.Count > 0)
            {
                selCompanyPar.DataSource = table;
                selCompanyPar.DataTextField = table.Columns[0].ColumnName;
                selCompanyPar.DataValueField = table.Columns[0].ColumnName;
                selCompanyPar.DataBind();
                selCompanyPar.Items.Insert(0, new ListItem("---请选择---", "0"));
                selCompanyPar.SelectedIndex = -1;
            }
            else
            {
                selCompanyPar.Items.Add(new ListItem("---请选择---", ""));
            }
            return;
        }
    }

    /// <summary>
    /// 单位名称全称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selAccountName_Changed(object sender, EventArgs e)
    {
        if (selAccountName.SelectedItem.Text != "---请选择---")
        {
            txtAccountName.Text = selAccountName.SelectedItem.ToString();
        }
        else
        {
            txtAccountName.Text = string.Empty;
        }
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        string companyName = "";
        if (selAccountName.SelectedItem != null && selAccountName.SelectedIndex > 0)
        {
            companyName = selAccountName.SelectedItem.Text;
        }
        else
        {
            companyName = txtAccountName.Text.Trim();
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        DataTable data = GroupCardHelper.callOrderQuery(context, "AccountQueryAndMaintainQuery", companyName,
            money, ddlAccountState.SelectedValue, selStaff.SelectedValue, txtFromDate.Text.Trim(), txtToDate.Text.Trim(), txtAccount.Text.Trim(), txtBankName.Text.Trim(),selLeftMoney.SelectedValue);
        if (data == null || data.Rows.Count < 1)
        {
            gvAccountList.DataSource = new DataTable();
            gvAccountList.DataBind();
            context.AddError("未查出账单记录");
        }
        return new DataView(data);
    }
    private bool ValidInput()
    {
        if (txtTotalMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtTotalMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtTotalMoney);
            }
        }
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        if (txtAccount.Text.Trim().Length > 0)  //对方帐号不为空时
        {
            if (Validation.strLen(txtAccount.Text.Trim()) > 20)
            {
                context.AddError("对方帐号长度不能超过20位", txtAccount);
            }
        }
        if (txtBankName.Text.Trim().Length > 0)  //到账银行不为空时
        {
            if (Validation.strLen(txtBankName.Text.Trim()) > 50)
            {
                context.AddError("到账银行长度不能超过50位", txtBankName);
            }
        }
        return !(context.hasError());
    }
    protected void gvAccountList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvAccountList','Select$" + e.Row.RowIndex + "')");
        }
    }
    /// <summary>
    /// 显示账单信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvAccountList_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidLeftMoney.Value = "";

        GridViewRow row = gvAccountList.SelectedRow;
        if (row != null)
        {
            for (int i = 0; i < 11; i++)
            {
                if (row.Cells[i].Text.Trim().Equals("&nbsp;"))
                {
                    row.Cells[i].Text = "";
                }
            }
            //交易日期
            txtTradeDate.Text = row.Cells[1].Text.Trim();
            //收入金额
            txtIncome.Text = row.Cells[2].Text.Trim();
            //对方开户行
            txtOtherDepositBank.Text = row.Cells[9].Text.Trim();
            //对方户名
            txtOtherAccountName.Text = row.Cells[7].Text.Trim();
            //对方账号
            txtOtherAccount.Text = row.Cells[8].Text.Trim();
            //交易说明
            txtTradeInstruction.Text = row.Cells[10].Text.Trim() == "&nbsp;" ? "" : row.Cells[10].Text.Trim();
            //交易摘要
            txtTradeSummary.Text = row.Cells[11].Text.Trim() == "&nbsp;" ? "" : row.Cells[11].Text.Trim();
            //交易附言
            txtTradePostscript.Text = row.Cells[12].Text.Trim() == "&nbsp;" ? "" : row.Cells[12].Text.Trim();
            //到账银行
            txtPaymentBank.Text = row.Cells[3].Text.Trim();
            //到账账号
            txtPaymentAccount.Text = row.Cells[4].Text.Trim();

            //剩余金额
            hidLeftMoney.Value = row.Cells[6].Text.Trim();
        }
    }
    /// <summary>
    /// 录入账单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_TRADEDATE").Value = txtTradeDate.Text.Trim();//交易日期(txtTotalMoney.Text.Trim()) * 100).ToString();
        context.AddField("P_MONEY").Value = (Convert.ToDecimal(txtIncome.Text.Trim()) * 100).ToString();//收入金额
        context.AddField("P_OPENBANK").Value = txtOtherDepositBank.Text.Trim();//对方开户行
        context.AddField("P_ACCOUNTNAME").Value = txtOtherAccountName.Text.Trim();//对方户名
        context.AddField("P_ACCOUNTNUMBER").Value = txtOtherAccount.Text.Trim();//对方账号
        context.AddField("P_EXPLAIN").Value = txtTradeInstruction.Text.Trim();//交易说明
        context.AddField("P_SUMMARY").Value = txtTradeSummary.Text.Trim();//交易摘要
        context.AddField("P_POSTSCRIPT").Value = txtTradePostscript.Text.Trim();//交易附言
        context.AddField("P_TOACCOUNTBANK").Value = txtPaymentBank.Text.Trim();//到账银行
        context.AddField("P_TOACCOUNTNUMBER").Value = txtPaymentAccount.Text.Trim();//到账账号
        bool ok = context.ExecuteSP("SP_GC_ADDACCOUNT");
        if (ok)
        {
            AddMessage("账单新增成功");
            gvAccountList.DataSource = query();
            gvAccountList.DataBind();
        }

    }
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);

        //交易日期校验
        if (string.IsNullOrEmpty(txtTradeDate.Text.Trim()))
        {
            context.AddError("A094780200：交易日期不能为空", txtTradeDate);
        }
        else
        {
            valid.beDate(txtTradeDate, "A094780201: 交易日期格式不是yyyyMMdd");
        }
        //金额校验
        if (string.IsNullOrEmpty(txtIncome.Text.Trim()))
        {
            context.AddError("A094780202：收入金额不能为空", txtIncome);
        }
        else if (!Validation.isPrice(txtIncome.Text.Trim()))
        {
            context.AddError("A094780203：收入金额输入不正确", txtIncome);
        }
        else if (Convert.ToDecimal(txtIncome.Text.Trim()) <= 0)
        {
            context.AddError("A094780204：收入金额必须是正数", txtIncome);
        }

        //对方开户行
        //if(txtOtherDepositBank.Text.Trim().Length<1)
        //{
        //    context.AddError("A094780205：对方开户行不能为空", txtOtherDepositBank);
        //}
        if (Validation.strLen(txtOtherDepositBank.Text.Trim()) > 100)
        {
            context.AddError("A094780205：对方开户行长度不能超过50位", txtOtherDepositBank);
        }
        //对方户名
        //if (txtOtherAccountName.Text.Trim().Length < 1)
        //{
        //    context.AddError("A094780207：对方户名不能为空", txtOtherAccountName);
        //}

        if (Validation.strLen(txtOtherAccountName.Text.Trim()) > 100)
        {
            context.AddError("A094780206：对方户名长度不能超过50位", txtOtherAccountName);
        }
        //对方帐号
        //if (txtOtherAccount.Text.Trim().Length < 1)
        //{
        //    context.AddError("A09478029：对方帐号不能为空", txtOtherAccount);
        //}
        if (Validation.strLen(txtOtherAccount.Text.Trim()) > 30)
        {
            context.AddError("A094780207：对方帐号长度不能超过30位", txtOtherAccount);
        }
        if (txtOtherAccount.Text.Trim().Length > 0)
        {
            if (!Validation.isNum(txtOtherAccount.Text.Trim()))
            {
                context.AddError("A001002708:对方帐号必须是数字", txtOtherAccount);
            }
        }
        //交易说明
        if (Validation.strLen(txtTradeInstruction.Text.Trim()) > 200)
        {
            context.AddError("A094780209：交易说明长度不能超过100位", txtTradeInstruction);
        }
        //交易摘要
        if (Validation.strLen(txtTradeSummary.Text.Trim()) > 200)
        {
            context.AddError("A094780210：交易摘要长度不能超过100位", txtTradeSummary);
        }
        //交易附言
        if (Validation.strLen(txtTradePostscript.Text.Trim()) > 200)
        {
            context.AddError("A094780211：交易附言长度不能超过100位", txtTradePostscript);
        }
        //到账银行
        if (Validation.strLen(txtPaymentBank.Text.Trim()) > 100)
        {
            context.AddError("A094780212：到账银行长度不能超过50位", txtPaymentBank);
        }
        //到账帐号
        if (txtPaymentAccount.Text.Trim().Length < 1)
        {
            context.AddError("A094780213：到账帐号不能为空", txtPaymentAccount);
        }
        else if (Validation.strLen(txtPaymentAccount.Text.Trim()) > 30)
        {
            context.AddError("A094780214：到账帐号长度不能超过30位", txtPaymentAccount);
        }
        else if (!Validation.isNum(txtPaymentAccount.Text.Trim()))
        {
            context.AddError("A001002715:到账帐号必须是数字", txtPaymentAccount);
        }
        return !context.hasError();
    }


    protected void gvAccountList_Page(object sender, GridViewPageEventArgs e)
    {
        gvAccountList.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 清空账单信息
    /// </summary>
    private void Clear()
    {
        txtTradeDate.Text = string.Empty;
        txtIncome.Text = string.Empty;
        txtOtherDepositBank.Text = string.Empty;
        txtOtherAccountName.Text = string.Empty;
        txtOtherAccount.Text = string.Empty;
        txtTradeInstruction.Text = string.Empty;
        txtTradeSummary.Text = string.Empty;
        txtTradePostscript.Text = string.Empty;
        txtPaymentBank.Text = string.Empty;
        txtPaymentAccount.Text = string.Empty;
    }
    /// <summary>
    /// 删除
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDeleteSubmit_Click(object sender, EventArgs e)
    {
        if (gvAccountList.SelectedRow == null)
        {
            context.AddError("A004P03R01: 没有选中任何行");
            return;
        }
        if (gvAccountList.SelectedRow.Cells[5].Text.Trim() != "0")
        {
            context.AddError("A004P03R02:已使用金额不为0的账单不允许删除！");
            return;
        }
        HiddenField hidCheckID = gvAccountList.SelectedRow.Cells[0].FindControl("tradID") as HiddenField;
        context.SPOpen();
        context.AddField("P_CHECKID").Value = hidCheckID.Value;
        bool ok = context.ExecuteSP("SP_GC_DELETEACCOUNT");
        if (ok)
        {

            AddMessage("账单删除成功");
            btnQuery_Click(sender, e);
        }

    }

    /// <summary>
    /// 退款
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRefundSubmit_Click(object sender, EventArgs e)
    {
        if (gvAccountList.SelectedRow == null)
        {
            context.AddError("A004P03R01: 没有选中任何行");
            return;
        }
        if (gvAccountList.SelectedRow.Cells[6].Text.Trim() == "0")
        {
            context.AddError("A094781029：剩余金额为0，不允许退款");
            return;
        }

        HiddenField hidCheckID = gvAccountList.SelectedRow.Cells[0].FindControl("tradID") as HiddenField;
        context.SPOpen();
        context.AddField("P_CHECKID").Value = hidCheckID.Value;
        context.AddField("P_LEFTMONEY").Value = decimal.Parse(gvAccountList.SelectedRow.Cells[6].Text.Trim()) * 100;
        bool ok = context.ExecuteSP("SP_GC_REFOUNDACCOUNT");
        if (ok)
        {
            AddMessage("账单退款成功");
            btnQuery_Click(sender, e);
        }
    }

    protected void gvAccountList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;  //隐藏CHECKID列
        }
    }
    /// <summary>
    /// 导出excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvAccountList.Rows.Count > 0)
        {
            gvAccountList.AllowPaging = false;//不分页导出Excel
            btnQuery_Click(sender, e);
            ExportGridView(gvAccountList);
            gvAccountList.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}