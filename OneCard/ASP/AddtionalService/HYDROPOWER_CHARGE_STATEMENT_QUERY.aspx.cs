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
using TM;
using TDO.UserManager;
using TDO.Financial;
using TDO.BusinessCode;
using System.Collections.Generic;

public partial class ASP_Financial_HYDROPOWER_CHARGE_STATEMENT_QUERY : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //控件初始化
            HYDROPHelper.InitItemCodes(selItemCode, true);//缴费类别
            HYDROPHelper.InitChargeTypes(selChargeType, true);//缴费方式
            //缴费状态
            selChargeStatus.Items.Add(new ListItem("",""));
            selChargeStatus.Items.Add(new ListItem("0:对账失败", "0"));
            selChargeStatus.Items.Add(new ListItem("1:对账成功", "1"));

            //开始日期、结束日期默认为系统日期
            txtFromDate.Text = DateTime.Now.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");

            gvResult.DataKeyNames = new string[] { "SEQNO" };

            FIHelper.selectDept(context, selDept, true);
            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        string p_fromDate = txtFromDate.Text;
        string p_endDate = txtToDate.Text;
        string p_ItemCode = selItemCode.Text;
        string p_ChargeType = selChargeType.Text;
        string p_CustomerNo = txtCustomer_No.Text;
        string p_ChargeStatus = selChargeStatus.Text;
        string p_Staff = selStaff.SelectedValue;
        string p_Dept = selDept.SelectedValue;

        DataTable data = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_Statement_Record",
            p_fromDate, p_endDate, p_ItemCode, p_ChargeType, p_CustomerNo, p_ChargeStatus, p_Staff, p_Dept);

        UserCardHelper.resetData(gvResult, data);
        gvResult.SelectedIndex = -1;
        gvResult.Columns[0].Visible = false;
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

    private double totalCharges = 0;

    protected void gvResult_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
            string result = GetTableCellValue(e.Row.Cells[9]);
            if (result.Contains("失败"))
            {
                result = string.Format("<span style='color:red;font-weight:bold;'>{0}</span>", result);
                e.Row.Cells[9].Text = result;
            }
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[1].Text = "总计";
            e.Row.Cells[8].Text = totalCharges.ToString("n");
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    private void InitStaffList(string deptNo)
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
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "");
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    protected void selDept_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
}