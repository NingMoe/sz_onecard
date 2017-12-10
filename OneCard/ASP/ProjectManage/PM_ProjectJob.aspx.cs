using System;
using System.Data;
using System.Web.UI.WebControls;
using Master;
using Common;
/***************************************************************
 * 功能名: 项目管理  项目完成情况
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/19    董翔			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_PM_ProjectJob : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        DataTable data = QuerySource();
        ResourceManageHelper.resetData(gvResult, data);
    }

    private DataTable QuerySource()
    {
        string[] parm = new string[1];
        parm[0] = context.s_UserID;
        DataTable data = SPHelper.callQuery("SP_PM_Query", context, "Query_ProjectJobList", parm);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        return data;
    }

    private void ClearPage()
    {
        txtPROJECTNAME.Text = "";
        txtJOBDESC.Text = "";
        txtEXPECTEDDATE.Text = "";
        txtJOBDESC.Text = "";
        txtACTUALDATE.Text = "";
        txtCOMPLETEDESC.Text = "";
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[1].Text != "&nbsp;" && e.Row.Cells[1].Text != "")
            {
                e.Row.Cells[1].Text = Convert.ToDateTime(e.Row.Cells[1].Text).ToString("yyyy-MM-dd");
            }
            if (e.Row.Cells[4].Text != "&nbsp;" && e.Row.Cells[4].Text != "")
            {
                e.Row.Cells[4].Text = Convert.ToDateTime(e.Row.Cells[4].Text).ToString("yyyy-MM-dd");
            }
        }
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[5].Visible = false;
            e.Row.Cells[6].Visible = false;
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
            ClearPage();
            hidePROJECTCODE.Value = row.Cells[5].Text.ToString().Trim();
            hideJOBCODE.Value = row.Cells[6].Text.ToString().Trim();
            txtPROJECTNAME.Text = row.Cells[0].Text.ToString().Trim();
            txtJOBDESC.Text = row.Cells[3].Text.ToString().Trim();
            txtEXPECTEDDATE.Text = row.Cells[4].Text.ToString().Trim();
        }
    }

    /// <summary>
    /// 完成计划
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        context.AddField("P_JOBCODE").Value = hideJOBCODE.Value.Trim();
        context.AddField("P_COMPLETEDESC").Value = txtCOMPLETEDESC.Text.Trim();
        context.AddField("P_ACTUALDATE").Value = txtACTUALDATE.Text.Trim();
        bool ok = context.ExecuteSP("SP_PM_ProjectJob");
        if (ok)
        {
            AddMessage("项目计划完成成功");
            DataTable data = QuerySource();
            ResourceManageHelper.resetData(gvResult, data);
        }
    }

    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        //完成情况描述
        if (Validation.strLen(txtCOMPLETEDESC.Text.Trim()) > 500)
        {
            context.AddError("A094780033：完成情况描述长度不能超过255位", txtCOMPLETEDESC);
        }

        //实际完成日期
        if (string.IsNullOrEmpty(txtACTUALDATE.Text.Trim()))
        {
            context.AddError("A094780035：实际完成日期不能为空", txtACTUALDATE);
        }
        else if (!Validation.isDate(txtACTUALDATE.Text.Trim(), "yyyyMMdd"))
        {
            context.AddError("A094780040：实际完成日期格式不正确", txtACTUALDATE);
        }
        else
        {
            DateTime acpDate = DateTime.ParseExact(txtACTUALDATE.Text.Trim(), "yyyyMMdd", null);

            DateTime expDate = DateTime.ParseExact(txtEXPECTEDDATE.Text.Trim(), "yyyy-MM-dd", null);
            TimeSpan ts= acpDate.Subtract(expDate);
            int i = ts.Days;
            if (i > 7 || i < -7)
            {
                context.AddError("A094780040：实际完成日期只能选择预计完成日期前后7天", txtACTUALDATE);
            }

        }
        return !context.hasError();
    }


}