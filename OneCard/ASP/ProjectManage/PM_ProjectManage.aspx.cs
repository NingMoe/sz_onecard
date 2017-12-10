using System;
using System.Data;
using System.Web.UI.WebControls;
using Common;
/***************************************************************
 * 功能名: 项目管理  项目管理
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/18    董翔			初次开发
 ****************************************************************/

public partial class ASP_ProjectManage_PM_ProjectManage : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        showNonDataGridView();
    }

    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, selStartDate, selEndDate, "A095470102", "A095470103", "A095470104");
        return !context.hasError();
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;

        DataTable data = QuerySource();
        ResourceManageHelper.resetData(gvResult, data);
    }


    private DataTable QuerySource()
    {
        string[] parm = new string[3];
        parm[0] = selStartDate.Text;
        parm[1] = selEndDate.Text;
        parm[2] = txtSelProjectName.Text.Trim();
        DataTable data = SPHelper.callQuery("SP_PM_Query", context, "Query_Project", parm);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        return data;
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            if (e.Row.Cells[2].Text != "&nbsp;" && e.Row.Cells[2].Text != "")
            {
                e.Row.Cells[2].Text = Convert.ToDateTime(e.Row.Cells[2].Text).ToString("yyyy-MM-dd");
            }
        }
    }

    /// <summary>
    /// 添加项目
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("P_PROJECTNAME").Value = txtPROJECTNAME.Text.Trim();
        context.AddField("P_STARTDATE").Value = txtSTARTDATE.Text.Trim();
        context.AddField("P_PROJECTDESC").Value = txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_PM_ADDPROJECT");
        if (ok)
        {
            AddMessage("项目添加成功");
            gvResult.DataSource = QuerySource();
            gvResult.DataBind();
        }

    }

    /// <summary>
    /// 修改
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        context.AddField("P_PROJECTNAME").Value = txtPROJECTNAME.Text.Trim();
        context.AddField("P_STARTDATE").Value = txtSTARTDATE.Text.Trim();
        context.AddField("P_PROJECTDESC").Value = txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_PM_EDITPROJECT");
        if (ok)
        {
            AddMessage("项目修改成功");
            gvResult.DataSource = QuerySource();
            gvResult.DataBind();
        }

    }

    /// <summary>
    /// 删除
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }

        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        bool ok = context.ExecuteSP("SP_PM_DELETEPROJECT");
        if (ok)
        {
            AddMessage("项目删除成功");

            btnQuery_Click(sender, e);

        }
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            try
            {
                txtPROJECTNAME.Text = row.Cells[1].Text.ToString().Trim();
                txtSTARTDATE.Text = row.Cells[2].Text.ToString().Trim().Replace("-", "");
                txtRemark.Text = row.Cells[3].Text.ToString().Trim().Replace("&nbsp;", "");
                hidePROJECTCODE.Value = row.Cells[0].Text.ToString().Trim();
            }
            catch
            {
            }
        }
    }

    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        //项目名称校验
        if (string.IsNullOrEmpty(txtPROJECTNAME.Text.Trim()))
        {
            context.AddError("A094780190：项目名称不能为空", txtPROJECTNAME);
        }
        else if (Validation.strLen(txtPROJECTNAME.Text.Trim()) > 50)
        {
            context.AddError("A094780190：项目名称长度不能超过50位", txtPROJECTNAME);
        }

        //项目描述
        if (Validation.strLen(txtRemark.Text.Trim()) > 250)
        {
            context.AddError("A094780189：项目描述长度不能超过250位", txtRemark);
        }

        //开始日期
        if (string.IsNullOrEmpty(txtSTARTDATE.Text.Trim()))
        {
            context.AddError("A094780188：开始日期不能为空", txtSTARTDATE);
        }
        else if (!Validation.isDate(txtSTARTDATE.Text.Trim(), "yyyyMMdd"))
        {
            context.AddError("A094780187：开始日期格式错误", txtSTARTDATE);
        }
        return !context.hasError();
    }

}