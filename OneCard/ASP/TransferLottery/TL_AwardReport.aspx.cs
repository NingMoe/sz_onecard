using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;
using System.Data;
using TDO.UserManager;

public partial class ASP_TransferLottery_TL_AwardReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERY");
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
                return;
            }
            gvResult.DataSource = dt;
            gvResult.DataBind();
        }
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
    private double totalGetNum = 0;  //领奖数
    private double totalFinfee = 0;  // 领奖额 
    private double totalNotGetNum = 0;  //未领奖数
    private double totalNotFinfee = 0;  // 未领奖额 
    
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalGetNum += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));//领奖数
            totalFinfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));//领奖额
            totalNotGetNum += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));//未领奖数
            totalNotFinfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));//未领奖额
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = totalGetNum.ToString("n");//领奖数 
            e.Row.Cells[2].Text = totalFinfee.ToString("n");//领奖额 
            e.Row.Cells[3].Text = totalNotGetNum.ToString("n");//未领奖数 
            e.Row.Cells[4].Text = totalNotFinfee.ToString("n");//未领奖额
        }


    }
}