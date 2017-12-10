using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI.WebControls;

/// <summary>
///EMHelper 的摘要说明
/// </summary>
public class EMHelper
{
	public static void setSource(DropDownList ddl)
	{
        ddl.Items.Add(new ListItem("---请选择---", ""));
        ddl.Items.Add(new ListItem("1:本公司提供", "1"));
        ddl.Items.Add(new ListItem("0:商户自有", "0"));
    }
}
