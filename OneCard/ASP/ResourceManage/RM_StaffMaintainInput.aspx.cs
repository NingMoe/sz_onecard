using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_ResourceManage_RM_StaffMaintainInput :  Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化页面
            init_Page();
            //指定工单GridView DataKeyNames
            gvResult.DataKeyNames = new string[] { "SIGNINMAINTAINID", "RESUOURCETYPE", "RESOURCENAME", "USETIME", "EXPLANATION", "RELATEDSTATE", "MAINTAINDEPT" };
            
        }
        
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult2.DataSource = new DataTable();
        gvResult2.DataBind();
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
        txtStartDate2.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate2.Text = DateTime.Today.ToString("yyyyMMdd");

        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, selResourceType, true);

        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, InResourceType, true);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, selResourceName, true, selResourceType.SelectedValue);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, InResourceName, true, InResourceType.SelectedValue);

        //初始化网点
        OtherResourceManagerHelper.selectDepartment(context, selDept, true);
        //selDept.SelectedValue = context.s_DepartID;

        //初始化维护员工
        bindStaffName(selStaff);
        //初始化维护网点
        OtherResourceManagerHelper.selectDepartment(context, ddlDept, true);


    }
    private void bindStaffName(DropDownList ddlStaff)
    {
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_MaintainStaff");
        ddlStaff.Items.Add(new ListItem("---请选择---", ""));
        if (data.Rows.Count > 0)
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
    protected void selResourceType_change(object sender, EventArgs e)
    {
        selResourceName.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, selResourceName, true, selResourceType.SelectedValue);
    }
    //填写需求单处资源类型改变时
    protected void InResourceType_change(object sender, EventArgs e)
    {
        InResourceName.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, InResourceName, true, InResourceType.SelectedValue);
        if (InResourceType.SelectedValue == "")
        {
            InResourceName.Enabled = false;
        }
        else
        {
            InResourceName.Enabled = true;
        }
    }
    /// <summary>
    /// 查询工单事件
    /// </summary>
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
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_StaffMaintainInput",txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selDept.SelectedValue,
            selResourceType.SelectedValue, selResourceName.SelectedValue,ddlState.SelectedValue);
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
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation2()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate2, txtEndDate2, "A095470102", "A095470103", "A095470104");
        return !context.hasError();
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

    
    /// <summary>
    /// 查询签到单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery2_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation2())
            return;

        gvResult2.DataSource = queryStaffSignIn();
        gvResult2.DataBind();
    }
    //查询签到单记录
    protected DataTable queryStaffSignIn()
    {
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_StaffSignIn", txtStartDate2.Text.Trim(), txtEndDate2.Text.Trim(),ddlState2.SelectedValue,selStaff.SelectedValue);
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return data;
    }

    /// <summary>
    /// 新增工单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_RESUOURCETYPECODE").Value = InResourceType.SelectedValue;//资源类型
        context.AddField("P_RESOURCECODE").Value = InResourceName.Text.Trim();//资源名称
        context.AddField("P_EXPLANATION").Value = txtExplanation.Text.Trim();//故障情况说明
        context.AddField("P_USETIME").Value = txtTime.Text.Trim();//维护时长
        context.AddField("P_MAINTAINDEPT").Value = ddlDept.SelectedValue;//维护网点
        bool ok = context.ExecuteSP("SP_RM_OTHER_ADDSTAFFMAINTAIN");
        if (ok)
        {
            AddMessage("新增工单成功");
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

        //对资源类型校验

        if (InResourceType.SelectedValue == string.Empty)
        {
            context.AddError("A001002103：请选择资源类型", InResourceType);
        }
        //对资源名称校验

        if (InResourceName.SelectedValue == string.Empty)
        {
            context.AddError("A001002104：请选择资源名称", InResourceName);
        }

        //故障说明校验
        if (string.IsNullOrEmpty(txtExplanation.Text.Trim()))
        {
            context.AddError("A094780205：故障说明不能为空", txtExplanation);
        }
        else if (Validation.strLen(txtExplanation.Text.Trim()) > 600)
        {
            context.AddError("A094780206：故障说明长度不能超过600位", txtExplanation);
        }

        //维护时长
        if (string.IsNullOrEmpty(txtTime.Text.Trim()))
        {
            context.AddError("A094780207：维护时长不能为空", txtTime);
        }
        else if (!Validation.isPosRealNum(txtTime.Text.Trim()))
        {
            context.AddError("A094780208：维护时长必须是半角正实数（可有1位小数）", txtTime);
        }
        //维护网点
        if (ddlDept.SelectedValue == string.Empty)
        {
            context.AddError("A094780209：请选择维护网点", InResourceName);
        }
        return !context.hasError();
    }
    /// <summary>
    /// 修改工单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("未选中数据行");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_SIGNINMAINTAINID").Value = getDataKeys("SIGNINMAINTAINID");//工单号
        context.AddField("P_RESUOURCETYPECODE").Value = InResourceType.Text.Trim();//资源类型
        context.AddField("P_RESOURCECODE").Value = InResourceName.Text.Trim();//资源名称
        context.AddField("P_EXPLANATION").Value = txtExplanation.Text.Trim();//故障情况说明
        context.AddField("P_USETIME").Value = txtTime.Text.Trim();//维护时长
        context.AddField("P_MAINTAINDEPT").Value = ddlDept.SelectedValue;//维护网点
        bool ok = context.ExecuteSP("SP_RM_OTHER_EDITSTAFFMAINTAIN");
        if (ok)
        {
            AddMessage("修改工单成功");
            gvResult.DataSource = queryStaffMaintain();
            gvResult.DataBind();
        }
    }
    
    private Boolean isPosRealNum(String strInput)
    {
        System.Text.RegularExpressions.Regex reg1
                    = new System.Text.RegularExpressions.Regex(@"^[0-9]+(.[0-9]{1})?$");
        return reg1.IsMatch(strInput);
    }
    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        InResourceType.SelectedValue = getDataKeys("RESUOURCETYPE").Substring(0,2);
        InResourceName.SelectedValue = getDataKeys("RESOURCENAME").Substring(0, 6); ;
        txtExplanation.Text = getDataKeys("EXPLANATION");
        txtTime.Text = getDataKeys("USETIME").Substring(0,getDataKeys("USETIME").Length-2);
        ddlDept.SelectedValue = getDataKeys("MAINTAINDEPT").Substring(0, 4);
    }
    public string getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
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
    /// 关联签到单事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRelation_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("P_SIGNINMAINTAINID").Value = getDataKeys("SIGNINMAINTAINID");//工单号
        context.AddField("p_SESSIONID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_RM_OTHER_RELATESTAFF");
        if (ok)
        {
            AddMessage("关联签到单成功");
        }
        //清空临时表


        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
        btnQuery2_Click(sender, e);
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {
        int count = 0;
        for (int index = 0; index < gvResult2.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult2.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
            }

        }
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中签到单");
        }
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("未选中工单数据行");
            return;
        }
    }
    private void FillTempTable(string sessionID)
    {

        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < gvResult2.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult2.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string signsheetid = gvResult2.Rows[index].Cells[1].Text.Trim();//签到单号

                //F0:签到单号，F1：SessionID
                context.ExecuteNonQuery(@"insert into TMP_COMMON (f0,f1)
                                values('" + signsheetid + "','" + sessionID + "')");
            }
        }
        context.DBCommit();

    }
    private void clearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON");
        context.DBCommit();
    }   
}