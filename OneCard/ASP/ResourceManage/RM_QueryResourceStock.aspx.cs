using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
/***************************************************************
 * 功能名: 其他资源管理  库存查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/12   董翔			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_QueryResourceStock : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化资源类型
            OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);
            //初始化资源名称
            OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
            showNonDataGridView();
        }
        ondisplay();    //网点结果数量显示
    }

    //查询资源名称
    protected void ddlResourceType_SelectIndexChange(object sender, EventArgs e)
    {
        ddlResource.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ondisplay();
        string[] parm = new string[2];
        parm[0] = ddlResourceType.SelectedValue;
        parm[1] = ddlResource.SelectedValue;
        DataTable dt = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_STOCK", parm);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        else
        {
            //if (selSellType.SelectedValue == "01") //出入库
            //{
                ResourceManageHelper.resetData(gvResultUseCard1, dt);
                gvResultUseCard1.Visible = true;
                gvResultUseCard2.Visible = false;
                gvResultUseCard1.SelectedIndex = -1;
            //}
            //else
            //{
            //    ResourceManageHelper.resetData(gvResultUseCard2, dt);
            //    gvResultUseCard1.Visible = false;
            //    gvResultUseCard2.Visible = true;
            //}
        }
    }

    //初始化Grid值

    private void showNonDataGridView()
    {
        gvResultUseCard1.DataSource = new DataTable();
        gvResultUseCard1.DataBind();
        gvResultUseCard2.DataSource = new DataTable();
        gvResultUseCard2.DataBind();
        gvUser.DataSource = new DataTable();
        gvUser.DataBind();
    }
    //用户卡单击事件
    protected void gvResultUseCard1_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultUseCard1','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
        }
        

    }

    //用户卡Grid选择
    public void gvResultUseCard1_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow selectRow = gvResultUseCard1.SelectedRow;
        string[] parm = new string[1];
        parm[0] = selectRow.Cells[1].Text.ToString().Split(':')[0].ToString();
        DataTable dt = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_STOCK_DEPART", parm);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        ResourceManageHelper.resetData(gvUser, dt);
    }

    //绑定用户卡下单按钮的链接
    protected void gvResultUseCard1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "applyOrder")
        {
            string cardSurFaceCode = e.CommandArgument.ToString().Split(';')[0].ToString().Split(':')[0].ToString();
            string cardSampleCode = e.CommandArgument.ToString().Split(';')[1].ToString();
            Response.Redirect("RM_ApplyOrder.aspx?surFaceCode=" + cardSurFaceCode + "&sampleCode=" + cardSampleCode);
        }
        else if (e.CommandName == "surFaceCode")
        {
            string cardSurFaceCode = e.CommandArgument.ToString().Split(':')[0].ToString();
            DataTable dt = ResourceManageHelper.callQuery(context, "GETCARDSAMPLECODE", cardSurFaceCode);
            if (dt == null || dt.Rows.Count == 0)
            {
                context.AddError("A094780003:该卡面没有卡样");
                return;
            }
            if (string.IsNullOrEmpty(dt.Rows[0][0].ToString()))
            {
                context.AddError("A094780003:该卡面没有卡样");
                return;
            }
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "cw", "CreateWindow('RoleWindow','RM_ShowPicture.aspx?surFaceCode=" + dt.Rows[0][0].ToString() + "');", true);

        }
    }

     

    /// <summary>
    /// 加载是否显示右边网点剩余数量
    /// </summary>
    private void ondisplay()
    {
        //if (selSellType.SelectedValue == "01")  //选择出库的时候加载事件
        //{
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "javascript", "gvOnSelected();", true);
        //}
        //else
        //{
        //    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "javascript", "gvUnSelected();", true);
        //}
    }

}