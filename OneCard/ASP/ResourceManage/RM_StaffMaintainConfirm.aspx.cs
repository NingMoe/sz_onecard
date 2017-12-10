using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_ResourceManage_RM_StaffMaintainConfirm : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化页面
            init_Page();
            //指定工单GridView DataKeyNames
            gvResult.DataKeyNames = new string[] { "SIGNINMAINTAINID", "RESOURCENAME", "USETIME", "EXPLANATION", "ISFINISHED", "SATISFATION", "CONFIRMATION", "CONFIRMID" };

        }
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
        string sql = "select * from td_m_insidestaffrole where staffno = '" + context.s_UserID + "'and roleno='0001'";
        context.DBOpen("Select");
        DataTable dt = context.ExecuteReader(sql);
        if (dt.Rows.Count > 0)  //当前操作员有管理员权限，可以查看所有维护网点的工单
        {
            //初始化维护网点
            OtherResourceManagerHelper.selectDepartment(context, selDept, true);
        }
        else
        {
            selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
        }
        
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
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");
        return !context.hasError();
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
        DataTable data = data = OtherResourceManagerHelper.callOtherQuery(context, "Query_StaffMaintain", txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selDept.SelectedValue,
           ddlIfFinish.SelectedValue, ddlState.SelectedValue);        
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return data;
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
    public string getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("未选中数据行");
            return;
        }
        if (getDataKeys("CONFIRMID").Equals(string.Empty))
        {
            context.AddError("此维护单未确认,不可修改确认信息");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        string t = getDataKeys("CONFIRMID");//确认单号
        context.AddField("P_CONFIRMID").Value = t;//确认单号
        context.AddField("P_ISFINISHED").Value = ddlInFinish.SelectedValue;//完成情况
        context.AddField("P_SATISFATION").Value = ddlSatisfy.Text.Trim();//满意度
        context.AddField("P_CONFIRMATION").Value = txtExplanation.Text.Trim();//确认说明
        bool ok = context.ExecuteSP("SP_RM_OTHER_EDITSTAFFCONFIRM");
        if (ok)
        {
            AddMessage("修改工单确认信息成功");
            gvResult.DataSource = queryStaffMaintain();
            gvResult.DataBind();
        }
    }
    protected void btnbtnAdd_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("未选中数据行");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_SIGNINMAINTAINID").Value = getDataKeys("SIGNINMAINTAINID");//维护单号
        context.AddField("P_ISFINISHED").Value = ddlInFinish.SelectedValue;//完成情况
        context.AddField("P_SATISFATION").Value = ddlSatisfy.Text.Trim();//满意度
        context.AddField("P_CONFIRMATION").Value = txtExplanation.Text.Trim();//确认说明
        bool ok = context.ExecuteSP("SP_RM_OTHER_ADDSTAFFCONFIRM");
        if (ok)
        {
            AddMessage("工单确认成功");
            gvResult.DataSource = queryStaffMaintain();
            gvResult.DataBind();
        }
    }
    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);

        //对完成情况校验

        if (ddlInFinish.SelectedValue == string.Empty)
        {
            context.AddError("A001002103：请选择完成情况", ddlInFinish);
        }
        //对满意度校验

        if (ddlSatisfy.SelectedValue == string.Empty)
        {
            context.AddError("A001002104：请选择满意度", ddlSatisfy);
        }

        //确认说明校验
        if (Validation.strLen(txtExplanation.Text.Trim()) > 600)
        {
            context.AddError("A094780206：确认说明长度不能超过600位", txtExplanation);
        }

        return !context.hasError();
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlInFinish.SelectedValue = (getDataKeys("ISFINISHED").Equals(string.Empty))?"":getDataKeys("ISFINISHED").Substring(0,1);
        ddlSatisfy.SelectedValue = (getDataKeys("SATISFATION").Equals(string.Empty)) ? "" : getDataKeys("SATISFATION").Substring(0, 1);
        txtExplanation.Text = getDataKeys("CONFIRMATION");
    }
}