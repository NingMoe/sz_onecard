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

public partial class ASP_AddtionalService_telcard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            CardInfo.Attributes["readonly"] = "true";

            CardType.Items.Add(new ListItem("201","201"));
            CardType.Items.Add(new ListItem("96998", "96998"));
            CardType.Items.Add(new ListItem("1183311", "1183311"));
        }
    }
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            //btnReadNCard.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            return;
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "submit")
        {
            //btnDBRead_Click(sender, e);
        }
        hidWarning.Value = "";
    }
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnWriteCard.Enabled = true;
    }
    protected void btnWriteCard_Click(object sender, EventArgs e)
    {
        if ((txtCardNo.Text.Length + txtPasswd.Text.Length) > 33)
        {
            context.AddError("A001026101");
            return;
        }
         string str = (CardType.Text + 'E' + txtCardNo.Text + "BE" + txtPasswd.Text + "BF"
            + "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
         strName.Value = str.Substring(0, 40);

        ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "writeTelcard();", true);
        btnWriteCard.Enabled = false;
    }
}
