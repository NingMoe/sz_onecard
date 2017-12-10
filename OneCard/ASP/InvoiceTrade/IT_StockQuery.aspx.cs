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
using Common;
using PDO.Financial;
using Master;
using System.Collections.Generic;

public partial class ASP_InvoiceTrade_IT_StockQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            UserCardHelper.selectDepts(context, selDepartName, true);
           
        }
    }
   
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        if (context.hasError()) return;
        List<string> vars = new List<string>();

        vars.Add(this.selDepartName.SelectedValue);
        DataTable data = SPHelper.callITQuery(context, "StockQuery", vars.ToArray());
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }
        else
        {
            btnPrint.Enabled = true;
        }
        totalCount1 = 0;
        totalCount2 = 0;
        totalCount3 = 0;
        totalCount4 = 0;
        totalCount5 = 0;
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
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    int totalCount1 = 0;
    int totalCount2 = 0;
    int totalCount3 = 0;
    int totalCount4 = 0;
    int totalCount5 = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        
        //ControlDeal.RowDataBound(e);
        if (this.selDepartName.SelectedValue == "")
        {
            if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
            {
                totalCount1 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[1]));
                totalCount2 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
                totalCount3 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
                totalCount4 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4]));
                totalCount5 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[5]));
            }
            else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
            {
                e.Row.Cells[0].Text = "合计";
                e.Row.Cells[1].Text = totalCount1.ToString();
                e.Row.Cells[2].Text = totalCount2.ToString();
                e.Row.Cells[3].Text = totalCount3.ToString();
                e.Row.Cells[4].Text = totalCount4.ToString();
                e.Row.Cells[5].Text = totalCount5.ToString();
            }
        }
        else
        {
            if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
            {
                totalCount1 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[1]));
                totalCount2 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
                totalCount3 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
                totalCount4 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4]));
                totalCount5 += Convert.ToInt32(GetTableCellValue(e.Row.Cells[5]));
            }
            else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
            {
                e.Row.Cells[0].Text = "合计";
                e.Row.Cells[1].Text = totalCount1.ToString();
                e.Row.Cells[2].Text = totalCount2.ToString();
                e.Row.Cells[3].Text = totalCount3.ToString();
                e.Row.Cells[4].Text = totalCount4.ToString();
                e.Row.Cells[5].Text = totalCount5.ToString();
            }
        }
        
    }
}
