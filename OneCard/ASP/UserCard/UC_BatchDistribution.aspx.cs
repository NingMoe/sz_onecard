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
using TM;
using TDO.UserManager;
using Common;
using TDO.BalanceChannel;
using PDO.UserCard;
using PDO.PersonalBusiness;

// 用户卡批量分配处理
public partial class ASP_UserCard_UC_BatchDistribution : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 初始化操作类型
        selCardState.Items.Add(new ListItem("01:批量分配", "01"));
        selCardState.Items.Add(new ListItem("05:取消分配", "05"));

        // 初始化分配员工
        UserCardHelper.selectDistStaff(context, selStaffNo, false);

        // 初始化银行列表
        UserCardHelper.selectBank(context, selBankNo, false);
    }

    // 提交前的输入校验
    private void SubmitValidate()
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
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

        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        if (selCardState.SelectedValue == "01") // 批量分配
        {
            // 调用批量分配存储过程
            SP_UC_BatchDistributionPDO pdo = new SP_UC_BatchDistributionPDO();
            pdo.fromCardNo = txtFromCardNo.Text;
            pdo.toCardNo = txtToCardNo.Text;
            pdo.distType = rbStaff.Checked ? 0 : 1;
            pdo.assignee = rbStaff.Checked ? selStaffNo.SelectedValue : selBankNo.SelectedValue;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok) AddMessage("D002P04001: 批量分配成功");
        }
        else
        {
            // 调用取消批量分配存储过程
            SP_UC_BatchUnDistributionPDO pdo = new SP_UC_BatchUnDistributionPDO();
            pdo.fromCardNo = txtFromCardNo.Text;
            pdo.toCardNo = txtToCardNo.Text;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok) AddMessage("D002P04002: 取消批量分配成功");
        }
    }

    // 操作类型更改事件
    protected void selCardState_SelectedIndexChanged(object sender, EventArgs e)
    {
        bool dist = selCardState.SelectedValue == "01";
        selStaffNo.Enabled = dist;
        selBankNo.Enabled = dist;
        rbStaff.Enabled = dist;
        rbBank.Enabled = dist;
    }
}
