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

// 充值卡直销
public partial class ASP_ChargeCard_CC_DirectSale : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        txtAccRecvDate.Attributes["readonly"] = "true";
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (btnQuery.Text == "修改")
        {
            btnQuery.Text = "查询";
            btnSubmit.Enabled = false;
            clearReadOnly(txtFromCardNo, txtToCardNo);
            return;
        }

        // 检查起始卡号和终止卡号的格式（非空、14位、英数）
        long quantity = ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError())
        {
            return;
        }
        labQuantity.Text = "" + quantity;

        int num = ChargeCardHelper.validateCardSold(context, txtFromCardNo, txtToCardNo);
        if (num > 0) return;

        // 检查卡是否都是出库状态 4-激活 5-使用 2008年9月3日17:25:55
        int queryCount = ChargeCardHelper.queryCountOfBatchSalable(context, txtFromCardNo, txtToCardNo);
        if (quantity != queryCount)
        {
            context.AddError("A007P02011: 状态不一致，请重新选择充值卡卡号范围");
            return;
        }


        // 检查卡是否是属于当前员工的部门
        queryCount = ChargeCardHelper.queryCountOfAssignDepart(context, txtFromCardNo, txtToCardNo);
        if (queryCount != quantity)
        {
            context.AddError("A007P04C01: 充值卡不属于当前员工所属的部门");
            return;
        }

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

        // 计算充值卡单张面值
        decimal unitPrice = ChargeCardHelper.queryUnitValue(context, txtFromCardNo);
        
        // 显示总面值
        labTotalValue.Text = unitPrice.ToString("n") + " * " + quantity + " = " + (quantity * unitPrice).ToString("n");

        setReadOnly(txtFromCardNo, txtToCardNo);

        btnQuery.Text = "修改";
        btnSubmit.Enabled = true;
    }

    // 提交前校验处理
    private void submitValidate()
    {
        Validation valid = new Validation(context);

        // 客户姓名校验 （不能为空，并且长度不超50位）
        bool b = valid.notEmpty(txtCustName, "A007P02012: 客户姓名不能为空");
        if (b) valid.check(Validation.strLen(txtCustName.Text) <= 50, "A007P02013: 客户姓名长度不能超过50");

        valid.notEmpty(selPayMode, "A007P02014: 付款方式必须设置");

        // 转账情况下的到账标记、到账日期校验（已到帐时检查到帐日期）
        if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2")  // 转账
        {
            valid.notEmpty(selRecvTag, "A007P02015: 到帐标记必须设置");

            if (selRecvTag.SelectedValue == "1")
            {
                b = valid.notEmpty(txtAccRecvDate, "A007P02016: 到帐日期不能为空");
                DateTime? dt = null;
                if (b) dt = valid.beDate(txtAccRecvDate, "A007P02017: 到帐日期必须格式为yyyyMMdd");
                if (dt != null)
                {
                    valid.check(dt.Value.CompareTo(DateTime.Today) <= 0, "A007P02018: 到帐日期不能超过当前日期");
                }
            }
        }

        valid.check(Validation.strLen(txtRemark.Text) <= 200, "A007P02019: 备注长度不能超过200");
    }

    // 点击“提交”按钮事件处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError())
        {
            return;
        }

        // 执行“直销存储过程”
        SP_CC_DirectSalePDO pdo = new SP_CC_DirectSalePDO();  // 直销存储过程
        pdo.fromCardNo = txtFromCardNo.Text;                  // 起始卡号
        pdo.toCardNo = txtToCardNo.Text;                      // 终止卡号
        pdo.custName = txtCustName.Text;                      // 客户姓名
        pdo.accRecv = selRecvTag.SelectedValue;               // 到账标记
        pdo.payMode = selPayMode.SelectedValue;               // 支付方式
        if (selPayMode.SelectedValue == "1") // 现金
        {
            pdo.recvDate = DateTime.Today.ToString("yyyyMMdd"); // 到账日期
        }
        else
        {
            pdo.recvDate = txtAccRecvDate.Text;                 // 到账日期
        }

        pdo.remark = txtRemark.Text.Trim();
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            AddMessage("D007P02001: 直销成功");
        }



        btnQuery.Text = "查询";
        btnSubmit.Enabled = false;
        clearReadOnly(txtFromCardNo, txtToCardNo);
    }

    // "支付方式"与"到账标记"下拉列表选择更改事件处理
    protected void selPayMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selPayMode.SelectedValue == "1") // 现金
        {
            selRecvTag.Enabled = false;
            txtAccRecvDate.Enabled = false;
        }
        else if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2") // 转账或报销
        {
            selRecvTag.Enabled = true;
            if (selRecvTag.SelectedValue == "0") // 未到账
            {
                txtAccRecvDate.Enabled = false;
                txtAccRecvDate.Text = "";
            }
            else if (selRecvTag.SelectedValue == "1") // 已到账
            {
                txtAccRecvDate.Enabled = true;
            }
        }
    }
}
