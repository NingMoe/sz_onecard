using Master;
using PDO.Financial;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;

/// <summary>
/// FIHelper 的摘要说明
/// </summary>
public class FIHelper
{
    public static void selectArea(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
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

        DataTable dataTable = storePro.Execute(context, pdo);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }

    public static void selectDept(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---普通---", ""));
        CashGiftHelper.selectDeptByArea(context, ddl, "SELECTDEPTBYAREA",context.s_DepartID);

        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S095470020: 部门查询失败");
        }
    }
    public static void selectDeptHasArea(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---普通---", ""));
        CashGiftHelper.selectDeptByArea(context, ddl, "SELECTDEPTBYAREA", context.s_DepartID, "OK");

        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S095470020: 部门查询失败");
        }
    }
}