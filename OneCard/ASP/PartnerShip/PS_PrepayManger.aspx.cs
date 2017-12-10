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
using Master;
using Common;
using TM;
using TDO.PartnerShip;
using PDO.PartnerShip;

public partial class ASP_PartnerShip_PS_PrepayManger : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initLoad();
            //显示列表
            showConGridView();

            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        }

    }
    protected void initLoad()
    {
        //初始化网点结算单元
        TMTableModule tmTMTableModule = new TMTableModule();

        //从网点结算单元编码表(TF_DEPT_BALUNIT)中读取数据，放入下拉列表中

        TF_DEPT_BALUNITTDO tdoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
        TF_DEPT_BALUNITTDO[] tdoTF_DEPT_BALUNITOutArr = (TF_DEPT_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT_NAME", null);

        ControlDeal.SelectBoxFill(ddlBalUnit.Items, tdoTF_DEPT_BALUNITOutArr, "DBALUNIT", "DBALUNITNO", true);
    }
    private void showConGridView()
    {
        //显示交易信息列表
        lvwPrepayQuery.DataSource = new DataTable();
        lvwPrepayQuery.DataBind();
        lvwPrepayQuery.SelectedIndex = -1;
    }
    protected void ddlBalUnit_Change(object sender, EventArgs e)
    {
        //查询结算单元信息
        if (ddlBalUnit.SelectedValue.Equals(""))
        {
            clearInfo();
        }
        else
        {
            //查询网点结算单元信息
            DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitInfo", ddlBalUnit.SelectedValue);
            if (data.Rows.Count != 0)
            {
                labBalUnitNO.Text = data.Rows[0]["DBALUNITNO"].ToString();
                labBalUnit.Text = data.Rows[0]["DBALUNIT"].ToString();
                labCreatTime.Text = Convert.ToDateTime(data.Rows[0]["CREATETIME"]).ToShortDateString();                
                labBank.Text = data.Rows[0]["OPENBANK"].ToString();
                labBankAccNo.Text = data.Rows[0]["BANKACCNO"].ToString();
                labDeptType.Text = data.Rows[0]["DEPTTYPE"].ToString();
                labPrepayWarnLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYWARNLINE"]).ToString("n");
                labPrepayLimitLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYLIMITLINE"]).ToString("n");
                labBalCyclType.Text = data.Rows[0]["BALCYCLETYPECODE"].ToString();
                labBalInterval.Text = data.Rows[0]["BALINTERVAL"].ToString();
                labFinType.Text = data.Rows[0]["FINTYPECODE"].ToString();
                labFinCyclType.Text = data.Rows[0]["FINCYCLETYPECODE"].ToString();
                labFinCyclInterval.Text = data.Rows[0]["FININTERVAL"].ToString();
                labFinBank.Text = data.Rows[0]["OUTBANK"].ToString();
                labLinkMan.Text = data.Rows[0]["LINKMAN"].ToString();
                labPhone.Text = data.Rows[0]["UNITPHONE"].ToString();
                labAddress.Text = data.Rows[0]["UNITADD"].ToString();
                labEmail.Text = data.Rows[0]["UNITEMAIL"].ToString();
                labReMark.Text = data.Rows[0]["REMARK"].ToString();

                //提交按钮可用
                btnSupply.Enabled = true;

                //获取预付款余额
                getPrepayMoney();

                showConGridView();
            }
        }
    }

    protected void getPrepayMoney()
    {
        //获取预付款余额
        //网点结算单元预付款账户表(TF_F_DEPTBAL_PREPAY)中读取数据 
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYIn = new TF_F_DEPTBAL_PREPAYTDO();
        tdoTF_F_DEPTBALUNIT_PREPAYIn.DBALUNITNO = ddlBalUnit.SelectedValue;
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYOut = (TF_F_DEPTBAL_PREPAYTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBALUNIT_PREPAYIn, typeof(TF_F_DEPTBAL_PREPAYTDO), null, "TF_F_DEPTBALUNIT_PREPAY", null);
        if (tdoTF_F_DEPTBALUNIT_PREPAYOut != null)
        {
            labPrepay.Text = ((tdoTF_F_DEPTBALUNIT_PREPAYOut.PREPAY) / 100.0).ToString("n");
        }
        else
        {
            labPrepayWarnLine.Text = "";
            labPrepayLimitLine.Text = "";
            labPrepay.Text = "";
            btnSupply.Enabled = false;
            context.AddMessage("未找到预付款账户信息");
        }
    }

    protected void clearInfo()
    {
        //清空结算单元信息
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labCreatTime.Text = "";
        labBank.Text = "";
        labBankAccNo.Text = "";
        labDeptType.Text = "";
        labPrepayWarnLine.Text = "";
        labPrepayLimitLine.Text = "";
        labBalCyclType.Text = "";
        labBalInterval.Text = "";
        labFinType.Text = "";
        labFinCyclType.Text = "";
        labFinCyclInterval.Text = "";
        labFinBank.Text = "";
        labLinkMan.Text = "";
        labPhone.Text = "";
        labAddress.Text = "";
        labEmail.Text = "";
        labReMark.Text = "";
        labPrepay.Text = "";

        Income.Checked = true;
        txtDealMoney.Text = "";
        txtReMark.Text = "";

        //提交按钮不可用
        btnSupply.Enabled = false;

        //重置查询列表
        showConGridView();
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation()) return;

        ICollection dataView;
        
        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核预付款收支记录
                dataView = queryPrepayWaitEaxm();
                break;
            case"1":
                //查询审核通过预付款收支记录
                dataView = queryPrepayReg();
                break;
            case"2":
                //查询审核作废预付款收支记录
                dataView = queryPrepayEaxmCancel();
                break;
            default:
                dataView = new DataView();//空
                break;
        }

        //没有查询出记录时,显示错误
        if (dataView.Count == 0)
        {
            showConGridView();
            context.AddError("没有查询出任何记录");
            return;
        }
        ViewState["selectedValue"] = selExamState.SelectedValue;
        lvwPrepayQuery.DataSource = dataView;
        lvwPrepayQuery.DataBind();
    }
    //提交
    protected void btnSupply_Click(object sender, EventArgs e)
    {
        if (!supplyValidation()) return;

        SP_PS_PrepayMangerPDO pdo = new SP_PS_PrepayMangerPDO();
        string funccode = "";
        if (Income.Checked == true) 
            funccode = "INCOME";
        else if (Pay.Checked == true)
        {
            //if(!checkPrepayMoney()) return;
            funccode = "PAY"; 
        }

        pdo.FUNCCODE = funccode;
        pdo.MONEY = Convert.ToInt32(Convert.ToDouble(txtDealMoney.Text.Trim()) * 100);
        pdo.CHMONEY = hidChineseNum.Value;
        pdo.REMARK = txtReMark.Text.Trim();
        pdo.DBALUNITNO = ddlBalUnit.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            //刷新列表
            selExamState.SelectedValue = "0";
            lvwPrepayQuery.DataSource = queryPrepayWaitEaxm();
            lvwPrepayQuery.DataBind();
            string function = "";
            switch (funccode)
            {
                case "INCOME":
                    function = "收入";
                    break;
                case "PAY":
                    function = "支出";
                    break;
                default:
                    break;
            }
            //显示对应操作成功
            context.AddMessage(function + "操作成功");

            txtDealMoney.Text = "";
            txtReMark.Text = "";

            getPrepayMoney();
        }

    }
    //查询预付款收支记录
    private ICollection queryPrepayReg()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayInfo", ddlBalUnit.SelectedValue, txtFromDate.Text, txtToDate.Text);
        return new DataView(data);
    }
    //查询待审核预付款收支记录
    private ICollection queryPrepayWaitEaxm()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayExamInfo", ddlBalUnit.SelectedValue, txtFromDate.Text, txtToDate.Text);
        return new DataView(data);
    }
    //查询审核作废预付款收支记录
    private ICollection queryPrepayEaxmCancel()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayCancelInfo", ddlBalUnit.SelectedValue, txtFromDate.Text, txtToDate.Text);
        return new DataView(data);
    }
    //查询校验
    protected Boolean queryValidation()
    {
        if (ddlBalUnit.SelectedValue.Equals(""))
            context.AddError("A008905001：请选择网点结算单元", ddlBalUnit);

        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

        return !(context.hasError());
    }
    //提交校验
    protected Boolean supplyValidation()
    {
        //校验是否选择了结算单元

        if (ddlBalUnit.SelectedValue.Equals(""))
            context.AddError("A008905001：请选择网点结算单元", ddlBalUnit);
        //对交易金额的校验
        if (txtDealMoney.Text.Trim() == "" || txtDealMoney.Text.Trim() == "0")
            context.AddError("A008905002：交易金额不能为0或空", txtDealMoney);
        else if (!Validation.isPosRealNum(txtDealMoney.Text.Trim()))
            context.AddError("A008905003:交易金额必须为正数", txtDealMoney);

        //对备注的校验
        if (txtReMark.Text.Trim() != "")
            if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                context.AddError("A008905004：备注长度不能超过50位", txtReMark);      

        return !(context.hasError());
    }

    protected void lvwPrepayQuery_Page(object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        lvwPrepayQuery.PageIndex = e.NewPageIndex;
        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核预付款收支记录
                lvwPrepayQuery.DataSource = queryPrepayWaitEaxm();
                break;
            case "1":
                //查询审核通过预付款收支记录
                lvwPrepayQuery.DataSource = queryPrepayReg();
                break;
            case "2":
                //查询审核作废预付款收支记录
                lvwPrepayQuery.DataSource = queryPrepayEaxmCancel();
                break;
            default:
                break;
        }
        lvwPrepayQuery.DataBind();
    }
    /// <summary>
    /// 修改日期和金额的格式
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwPrepayQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (lvwPrepayQuery.Rows.Count > 0)
        {
            GridView gridView = new GridView();
            switch ((string)ViewState["selectedValue"])
            {
                case "0":
                    //查询待审核预付款收支记录
                    gridView.DataSource = queryPrepayWaitEaxm();
                    break;
                case "1":
                    //查询审核通过预付款收支记录

                    gridView.DataSource = queryPrepayReg();
                    break;
                case "2":
                    //查询审核作废预付款收支记录

                    gridView.DataSource = queryPrepayEaxmCancel();
                    break;
                default:
                    break;
            }
            gridView.DataBind();
            ExportGridView(gridView);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    /// <summary>
    /// 单元类型选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlBalUnit.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();
        sql.Append("SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1'");
        if (ddlBalType.SelectedIndex > 0)
        {
            sql.Append("AND DEPTTYPE = '" + ddlBalType.SelectedValue + "'");
        }
        else
        {
            sql.Append("AND DEPTTYPE <> '0'");
        }
        sql.Append("ORDER BY DBALUNITNO");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(ddlBalUnit, table, true);
    }
}