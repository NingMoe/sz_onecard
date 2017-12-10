using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_ResourceManage_RM_StaffMaintainQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化页面
            init_Page();
            
        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");
        


        //初始化网点
        OtherResourceManagerHelper.selectDepartment(context, selDept, true);
        //selDept.SelectedValue = context.s_DepartID;

        //初始化维护员工
        bindStaffName(selStaff);
        

    }
    private void bindStaffName(DropDownList ddlStaff)
    {
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_MaintainStaff");
        ddlStaff.Items.Add(new ListItem("---请选择---", ""));
        if (data.Rows.Count >0)
        {
            Object[] itemArray;
            ListItem li;
            for (int i = 0; i < data.Rows.Count; ++i)
            {
                itemArray = data.Rows[i].ItemArray;
                li = new ListItem(itemArray[0].ToString());
                ddlStaff.Items.Add(li);
            }
        }
        
    }

    /// <summary>
    /// 翻页事件
    /// </summary>
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataSource = queryStaffMaintain();
        gvResult.DataBind();
    }
   
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        gvResult.DataSource = queryStaffMaintain();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    //查询工单
    protected DataTable queryStaffMaintain()
    {
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_StaffMaintainQuery", txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selDept.SelectedValue,
            selStaff.SelectedValue, ddlState.SelectedValue);
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return data;
    }
    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");
        return !context.hasError();
    }
    /// <summary>
    /// Excel导出
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            gvResult.AllowPaging = false;//不分页导出Excel
            btnQuery_Click(sender, e);
            ExportGridView(gvResult);
            gvResult.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}