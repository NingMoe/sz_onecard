using System;
using System.Collections;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.PrivilegePR;
using Master;
using TM;
using Common;

/***************************************************************
 * 功能名: 系统管理_admin页面登陆限制
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/09/28    liuhe			初次开发
 ****************************************************************/
public partial class ASP_PrivilegePR_PR_StaffLoginAdminConfig : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            UserCardHelper.selectDepts(context, selDepartName, true);

            UserCardHelper.selectAllStaffs(context, selStaffName, selDepartName, true);

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

        }
        return;
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        pdo.funcCode = "QueryLogonAdminpageConfig";

        pdo.var1 = selConfigtype.SelectedValue;
        pdo.var2 = selDepartName.SelectedValue;
        pdo.var3 = selStaffName.SelectedValue;

        StoreProScene sp = new StoreProScene();
        DataTable dt = sp.Execute(context, pdo);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, dt);


        if (selConfigtype.SelectedValue == "0")      
        {
            btnAdd.Enabled = false;
            btnDel.Enabled = true;
        }
        else if (selConfigtype.SelectedValue == "1") 
        {
            btnAdd.Enabled = true;
            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 添加限制按钮事件（添加限制则从配置表删除）
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        string session = Session.SessionID;

        FillToTmpCommon(session, "1");
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = session;
        bool ok = context.ExecuteSP("SP_PR_AdminPageConfig");
        if (ok)
        {
            AddMessage("提交成功");
            SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
            pdo.funcCode = "QueryLogonAdminpageConfig";

            pdo.var1 = selConfigtype.SelectedValue;
            pdo.var2 = selDepartName.SelectedValue;
            pdo.var3 = selStaffName.SelectedValue;

            StoreProScene sp = new StoreProScene();
            DataTable dt = sp.Execute(context, pdo);
            UserCardHelper.resetData(gvResult, dt); ;
        }
    }

    /// <summary>
    /// 取消限制按钮事件（取消限制则添加到配置表）
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        string session = Session.SessionID;

        FillToTmpCommon(session, "0");
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = session;
        bool ok = context.ExecuteSP("SP_PR_AdminPageConfig");
        if (ok)
        {
            AddMessage("提交成功");
            SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
            pdo.funcCode = "QueryLogonAdminpageConfig";

            pdo.var1 = selConfigtype.SelectedValue;
            pdo.var2 = selDepartName.SelectedValue;
            pdo.var3 = selStaffName.SelectedValue;

            StoreProScene sp = new StoreProScene();
            DataTable dt = sp.Execute(context, pdo);
            UserCardHelper.resetData(gvResult, dt); ;
        }

        
    }

    /// <summary>
    /// 向临时表添加gv选中行
    /// </summary>
    /// <param name="session">当前会话</param>
    /// <param name="warnType">是否需要过滤 0：添加 1：删除</param>
    public void FillToTmpCommon(string session, string opType)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + session + "'");

        // 根据页面数据生成临时表数据
        int count = 0;
        string staffNo = "";
        string departNo = "";
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                staffNo = gvResult.Rows[index].Cells[1].Text.Split(':')[0].ToString();
                departNo = gvResult.Rows[index].Cells[2].Text.Split(':')[0].ToString();
                context.ExecuteNonQuery(@"insert into tmp_common(F0,F1,F2,F3) values('" + session + "','" + staffNo + "','" + departNo + "','" + opType + "')");
            }
        }
        context.DBCommit();
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }

    }

    /// <summary>
    /// 部门下来框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selDepartName_SelectedIndexChanged(object sender, EventArgs e)
    {
        UserCardHelper.selectStaffs(context, selStaffName, selDepartName, true);
    }

    /// <summary>
    /// 选中gridview当前页所有数据
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
}
