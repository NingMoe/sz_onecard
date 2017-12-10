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
using PDO.Financial;
using Master;
using Common;
using TDO.BalanceParameter;
using TDO.BalanceChannel;
using TM;
using TDO.UserManager;
public partial class ASP_Financial_FI_DeptOperReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            //TMTableModule tmTMTableModule = new TMTableModule();
            //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            //ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        }
        
    }
    //protected void selDept_Changed(object sender, EventArgs e)
    //{
    //    InitStaffList(selDept.SelectedValue);
    //}
//    private void InitStaffList(string deptNo)
//    {
//        if (deptNo == "")
//        {
//            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
//            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
//            {
//                context.DBOpen("Select");

//                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
//                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
//                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
//                DataTable table = context.ExecuteReader(sql);
//                GroupCardHelper.fill(selStaff, table, true);

//                return;
//            }

//            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
//            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

//            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "");
//            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
//            selStaff.SelectedValue = context.s_UserID;
//        }
//        else
//        {
//            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
//            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
//            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

//            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
//            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
//        }
//    }
    //查询校验
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

    }
    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;


        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryDeptOperReport", txtFromDate.Text, txtToDate.Text);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            context.AddError("N005030001: 查询结果为空");
            return;
        }

        UserCardHelper.resetData(gvResult, dt);
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
    //private int total = 0;  
    //protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        total += Convert.ToInt32(GetTableCellValue(e.Row.Cells[1]));
    //    }
    //    else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
    //    {
    //        e.Row.Cells[0].Text = "总计";
    //        e.Row.Cells[1].Text = total.ToString();
    //    }
    //}
}