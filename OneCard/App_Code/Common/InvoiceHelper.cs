using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using PDO.UserCard;
using Master;

public class InvoiceHelper
{
    static public string queryVolumne(CmnContext context)
    {
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();

        pdo.funcCode = "InvoiceVolumnQuery";
        pdo.var1 = context.s_DepartID;
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        string volumnNo;
        if (data == null || data.Rows.Count == 0)
        {
            volumnNo = "";
        }
        else
        {
            Object[] obj = data.Rows[0].ItemArray;
            volumnNo = "" + obj[0];
        }

        return volumnNo;
    }

    static public string AutoGetValidateCode()
    {
        string validatecode = "0000";
        string k = string.Empty;
        Random r = new Random();
        k = Convert.ToString(r.Next(1, 9999));
        if (k.Length == 4)
        {
            validatecode = k;
        }
        else if (k.Length == 3)
        {
            validatecode = string.Format("{0:D4}", Convert.ToInt32(k));
        }
        else if (k.Length == 2)
        {
            validatecode = string.Format("{0:D4}", Convert.ToInt32(k));
        }
        else if (k.Length == 1)
        {
            validatecode = string.Format("{0:D4}", Convert.ToInt32(k));
        }
        return validatecode;
    }

}
