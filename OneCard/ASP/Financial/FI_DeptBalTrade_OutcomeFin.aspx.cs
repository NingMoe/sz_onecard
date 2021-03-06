﻿using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using TDO.UserManager;
using Common;

public partial class ASP_Financial_FI_DeptBalTrade_OutcomeFin : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化日期
            txtFromDate.Text = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");

            //初始化营业厅
            DeptBalunitHelper.InitDBalUnit(context, selBalUnit, txtBalUnitName);

            //初始化业务类型
            InitTradeType();

            //显示表格
            showConGridView();
        }
    }

    /// <summary>
    /// 初始化业务类型
    /// </summary>
    private void InitTradeType()
    {
        context.DBOpen("Select");
        string sql = "SELECT DISTINCT SHOWNAME,SHOWNO  FROM TD_TRADETYPE_SHOW ORDER BY SHOWNO";
        DataTable dt = context.ExecuteReader(sql);
        GroupCardHelper.fill(selTradeType, dt, true);
    }

    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        if (!checkEndDate()) return;
        string tradeType;
        if (selTradeType.SelectedIndex < 1)
        {
            tradeType = "0000";
        }
        else
        {
            tradeType = selTradeType.SelectedValue;
        }
        DataTable data = SPHelper.callQuery("SP_PS_Query_Report", context, "QueryOutcomeFin", txtFromDate.Text, txtToDate.Text, selBalUnit.SelectedValue, tradeType);
        if (data == null || data.Rows.Count < 1)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {

    }
    
    private double totalBalFee;
    private int totalTimes;
    private double cancelTotalBalFee;
    private int cancelTotalTimes;
    private double comFee;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalBalFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
            totalTimes += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
            cancelTotalBalFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            cancelTotalTimes += Convert.ToInt32(GetTableCellValue(e.Row.Cells[6]));
            comFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = totalBalFee.ToString("n");
            e.Row.Cells[3].Text = totalTimes.ToString();
            e.Row.Cells[5].Text = cancelTotalBalFee.ToString("n");
            e.Row.Cells[6].Text = cancelTotalTimes.ToString();
            e.Row.Cells[7].Text = comFee.ToString("n");
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    // 查询输入校验处理
    private void validate()
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
    }

    private bool checkEndDate()
    {
        context.DBOpen("Select");
        string sql = "select REALEXECTIME from tp_job where jobno = 'DP000100'";
        DataTable table = context.ExecuteReader(sql);
        if (table != null && table.Rows.Count > 0 && table.Rows[0]["REALEXECTIME"].ToString().Trim().Length > 0)
        {
            DateTime dealDate = Convert.ToDateTime(Convert.ToDateTime(table.Rows[0]["REALEXECTIME"].ToString().Trim()).ToShortDateString());
            DateTime endDate = DateTime.ParseExact(txtToDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        else
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        return true;
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