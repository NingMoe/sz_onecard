using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI.WebControls;

/// <summary>
///TSHelper 的摘要说明
/// </summary>
public class TSHelper
{
	public static void initDismissionTag(DropDownList ddl)
	{
        ddl.Items.Add(new ListItem("---请选择---", ""));
        ddl.Items.Add(new ListItem("1:在职", "1"));
        ddl.Items.Add(new ListItem("0:离职", "0"));
    }

    public static void initInitState(DropDownList ddl)
    {
        ddl.Items.Add(new ListItem("0B:签到", "0B"));
        ddl.Items.Add(new ListItem("0E:签退", "0E"));
        ddl.Items.Add(new ListItem("0C:签帐", "0C"));
    }

    public static void initInitState2(DropDownList ddl, bool allowEmpty)
    {
        if (allowEmpty)
        {
            ddl.Items.Add(new ListItem("---请选择---", ""));
        }
        ddl.Items.Add(new ListItem("0B:签到", "0B"));
        ddl.Items.Add(new ListItem("0E:签退", "0E"));
    }

    public static void initUseState(DropDownList ddl)
    {
        initUseState(ddl, true);
    }

    public static void initUseState(DropDownList ddl, bool allowEmpty)
    {
        if (allowEmpty)
        {
            ddl.Items.Add(new ListItem("---请选择---", ""));
        }
        ddl.Items.Add(new ListItem("09:启用", "09"));
        ddl.Items.Add(new ListItem("FF:销毁", "FF"));
    }

    public static void initPayType(DropDownList ddl)
    {
        ddl.Items.Add(new ListItem("---请选择---", ""));
        ddl.Items.Add(new ListItem("2:现金支付", "2"));
        ddl.Items.Add(new ListItem("0:转帐支付", "0"));
    }

    public static void initUseTag(DropDownList ddl)
    {
        initUseTag(ddl, true);
    }

    public static void initUseTag(DropDownList ddl, bool allowEmpty)
    {
        ddl.Items.Add(new ListItem("---请选择---", ""));
        ddl.Items.Add(new ListItem("1:有效", "1"));
        ddl.Items.Add(new ListItem("0:无效", "0"));
    }
}
