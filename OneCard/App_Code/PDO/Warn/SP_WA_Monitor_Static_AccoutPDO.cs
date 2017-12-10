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
public class SP_WA_Monitor_Static_AccoutPDO : PDOBase
{
	public SP_WA_Monitor_Static_AccoutPDO()
	{
	}

    protected override void Init()
    {
        InitBegin("SP_WA_Monitor_Static_Accout", 1 + 5);

        AddField("@amount", "Int32", "", "inputoutput");

       InitEnd();
    }
    
    public int amount
    {
      get { return  GetInt32("amount"); }
      set { SetInt32("amount",value); }
    }

}
