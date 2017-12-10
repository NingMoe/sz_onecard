using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.PartnerShip;
using PDO.PartnerShip;

/***************************************************************
 * 功能名: 代理营业厅_预付款清单
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/02/08    liuh			初次开发
 * 
 ****************************************************************/
public partial class ASP_Financial_FI_DBalunitAccTrade : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            //初始化日期

            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            //初始化营业厅
            DeptBalunitHelper.InitDBalUnit(context, selBalUnit, txtBalUnitName);

            selBalUnit_Change(sender, e);
        }
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ValidateInputs();

        if (context.hasError()) return;

        List<string> vars = new List<string>();
        vars.Add(txtFromDate.Text);
        vars.Add(txtToDate.Text);
        vars.Add(selBalUnit.SelectedValue);

        //查询结算单元信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_Report", context, "QueryPrepayTrade", vars.ToArray());

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    /// <summary>
    /// 分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    /// <summary>
    /// 修改日期和金额的格式
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }

    /// <summary>
    /// 查询输入校验处理
    /// </summary>
    private void ValidateInputs()
    {
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

        if (valid.beDate(txtFromDate, "").Value.AddMonths(6) < DateTime.Now)
            context.AddError("A001003191:查询时间超过6个月");

    }

    /// <summary>
    /// 结算单元选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selBalUnit_Change(object sender, EventArgs e)
    {
        //查询结算单元信息
        if (selBalUnit.SelectedValue.Equals(""))
        {
            labPrepayWarnLine.Text = "";
            labPrepayLimitLine.Text = "";
            labPrepay.Text = "";
        }
        else
        {
            getPrepayMoney();
        }
    }

    /// <summary>
    /// 获取预付款余额，预警额度、最低额度
    /// </summary>
    protected void getPrepayMoney()
    {
        //获取预付款余额
        //网点结算单元预付款账户表(TF_F_DEPTBAL_PREPAY)中读取数据 
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYIn = new TF_F_DEPTBAL_PREPAYTDO();
        tdoTF_F_DEPTBALUNIT_PREPAYIn.DBALUNITNO = selBalUnit.SelectedValue;
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYOut = (TF_F_DEPTBAL_PREPAYTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBALUNIT_PREPAYIn, typeof(TF_F_DEPTBAL_PREPAYTDO), null, "TF_F_DEPTBAL_PREPAY", null);
        if (tdoTF_F_DEPTBALUNIT_PREPAYOut != null)
        {
            labPrepay.Text = ((tdoTF_F_DEPTBALUNIT_PREPAYOut.PREPAY) / 100.0).ToString("n");

            TF_DEPT_BALUNITTDO tdoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
            tdoTF_DEPT_BALUNITIn.DBALUNITNO = tdoTF_F_DEPTBALUNIT_PREPAYOut.DBALUNITNO;
            TF_DEPT_BALUNITTDO tdoTF_F_DEPTBAL_PREPAYOut = (TF_DEPT_BALUNITTDO)tmTMTableModule.selByPK(context, tdoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT", null);
            if (tdoTF_F_DEPTBAL_PREPAYOut != null)
            {
                labPrepayWarnLine.Text = (tdoTF_F_DEPTBAL_PREPAYOut.PREPAYWARNLINE / 100.0).ToString("n");
                labPrepayLimitLine.Text = (tdoTF_F_DEPTBAL_PREPAYOut.PREPAYLIMITLINE / 100.0).ToString("n");
            }
        }
        else
        {
            labPrepayWarnLine.Text = "";
            labPrepayLimitLine.Text = "";
            labPrepay.Text = "";
            context.AddMessage("未找到预付款账户信息");
        }
    }

    #region 根据输入结算单元名称初始化下拉选项
    /// <summary>
    /// 根据输入结算单元名称初始化下拉选项
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBalUnitName_Changed(object sender, EventArgs e)
    {
        //初始化营业厅
        DeptBalunitHelper.InitDBalUnit(context, selBalUnit, txtBalUnitName);
    }
    #endregion
}
