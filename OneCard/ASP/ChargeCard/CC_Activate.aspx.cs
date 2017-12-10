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
using PDO.ChargeCard;

// 充值卡激活/关闭
public partial class ASP_ChargeCard_CC_Activate : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    // 点击“查询/修改”按钮
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (btnQuery.Text == "修改")
        {
            btnQuery.Text = "查询";
            chkActivate.Checked = false;
            chkClose.Checked = false;
            btnSubmit.Enabled = false;
            chkActivate.Enabled = false;
            chkClose.Enabled = false;

            clearReadOnly(txtFromCardNo, txtToCardNo);
            return;
        }

        // 查询处理中间清除页面输入
        clearPageInput();

        // 检查起始卡号和终止卡号的格式（非空、14位、英数）
        long quantity = ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError()) return;

        // 设置数量标签值
        labQuantity.Text = " " + quantity;

        int num = ChargeCardHelper.validateCardSold(context, txtFromCardNo, txtToCardNo);
        if (num > 0) return;

        // 检查充值卡是否都有相同的类型
        bool b = ChargeCardHelper.hasSameTypeValue(context, txtFromCardNo, txtToCardNo);
        if (!b)
        {
            return;
        }
        labCardType.Text = ChargeCardHelper.CardTypeValue(context, txtFromCardNo);
        // 检查卡是否都是出库状态或者是激活状态        // 3-出库 4-激活
        // 首先检查起始卡号和结束卡号中间是出库状态的卡片数量
        int count = ChargeCardHelper.queryCountByState(context, txtFromCardNo, txtToCardNo, "3");
        if (count > 0 )
        {
            // 如果卡片数量大于0并且不等于相减所得数量，则说明不全是出库状态（还存在其他状态）
            if (count != quantity)
            {
                context.AddError("A007P01009: 位于起始卡号和终止卡号之间的充值卡不都是出库状态");
                return;
            }
            labState.Text = "已出库";
            labTotalValue.Text = ChargeCardHelper.queryTotalValue(context, txtFromCardNo, txtToCardNo).ToString("n");

            btnQuery.Text = "修改";
            setReadOnly(txtFromCardNo, txtToCardNo);
            chkActivate.Enabled = true;
            return;
        }

        // 再次检查起始卡号和结束卡号中间是激活状态的卡片数量
        count = ChargeCardHelper.queryCountByState(context, txtFromCardNo, txtToCardNo, "4");
        if (count > 0)
        {
            // 如果卡片数量大于0并且不等于相减所得数量，则说明不全是激活状态（还存在其他状态）
            if (count != quantity)
            {
                context.AddError("A007P01010: 位于起始卡号和终止卡号之间的充值卡不都是激活状态");
                return;
            }
            labState.Text = "已激活";
            labTotalValue.Text = ChargeCardHelper.queryTotalValue(context, txtFromCardNo, txtToCardNo).ToString("n");

            btnQuery.Text = "修改";
            setReadOnly(txtFromCardNo, txtToCardNo);
            chkClose.Enabled = true;
            return;
        }

        context.AddError("A007P01011: 位于起始卡号和终止卡号之间的充值卡不存在出库或激活状态");
    }

    // 点击“提交”按钮
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 生成充值卡激活/关闭存储过程，并调用之
        SP_CC_ActivatePDO pdo = new SP_CC_ActivatePDO(); // 充值卡激活/关闭存储过程
        pdo.fromCardNo = txtFromCardNo.Text;             // 起始卡号
        pdo.toCardNo = txtToCardNo.Text;                 // 结束卡号
        pdo.stateCode = chkActivate.Checked ? "4" : "3"; // 激活为'4', 关闭为'3'
        pdo.remark = txtRemark.Text.Trim();              // 备注

        bool ok = TMStorePModule.Excute(context, pdo);   // 执行存储过程

        if (ok) AddMessage(chkActivate.Checked ? "D007P01001: 激活成功" : "D007P01002: 关闭成功");

        foreach (Control con in this.Page.Controls)
        {
            ClearControl(con);
        }

        clearPageInput();

        btnQuery.Text = "查询";
        clearReadOnly(txtFromCardNo, txtToCardNo);
    }

    // 清除页面输入
    private void clearPageInput()
    {
        labQuantity.Text = "";
        labState.Text = "";
        labTotalValue.Text = "";
        chkActivate.Checked = false;
        chkClose.Checked = false;
        btnSubmit.Enabled = false;
        chkActivate.Enabled = false;
        chkClose.Enabled = false;
    }

    // 点击"激活"复选框（选中或者去选中）
    protected void chkActivate_CheckedChanged(object sender, EventArgs e)
    {
        if (chkActivate.Checked)
        {
            chkClose.Checked = false;
        }

        btnSubmit.Enabled = (chkActivate.Checked || chkClose.Checked);
    }

    // 点击"关闭"复选框（选中或者去选中）
    protected void chkClose_CheckedChanged(object sender, EventArgs e)
    {
        if (chkClose.Checked)
        {
            chkActivate.Checked = false;
        }
        btnSubmit.Enabled = (chkActivate.Checked || chkClose.Checked);
    }
}
