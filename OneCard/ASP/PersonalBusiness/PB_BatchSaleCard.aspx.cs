using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_PersonalBusiness_PB_BatchSaleCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtSellTime.Text = DateTime.Now.ToString("yyyyMMdd");

            txtFromCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtToCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtDeposit.Attributes["OnChange"] = "javascript:return Change();";
            txtCardCost.Attributes["OnChange"] = "javascript:return Change();";

            setReadOnly(txtSellTimes, txtMoney);
        }
    }

    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //对起始卡号进行非空、长度、数字检验



        bool b = valid.notEmpty(txtFromCardNo, "A004112100");
        if (b) b = valid.fixedLength(txtFromCardNo, 16, "A004112101");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A004112102");
        //对终止卡号进行非空检验

        bool b1 = valid.notEmpty(txtToCardNo, "A004112103");

        //对终止卡号进行长度、数字检验

        if (txtToCardNo.Text != "")
        {
            b = valid.fixedLength(txtToCardNo, 16, "A004112104");
            toCard = valid.beNumber(txtToCardNo, "A004112105");

            // 0 <= 终止卡号-起始卡号 <= 10000
            if (fromCard > 0 && toCard > 0)
            {
                long quantity = toCard - fromCard;
                b = valid.check(quantity >= 0, "A004112106");
                if (b) valid.check(quantity <= 10000, "A004112107");
            }
        }
        //卡片单价验证
        UserCardHelper.validatePrice(context, txtCardCost, "A002P01209: 卡费不能为空", "A002P01210: 卡费必须是10.2的格式");
        //卡片押金验证
        UserCardHelper.validatePrice(context, txtDeposit, "A002P01110: 卡押金不能为空", "A002P01110: 卡押金必须是10.2的格式");
        if (Convert.ToDecimal(txtCardCost.Text.Trim()) * Convert.ToDecimal(txtDeposit.Text.Trim()) != 0)
        {
            context.AddError("A00501B013");
        }
        //售卡时间校验
        if (string.IsNullOrEmpty(txtSellTime.Text.Trim()))
        {
            context.AddError("售卡时间不能为空");
        }
        else
        {
            if (!Validation.isDate(txtSellTime.Text.Trim(), "yyyyMMdd"))
            {
                context.AddError("售卡时间格式为yyyyMMdd");
            }
        }
        return !context.hasError();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_beginCardno").Value = txtFromCardNo.Text;
        context.AddField("p_endCardno").Value = txtToCardNo.Text;
        context.AddField("p_DEPOSIT").Value = Convert.ToInt32(txtDeposit.Text.Trim()) * 100;
        context.AddField("p_CARDCOST").Value = Convert.ToInt32(txtCardCost.Text.Trim()) * 100;
        //context.AddField("p_CURRENTTIME").Value = DateTime.ParseExact(txtSellTime.Text.Trim(), "yyyyMMdd", null);
        context.AddField("p_CURRENTTIME", "DateTime", "input", "", DateTime.ParseExact(txtSellTime.Text.Trim(), "yyyyMMdd", null).ToString());
        context.AddField("p_REMARK").Value = txtReMark.Text.Trim().ToString();
        bool ok = context.ExecuteSP("SP_PB_BatchSaleCard");

        if (ok)
        {
            AddMessage("批量售卡成功，请等待审批");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }
    }
}
