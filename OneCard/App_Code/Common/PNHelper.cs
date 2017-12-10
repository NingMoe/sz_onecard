using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TM;
using Master;
using Common;
using PDO.AdditionalService;
using Controls.Customer.Asp;
using PDO.ProvisionNote;

// 附加业务帮助类


public class PNHelper
{
    public static void initPaperTypeList(CmnContext context, DropDownList lst, string funcCode, params string[] vars)
    {
        DataTable dt = SPHelper.callQuery("SP_PN_QUERY", context, funcCode, vars);

        GroupCardHelper.fill(lst, dt, true);
    }


    public static void initSexList(DropDownList lst)
    {
        initSexList(lst, true);
    }

    public static void initSexList(DropDownList lst, bool allowEmpty)
    {
        if (allowEmpty) lst.Items.Add(new ListItem("---请选择---", ""));
        lst.Items.Add(new ListItem("0:男", "0"));
        lst.Items.Add(new ListItem("1:女", "1"));
    }

    public static string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
    {

        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        pdo.funcCode = funcCode;
        int varNum = 0;
        foreach (string var in vars)
        {
            switch (++varNum)
            {
                case 1:
                    pdo.var1 = var;
                    break;
                case 2:
                    pdo.var2 = var;
                    break;
                case 3:
                    pdo.var3 = var;
                    break;
                case 4:
                    pdo.var4 = var;
                    break;
                case 5:
                    pdo.var5 = var;
                    break;
                case 6:
                    pdo.var6 = var;
                    break;
                case 7:
                    pdo.var7 = var;
                    break;
                case 8:
                    pdo.var8 = var;
                    break;
                case 9:
                    pdo.var9 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        return storePro.Execute(context, pdo);
    }
}

