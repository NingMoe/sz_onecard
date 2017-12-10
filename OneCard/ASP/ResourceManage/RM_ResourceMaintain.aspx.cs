using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PrivilegePR;
using TDO.UserManager;
using TM;
/***************************************************************
 * 功能名: 其他资源管理  资源维护审批
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/13    董翔			初次开发
 ****************************************************************/

public partial class ASP_ResourceManage_RM_ResourceMaintain : Master.ExportMaster 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            init_Page();
            if (!HasOperPower("201008"))     //非网点主管不可以审核、作废
            {
                context.AddError("用户没有操作权限,请联系管理员");
                btnSubmit.Enabled = false;
                Button1.Enabled = false;
                return;
            }
        }
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);

        //初始化本部门员工
        string[] parm = new string[1];
        parm[0] = context.s_DepartID;//本部门ID
        OtherResourceManagerHelper.selectStaff(context, ddlStaffQuery, true, parm);//加载本部门员工

        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");


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
        gvResult.DataSource = queryResourceOrder();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
        //GridView gv = gvResult;
        //foreach (GridViewRow gvr in gv.Rows)
        //{
        //    DropDownList dl = (DropDownList)gvr.FindControl("ddlStaff");
        //    string[] parm = new string[1];
        //    parm[0] = context.s_DepartID;//本部门ID
        //    OtherResourceManagerHelper.selectStaff(context, dl, true, parm);//加载本部门员工
        //}
    }

    /// <summary>
    /// 查询资源维护单（查询本部门的）
    /// </summary>
    /// <returns></returns>
    protected ICollection queryResourceOrder()
    {
        string[] parm = new string[8];
        parm[0] = ddlResourceType.SelectedValue;
        parm[1] = ddlResource.SelectedValue;
        parm[2] = selExamState.SelectedValue;
        parm[3] = context.s_DepartID;  //下单员工部门ID
        parm[4] = txtFromDate.Text.Trim();
        parm[5] = txtToDate.Text.Trim();
        parm[6] = ddlStaffQuery.SelectedValue;
        parm[7] = txtMaintainOrderID.Text.Trim();
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_ResourceMaintain", parm);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }


    /// <summary>
    /// 提交验证
    /// </summary>
    private bool submitValidation(int number)
    {
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                TextBox txt = (TextBox)gvResult.Rows[index].FindControl("txtCheckNote");
                if (Validation.strLen(txt.Text.Trim()) > 255)
                {
                    context.AddError("A001003401:审核说明长度不能超过255位", txt);
                    return false;
                }
                if (number == 1)//只有通过操作时需选择维护员工
                {
                    DropDownList dl = (DropDownList)gvResult.Rows[index].FindControl("ddlStaff");
                    if (dl.SelectedIndex < 1)
                    {
                        context.AddError("A001003402:维护员工不可为空", dl);
                        return false;
                    }
                }
            }

        }
        return true;
    }

    /// <summary>
    /// 审核通过按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation(1))
            return;

        //选择的记录入临时表
        if (!RecordIntoTmp()) return;

        //属性插入临时表中
        context.SPOpen();
        context.AddField("P_SESSION").Value = Session.SessionID;
        //调用下单申请存储过程
        bool ok = context.ExecuteSP("SP_RM_ResourceMaintainPass");
        if (ok)
        {
            AddMessage("审核通过成功");
            //循环将选中行入临时表
            foreach (GridViewRow gvr in gvResult.Rows)
            {
                CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    DropDownList ddl = (DropDownList)gvr.FindControl("ddlStaff");
                    string ddlStaff = ddl.SelectedItem.Text.Split(':')[1];
                    //发送信息
                    SP_PR_SendMsgPDO pdo = new SP_PR_SendMsgPDO();
                    pdo.msgtitle = "资源维护申请已受理";
                    pdo.msgbody = "你录的资源维护申请单已经安排[" + ddlStaff + "]前去维护处理，请及时跟进，有任何问题请电话联系。";
                    pdo.msglevel = 0;
                    pdo.depts = "";
                    pdo.roles = "";
                    pdo.staffs = gvr.Cells[8].Text.Trim().Split(':')[0];
                    pdo.msgpos = 1;
                    PDOBase pdoOut;
                    TMStorePModule.Excute(context, pdo, out pdoOut);
                }
            }
          
            btnQuery_Click(sender, e);

        }
    }

    /// <summary>
    /// 审核不通过按钮点击事件
    /// </summary>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation(2))
            return;

        //选择的记录入临时表
        if (!RecordIntoTmp()) return;

        //属性插入临时表中
        context.SPOpen();
        context.AddField("P_SESSION").Value = Session.SessionID;
        //调用下单申请存储过程
        bool ok = context.ExecuteSP("SP_RM_ResourceMaintainCancel");
        if (ok)
        {
            AddMessage("审核作废成功");
            gvResult.DataSource = queryResourceOrder();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;
        }
    }

    /// <summary>
    /// 选中的记录入临时表
    /// </summary>
    /// <returns>入临时表成功返回true，否则返回false</returns>
    private bool RecordIntoTmp()
    {
        //清空临时表
        clearTempTable();

        //记录入临时表
        context.DBOpen("Insert");
        GridView gv = gvResult;
        int count = 0;
        //循环将选中行入临时表
        foreach (GridViewRow gvr in gv.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                TextBox txt = (TextBox)gvr.FindControl("txtCheckNote");
                DropDownList ddl = (DropDownList)gvr.FindControl("ddlStaff");
                string ddlStaff = ddl.SelectedValue;
                string checkNote = txt.Text.Trim();
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1,f2,f3,f4) values('" +
                        gvr.Cells[1].Text + "', '" + Session.SessionID + "', '" + gvr.Cells[4].Text.Split(':')[0] + "','" + checkNote + "','" + ddlStaff + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("没有选中任何行");
            return false;
        }
        return true;
    }

    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1= '"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    //判断是否有指定权限
    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            for (int index = 0; index < gvResult.Rows.Count; index++)
            {
                DropDownList dl = (DropDownList)gvResult.Rows[index].FindControl("ddlStaff");
                dl.Items.Clear();
                string[] parm = new string[1];
                parm[0] = context.s_DepartID;//本部门ID
                OtherResourceManagerHelper.selectStaff(context, dl, true, parm);//加载本部门员工
                HiddenField id = (HiddenField)gvResult.Rows[index].FindControl("staffId");
                if (id.Value.Equals(""))
                {
                    dl.SelectedIndex = 0;
                }
                else
                {
                    dl.SelectedValue = id.Value;
                }
            }
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        ExportGridView(gvResult);
    }
}