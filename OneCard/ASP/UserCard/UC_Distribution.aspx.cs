using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using TDO.UserManager;
using System.Text;
using PDO.UserCard;
using Master;
using PDO.PersonalBusiness;

// 用户卡分配处理
public partial class ASP_UserCard_UC_Distribution : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 建立临时表
        UserCardHelper.createTempTable(context);

        // 初始化操作类型
        selCardState.Items.Add(new ListItem("01:分配", "01"));
        selCardState.Items.Add(new ListItem("05:取消分配", "05"));

        // 初始化分配员工
        UserCardHelper.selectDistStaff(context, selAssignee, false);
        UserCardHelper.selectDistStaff(context, selAssignedStaff, false);

        UserCardHelper.resetData(gvResult, null);
    }

    // 输入项判断处理
    private void InputValidate()
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, false);

        if (selCardState.SelectedValue != "01") // 取消分配
        {
            UserCardHelper.validateDate(context, txtDistDate, false, "", "A002P03009: 分配日期格式必须是yyyyMMdd形式");
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtFromCardNo.Text;
        bool smkFromCard = TMStorePModule.Excute(context, smkpdo);

        smkpdo.CARDNO = txtToCardNo.Text;
        bool smkToCard = TMStorePModule.Excute(context, smkpdo);
        if (smkFromCard == false || smkToCard == false)
        {
            return;
        }

        InputValidate();
        if (context.hasError()) return;

        // 查询用户卡资料表
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
        pdo.funcCode = "CardQuery";
        pdo.var1 = txtFromCardNo.Text.Trim();
        pdo.var2 = txtToCardNo.Text.Trim();

        if (selCardState.SelectedValue == "01") // 分配
        {
            pdo.var3 = "01";
            // 添加分配的约束条件(分配员工、部门以及卡片状态）
            pdo.var4 = context.s_UserID;
            pdo.var5 = context.s_DepartID;
        }
        else // 取消分配
        {
            pdo.var3 = "02";
            pdo.var4 = txtDistDate.Text.Trim();
            pdo.var5 = selAssignee.SelectedValue;
            pdo.var6 = context.s_UserID;
        }

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        btnSubmit.Enabled = data.Rows.Count > 0;

        UserCardHelper.resetData(gvResult, data);
    }

    // 选中当前页所有用户卡
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    // gridview分页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 清空卡号列表临时表
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_UC_CardNoList where SessionId='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 首先清空临时表
        clearTempTable();

        context.DBOpen("Insert");

        // 根据页面卡号选中生成临时表数据
        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_UC_CardNoList values('" 
                    + Session.SessionID + "','" + gvr.Cells[1].Text + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A002P03R01: 没有选中任何行");
            return;
        }

        if (selCardState.SelectedValue == "01") // 分配
        {
            // 调用分配存储过程
            SP_UC_DistributionPDO pdo = new SP_UC_DistributionPDO();
            pdo.sessionId = Session.SessionID;
            pdo.assignedStaff = selAssignedStaff.SelectedValue;
            bool ok = TMStorePModule.Excute(context, pdo);

            if(ok) AddMessage("D002P03001: 分配成功");
        }
        else // 取消分配
        {
            // 调用取消分配存储过程
            SP_UC_UnDistributionPDO pdo = new SP_UC_UnDistributionPDO();
            pdo.sessionId = Session.SessionID;
            bool ok = TMStorePModule.Excute(context, pdo);

            if(ok) AddMessage("D002P03002: 取消分配成功");
       }

       clearTempTable();
       UserCardHelper.resetData(gvResult, null);
   }


    // 选择“操作类型”
    protected void selCardState_SelectedIndexChanged(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        bool dist = selCardState.SelectedValue == "01";

        txtDistDate.Enabled = !dist;
        selAssignee.Enabled = !dist;

        selAssignedStaff.Enabled = dist;
    }
}
