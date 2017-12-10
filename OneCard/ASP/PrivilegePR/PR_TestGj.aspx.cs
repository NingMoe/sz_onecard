using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using System.Data;
using Common;
using Master;

public partial class TestGj : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected string createTokenValue(CmnContext context)
    {
        // 获得TOKEN值
        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable data = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)data.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));

        return Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

    }

    protected void Button2_Click(object sender, EventArgs e)
    {
        // 解锁
        hidCardReaderToken.Value = createTokenValue(context);
        ScriptManager.RegisterStartupScript(
            this, this.GetType(), "writeCardScript",
            hidHelp.Value, true);     
    }
}
