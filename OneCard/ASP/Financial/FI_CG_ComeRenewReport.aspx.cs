using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.Financial;
using Master;
using Common;
using System.Data;

public partial class ASP_Financial_FI_CG_ComeRenewReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
        }
    }
    private int operCount = 0;
    private double money = 0;
    /// <summary>
    /// 查询结果增加合计数字
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            money += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));
            operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = money.ToString("n");
            e.Row.Cells[2].Text = operCount.ToString();
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    //protected void queryBalUnit(object sender, EventArgs e)
    //{
    //    string name = txtBalUnitName.Text.Trim();
    //    if (name == "")
    //    {
    //        selBalUnit.Items.Clear();
    //        txtBalUnit.Text = "";
    //        return;
    //    }

    //    TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
    //    TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;
    //    tdoTF_TRADE_BALUNITIn.BALUNIT = "%" + name + "%";
    //    tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tm.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_NAME", null);

    //    selBalUnit.Items.Clear();
    //    foreach (TF_TRADE_BALUNITTDO ddoBalUnit in tdoTF_TRADE_BALUNITOutArr)
    //    {
    //        selBalUnit.Items.Add(new ListItem(ddoBalUnit.BALUNITNO + ":" + ddoBalUnit.BALUNIT, ddoBalUnit.BALUNITNO));
    //    }

    //    if (tdoTF_TRADE_BALUNITOutArr.Length > 0)
    //    {
    //        selBalUnit.SelectedValue = tdoTF_TRADE_BALUNITOutArr[0].BALUNITNO;
    //        txtBalUnit.Text = tdoTF_TRADE_BALUNITOutArr[0].BALUNITNO;
    //    }
    //    else
    //    {
    //        txtBalUnit.Text = "";
    //    }
    //}

    //protected void selBalUnit_Change(object sender, EventArgs e)
    //{
    //    txtBalUnit.Text = selBalUnit.SelectedValue;
    //}

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "LIJININCOME__RENEW_REPORT";
        pdo.var1 = txtDate.Text.Trim();
        //pdo.var7 = txtBalUnit.Text;

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);
        //hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
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

    // 查询输入校验处理
    private bool validate()
    {
        Validation valid = new Validation(context);

        if (Validation.isEmpty(txtDate))
        {
            context.AddError("查询时间不能为空");
        }
        else if (!Validation.isDate(txtDate.Text.Trim(), "yyyyMM"))
        {
            context.AddError("查询时间格式必须为yyyyMM");
        }
        if (context.hasError())
            return false;
        else
            return true;
    }
}
