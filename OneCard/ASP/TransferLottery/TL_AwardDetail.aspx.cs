using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;
using TDO.UserManager;
/// <summary>
/// 领奖明细
/// 尤悦 20140429
/// </summary>

public partial class ASP_TransferLottery_TL_AwardDetail : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化部门  
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            selDept.SelectedValue = context.s_DepartID;
            //初始化日期 
            DateTime date = new DateTime();
            date = DateTime.Today;
            txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
            ShowNonDataGridView();
        }
        
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
    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_AWARDSTRADE", txtFromDate.Text, txtToDate.Text, selAWARDTYPE.SelectedValue, selDept.SelectedValue);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            return;
        }  
        gvResult.DataSource = dt;
        gvResult.DataBind();

       
       
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    private double totalFinfee = 0;  // 领奖金额 
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            
            totalFinfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));  
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[5].Text = totalFinfee.ToString("n");//领奖金额 
        }

       
    }
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvTax.DataSource = new DataTable();
        gvTax.DataBind();
    }

    
    
    private double totalAwards = 0;  // 中奖金额 
    private double totalTax = 0;     // 应納税额
    private double totalGetAwards = 0;  // 实际领奖金额 
    protected void gvTax_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvTax.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {

            totalAwards += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalTax += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totalGetAwards += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = totalAwards.ToString("n");//中奖金额 
            e.Row.Cells[5].Text = totalTax.ToString("n");//应納税额 
            e.Row.Cells[6].Text = totalGetAwards.ToString("n");//实际领奖金额 
        }


    }
    protected void btnExportTax_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_AWARDSTRADETAX", txtFromDate.Text, txtToDate.Text, selAWARDTYPE.SelectedValue, selDept.SelectedValue);
        if (dt.Rows.Count > 0)
        {
            List<String> list = new List<string>();
            list.Add("姓名");
            list.Add("证件号码");
            list.Add("手机号码");
            CommonHelper.AESDeEncrypt(dt, list);

            gvTax.DataSource = dt;
            gvTax.DataBind();
            gvTax.Visible = true;
            ExportGridView(gvTax);
            gvTax.Visible = false;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }



}