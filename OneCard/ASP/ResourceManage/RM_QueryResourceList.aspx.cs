using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Common;
/***************************************************************
 * 功能名: 其他资源管理  资源维护审批
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/13    董翔			初次开发
 ****************************************************************/

public partial class ASP_ResourceManage_RM_QueryResourceList : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            init_Page();
        }
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);

        //初始化网点
        OtherResourceManagerHelper.selectDepartment(context, selDept, true);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    //查询资源名称
    protected void ddlResourceType_SelectIndexChange(object sender, EventArgs e)
    {
        ddlResource.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
    }

    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {


        gvResult.DataSource = queryResourceList();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 3 || i == 5 || i == 7 || i == 9 || i == 11 || i == 13)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[2].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i > 2 && i < 14)
                {
                    e.Row.Cells[i].Visible = false;
                }
            }
        }
    }

    /// <summary>
    /// 查询资源库存明细
    /// </summary>
    /// <returns></returns>
    protected ICollection queryResourceList()
    {
        string[] parm = new string[3];
        parm[0] = ddlResourceType.SelectedValue;
        parm[1] = ddlResource.SelectedValue;
        parm[2] = selDept.SelectedValue;
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_ResourceList", parm);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

}