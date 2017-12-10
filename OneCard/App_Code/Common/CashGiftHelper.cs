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
using PDO.CashGift;

/// <summary>
/// CashGiftHelper 的摘要说明
/// </summary>
public class CashGiftHelper
{
    // 初始化有效期选项
    public static void initValidMonths(CmnContext context, DropDownList lst, bool allowEmpty)
    {

        SPHelper.fillCodingWoCode(context, lst, allowEmpty, "CATE_CG_VALID");
    }
    
     public static void selectDeptByArea(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_CG_QueryPDO pdo = new SP_CG_QueryPDO();
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
}
