using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Master;
using TM;
using Common;

public partial class CardReaderImpl : System.Web.UI.UserControl
{
    public string createToken(CmnContext context)
    {
        if (context.s_CardID == null) return "";

        // 获得TOKEN值

        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable data = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)data.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));

        return Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

    }
}
