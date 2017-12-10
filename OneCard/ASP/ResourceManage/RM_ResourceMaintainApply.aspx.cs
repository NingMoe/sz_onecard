using System;
using System.Collections;
using System.Data; 
using System.Web.UI; 
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PrivilegePR;
using TM;
/***************************************************************
 * 功能名: 其他资源管理  资源维护申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/12   董翔			初次开发
 * 2013/1/5     尤悦            修改
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ResourceMaintainApply : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            init_Page();
        }
            Panel1.Visible = false;
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType2, true);
        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType2.SelectedValue);
        //初始化申请部门
        OtherResourceManagerHelper.selectDepartment(context, selDept, true);
        //初始化维护部门(默认值：技术组)
        OtherResourceManagerHelper.selectDepartment(context, ddlMaintainDepart, true);
        ddlMaintainDepart.SelectedValue = "0003";
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    //查询事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ResourceManageHelper.checkDate(context, txtFromDate, txtToDate, "开始日期范围起始值格式必须为yyyyMMdd",
           "结束日期范围终止值格式必须为yyyyMMdd", "开始日期不能大于结束日期");
        if (context.hasError())
        {
            return;
        }
        gvResult.DataSource = QueryGetMaintainApply();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    //查询资源名称
    protected void ddlResourceType2_SelectIndexChange(object sender, EventArgs e)
    {
        ddlResource.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType2.SelectedValue);
        if (ddlResourceType2.SelectedValue == "")
        {
            ddlResource.Enabled = false;
        }
        else
        {
            ddlResource.Enabled = true;
        }
    }

    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean submitValidation()
    {
        //资源类型
        if (ddlResourceType2.SelectedValue == "")
        {
            context.AddError("资源类型不能为空", ddlResourceType2);
        }
        //资源名称
        if (ddlResource.SelectedValue == "")
        {
            context.AddError("资源名称不能为空", ddlResource);
        }

        //申请原因
        if (string.IsNullOrEmpty(txtMaintainReason.Text.Trim()))
        {
            context.AddError("申请原因不能为空", txtMaintainReason);
        }
        else if (Validation.strLen(txtMaintainReason.Text.Trim()) > 255)
            context.AddError("申请原因长度不能大于255", txtMaintainReason);

        //备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()) && Validation.strLen(txtRemark.Text.Trim()) > 255)
        {
            context.AddError("备注长度不能大于255", txtRemark);
        }
        //维护部门
        if(ddlMaintainDepart.SelectedValue=="")
        {
            context.AddError("维护部门不能为空", ddlMaintainDepart);
        }
        //维护要求
        if (!string.IsNullOrEmpty(txtMaintainRequest.Text.Trim()) && Validation.strLen(txtMaintainRequest.Text.Trim()) > 255)
        {
            context.AddError("维护要求长度不能大于255", txtMaintainRequest);
        }
        //维护期限
        if(string.IsNullOrEmpty(txtTimeLimit.Text.Trim()))
        {
            context.AddError("维护期限不能为空", txtTimeLimit);
        }
        else 
        {
            Validation valid = new Validation(context);
            DateTime? timeLimit = null;
            timeLimit = valid.beDate(txtTimeLimit, "维护期限格式必须为yyyyMMdd");
        }
        return !context.hasError();
    }

    /// <summary>
    /// 申请按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation())
            return;

        //属性插入临时表中
        context.SPOpen();
        context.AddField("P_RESOURCECODE").Value = ddlResource.SelectedValue;
        context.AddField("P_MAINTAINREASON").Value = txtMaintainReason.Text.Trim();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
        context.AddField("P_MAINTAINDEPT").Value =ddlMaintainDepart.SelectedValue ;
        context.AddField("P_MAINTAINREQUEST").Value = txtMaintainRequest.Text.Trim();
        context.AddField("P_TIMELIMIT").Value = txtTimeLimit.Text.Trim();
        context.AddField("P_TEL").Value = txtTel.Text.Trim();
        //调用下单申请存储过程
        bool ok = context.ExecuteSP("SP_RM_ResourceMaintainApply");
        if (ok)
        {
            AddMessage("申请成功");
            //发送信息
            SP_PR_SendMsgPDO pdo = new SP_PR_SendMsgPDO();
            pdo.msgtitle = "新资源维护申请";
            pdo.msgbody =  "[" + context.s_DepartName + "]网点提交资源维护申请，请及时审核按排人员进行维护";
            pdo.msglevel = 0;
            pdo.depts = "";
            pdo.roles = "X019";
            pdo.staffs = "";
            pdo.msgpos = 1;
            PDOBase pdoOut;
            TMStorePModule.Excute(context, pdo, out pdoOut);
        }
    }


    /// <summary>
    /// 查询维护申请单（查询本部门的）
    /// </summary>
    /// <returns></returns>
    protected ICollection QueryGetMaintainApply()
    {
        string[] parm = new string[6];
        parm[0] = txtFromDate.Text.Trim();
        parm[1] = txtToDate.Text.Trim();
        parm[2] = ddlResourceType.SelectedValue;
        parm[3] = selDept.SelectedValue;
        parm[4] = selExamState.SelectedValue;
        parm[5] = context.s_DepartID;  //下单员工部门ID
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetMaintainApply", parm);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        //显示资源维护单的反馈信息
        GridViewRow dr = ((GridView)(sender)).SelectedRow;
        if (!dr.Cells[9].Text.Trim().Equals("&nbsp;"))
        {
            string[] message = dr.Cells[9].Text.Trim().Split(';');
            string changedmessage="";
            for(int i=0;i<message.Length;i++)
            {
                changedmessage += message[i] +";"+ "<br/>";
            }
            txtMessage.Text = changedmessage.Substring(0,changedmessage.LastIndexOf(';'));
        }
        else
        {
            txtMessage.Text = "";
        }
        if (dr.Cells[1].Text.Trim().Equals("1:审核通过")) //若资源维护单的状态时审核通过的，则显示反馈信息
        {
            Panel1.Visible = true;
            hideValue.Value = "1";
            maintainDate.Text = DateTime.Today.ToString("yyyyMMdd");
        }
        hideMaintainOrderId.Value = dr.Cells[0].Text.Trim();     
    }

    /// <summary>
    /// 反馈信息提交事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnFeedBackSubmit_Click(object sender, EventArgs e)
    {
        ValidInput();
        if (context.hasError())
        {
            Panel1.Visible = true; //显示反馈信息输入框
            return;
        }
        //属性插入临时表中
        context.SPOpen();
        context.AddField("P_MAINTAINORDERID").Value = hideMaintainOrderId.Value;
        string feedback;
        if(txtOther.Text.Trim().Length<1)
        {
            feedback = "维护日期:" + maintainDate.Text.Trim() + "-" + "维护结果：" + ddlResult.SelectedItem.Text + "-" + "实际维护员工：" + txtMaintainStaff.Text + ";";
        }
        else
        {
            feedback = "维护日期:" + maintainDate.Text.Trim() + "-" + "维护结果：" + ddlResult.SelectedItem.Text + "-" + "实际维护员工：" + txtMaintainStaff.Text + "-" + "其他:" + txtOther.Text.Trim() + ";";
         }
        context.AddField("P_FEEDBACK").Value = feedback; //反馈信息(拼接)
        //调用资源维护单反馈信息提交存储过程
        bool ok = context.ExecuteSP("SP_RM_MaintainFeedBack");
        if (ok)
        {
            AddMessage("提交成功");

        }
        gvResult.DataSource = QueryGetMaintainApply();//刷新列表
        gvResult.DataBind();
    }
    //申请校验
    private void ValidInput()
    {
        if (string.IsNullOrEmpty(maintainDate.Text.Trim())) //维护时间必填
            context.AddError("维护日期不能为空", maintainDate);
        else if (!Validation.isDate(maintainDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("维护日期格式必须为yyyyMMdd", maintainDate);
        if(ddlResult.SelectedIndex<1)   //维护结构必填
        {
            context.AddError("维护结果不能为空", ddlResult);
        }
        if (Validation.strLen(txtOther.Text.Trim()) + Validation.strLen(txtMessage.Text.Trim()) > 1000)//反馈信息汇总长度不得大于1000
        {
            context.AddError("反馈信息汇总长度不能超过1000位", txtOther);
        }
        if (string.IsNullOrEmpty(txtMaintainStaff.Text.Trim())) //实际维护员工
            context.AddError("实际维护员工不能为空", txtMaintainStaff);
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }

}