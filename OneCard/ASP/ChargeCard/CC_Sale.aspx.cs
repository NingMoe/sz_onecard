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

// 充值卡前台售卡
public partial class ASP_ChargeCard_CC_Sale : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    // 查询/修改 按钮点击事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (btnQuery.Text == "修改")
        {
            btnQuery.Text = "查询";
            btnSubmit.Enabled = false;

            clearReadOnly(txtFromCardNo, txtToCardNo);
            return;
        }

        #region add by yin 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion 

        // 检查起始卡号和终止卡号的格式（非空、14位、英数）
        long quantity = ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError())
        {
            return;
        }
        labQuantity.Text = "" + quantity;

        // 查询总面值        labTotalValue.Text = ChargeCardHelper.queryTotalValue(context, txtFromCardNo, txtToCardNo).ToString("n");

        // 检查充值卡是否都有相同的面值        bool b = ChargeCardHelper.hasSameFaceValue(context, txtFromCardNo, txtToCardNo);
        if (!b)
        {
            return;
        }

        // 检查充值卡是否都有相同的类型
        b = ChargeCardHelper.hasSameTypeValue(context, txtFromCardNo, txtToCardNo);
        if (!b)
        {
            return;
        }

        labCardType.Text = ChargeCardHelper.CardTypeValue(context, txtFromCardNo);

        // 检查卡是否是可售状态（出库或激活状态并且售出员工、售出时间为空）
        int count = ChargeCardHelper.queryCountOfSalable(context, txtFromCardNo, txtToCardNo);
        if (count != quantity)
        {
            context.AddError("A007P04001: 充值卡不是可售状态");
            return;
        }
        // 检查卡是否是属于当前员工的部门
        count = ChargeCardHelper.queryCountOfAssignDepart(context, txtFromCardNo, txtToCardNo);
        if (count != quantity)
        {
            context.AddError("A007P04C01: 充值卡不属于当前员工所属的部门");
            return;
        }

        setReadOnly(txtFromCardNo, txtToCardNo);
        btnQuery.Text = "修改";
        btnSubmit.Enabled = true;
    }

    // 点击“提交”按钮    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        txtRemark.Text = txtRemark.Text.Trim();
        if (Validation.strLen(txtRemark.Text) > 100)
        {
            context.AddError("A005010011: 备注位数必须小于等于100", txtRemark);
            return;
        }

        #region add by yin 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(labTotalValue.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion 

        // 调用充值卡销售存储过程
        SP_CC_SalePDO pdo = new SP_CC_SalePDO();
        pdo.fromCardNo = txtFromCardNo.Text;            // 起始卡号
        pdo.toCardNo = txtToCardNo.Text;                // 结束卡号
        pdo.remark = txtRemark.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D007P04001: 充值卡售卡成功");

        foreach (Control con in this.Page.Controls)
        {
            ClearControl(con);
        }

        // 重置页面
        btnQuery.Text = "查询";
        btnSubmit.Enabled = false;
        clearReadOnly(txtFromCardNo, txtToCardNo);
    }
}
