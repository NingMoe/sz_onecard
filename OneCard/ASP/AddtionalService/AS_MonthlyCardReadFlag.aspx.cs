using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.PersonalBusiness;
using TDO.UserManager;
using System.Collections.Generic;
using Master;

public partial class ASP_AddtionalService_AS_MonthlyCardReadFlag : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }


    protected void btnGetToken_Click(object sender, EventArgs e)
    {
       


    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        string token;
        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable dt = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)dt.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
        token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

        hidCardReaderToken1.Value = token;
        ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "ReadYuepiaoInfo();", true);
    }
}
