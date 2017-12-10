using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_PersonalBusiness_PB_ChangeRemark : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
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

        return !context.hasError();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        context.SPOpen();

        context.AddField("p_fromCardNo").Value = txtFromCardNo.Text;
        context.AddField("p_toCardNo").Value = txtToCardNo.Text;
        context.AddField("p_remark").Value = txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_PB_ChangeRemark");

        if (ok)
        {
            AddMessage("更改客户信息成功");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }
    }
}
