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
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;

// 月票卡售卡返销
public partial class ASP_AddtionalService_AS_ChangeTimes : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        txtGardenTimes.Attributes["onkeyup"] = "realRecvChanging(this);";
        txtRelaxTimes.Attributes["onkeyup"] = "realRecvChanging(this);";
        txtWujlvyouTimes.Attributes["onkeyup"] = "realRecvChanging(this);";

    }

    // 查询
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        Validation valid = new Validation(context);

        // 对卡号进行非空、长度、数字检验

        bool b = valid.notEmpty(txtCardNo, "A004P09001: 卡号不能为空");
        if (b) b = valid.fixedLength(txtCardNo, 16, "A004P09002: 卡号长度必须是16位");
        if (b) valid.beNumber(txtCardNo, "A004P09003: 卡号必须全部是数字");

        if (context.hasError()) return;

        DataTable data = ASHelper.callQuery(context, "ReadGardenTimes", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            txtGardenTimes.Text = "" + data.Rows[0].ItemArray[0];
            txtGardenTimes.Enabled = true;
            txtGardenTimes.CssClass = "inputmid";
        }
        else
        {
            txtGardenTimes.Text = "";
            txtGardenTimes.Enabled = false;
            txtGardenTimes.CssClass = "labeltext";
        }
        labGardenTimes.Text = txtGardenTimes.Text;

        data = ASHelper.callQuery(context, "ReadRelaxTimes", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            txtRelaxTimes.Text = "" + data.Rows[0].ItemArray[0];
            txtRelaxTimes.Enabled = true;
            txtRelaxTimes.CssClass = "inputmid";
        }
        else
        {
            txtRelaxTimes.Text = "";
            txtRelaxTimes.Enabled = false;
            txtRelaxTimes.CssClass = "labeltext";
        }
        labRelaxTimes.Text = txtRelaxTimes.Text;

        data = ASHelper.callQuery(context, "ReadWjLvyouTimes", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            txtWujlvyouTimes.Text = "" + data.Rows[0].ItemArray[0];
            txtWujlvyouTimes.Enabled = true;
            txtWujlvyouTimes.CssClass = "inputmid";
        }
        else
        {
            txtWujlvyouTimes.Text = "";
            txtWujlvyouTimes.Enabled = false;
            txtWujlvyouTimes.CssClass = "labeltext";
        }
        labWujlvyouTimes.Text = txtWujlvyouTimes.Text;

        if (!txtGardenTimes.Enabled && !txtRelaxTimes.Enabled && !txtWujlvyouTimes.Enabled)
        {
            context.AddError("A005160001: 当前卡片不是有效的园林或者休闲年卡或者吴江旅游卡", txtCardNo);
        }

        btnSubmit.Enabled = !context.hasError();
    }

    // 售卡/补卡返销
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SP_AS_ChangeTimesPDO pdo = new SP_AS_ChangeTimesPDO();

        pdo.cardNo = txtCardNo.Text;
        pdo.gardenTimes = txtGardenTimes.Enabled ? Convert.ToInt32(txtGardenTimes.Text) : 0;
        pdo.relaxTimes = txtRelaxTimes.Enabled ? Convert.ToInt32(txtRelaxTimes.Text) : 0;
        pdo.wujlvyouTimes = txtWujlvyouTimes.Enabled ? Convert.ToInt32(txtWujlvyouTimes.Text) : 0;

        if (txtGardenTimes.Enabled)
        {
            if ((pdo.gardenTimes <= 0 || pdo.gardenTimes >= 100))
            {
                context.AddError("A005160002: 更改后的次数只能在1到99之间", txtGardenTimes);
            }
            else if (txtGardenTimes.Text == labGardenTimes.Text)
            {
                pdo.gardenTimes = 0;
            }
        }

        if (txtRelaxTimes.Enabled)
        {
            if ((pdo.relaxTimes <= 0 || pdo.relaxTimes >= 100))
            {
                context.AddError("A005160002: 更改后的次数只能在1到99之间", txtRelaxTimes);
            }
            else if (txtRelaxTimes.Text == labRelaxTimes.Text)
            {
                pdo.relaxTimes = 0;
            }
        }

        if (txtWujlvyouTimes.Enabled)
        {
            if ((pdo.wujlvyouTimes <= 0 || pdo.wujlvyouTimes >= 100))
            {
                context.AddError("A005160002: 更改后的次数只能在1到99之间", txtWujlvyouTimes);
            }
            else if (txtWujlvyouTimes.Text == labWujlvyouTimes.Text)
            {
                pdo.wujlvyouTimes = 0;
            }
        }

        if (pdo.gardenTimes == 0 && pdo.relaxTimes == 0 && pdo.wujlvyouTimes == 0)
        {
            context.AddError("A005160003: 次数没有更新");
        }

        if (context.hasError()) return;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 存储过程执行成功，返回成功消息

        if (ok)
        {
            context.AddMessage("D005160001: 更改次数成功");
        }
    }
}
