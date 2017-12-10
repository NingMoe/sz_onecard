using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;

/// <summary>
/// SP_WA_Monitor 的摘要说明
/// </summary>
public class SP_WA_MonitorPDO : PDOBase
{
	public SP_WA_MonitorPDO()
	{
	}

    protected override void Init()
    {
        InitBegin("SP_WA_Monitor", 2 + 1);

        AddField("@retCode", "Int32", "", "output");
        AddField("@retMsg", "String", "127", "output");
    }
}
