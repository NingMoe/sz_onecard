using System;
using System.Collections.Generic;
using System.Web;
using Master;
using PDO.PersonalBusiness;
using System.Data;
using PDO.PartnerShip;
using PDO.SpecialDeal;
using PDO.TaxiService;
using System.Web.UI.WebControls;

/// <summary>
///SPHelper 的摘要说明
/// </summary>
public class SPHelper
{
    public static void fillCoding(CmnContext context, DropDownList ddl, bool allowEmpty,
        string category)
    {
        context.DBOpen("Select");
        context.AddField("category").Value = category;
        DataTable data = context.ExecuteReader(
            "select t.CODENAME, t.CODEVALUE from TD_M_CODING t where t.CODECATE = :category");
        context.DBCommit();

        ddl.Items.Clear();
        GroupCardHelper.fill(ddl, data, allowEmpty);
    }
    public static void fillCodingWoCode(CmnContext context, DropDownList ddl, bool allowEmpty,
        string category)
    {
        context.DBOpen("Select");
        context.AddField("category").Value = category;
        DataTable data = context.ExecuteReader(
            "select t.CODENAME, t.CODEVALUE from TD_M_CODING t where t.CODECATE = :category");
        context.DBCommit();

        ddl.Items.Clear();
        GroupCardHelper.fillWoCode(ddl, data, allowEmpty);
    }

    public static void fillDDL(CmnContext context, DropDownList ddl, bool allowEmpty,
            String spName, String funcCode, params string[] vars)
    {
        DataTable data = callQuery(spName, context, funcCode, vars);
        ddl.Items.Clear();
        GroupCardHelper.fill(ddl, data, allowEmpty);
    }

    public static void fill12DDL(CmnContext context, DropDownList ddl, bool allowEmpty,
        String spName, String funcCode, params string[] vars)
    {
        DataTable data = call12Query(spName, context, funcCode, vars);
        ddl.Items.Clear();
        GroupCardHelper.fill(ddl, data, allowEmpty);
    }

    public static void fillDDLWoCode(CmnContext context, DropDownList ddl, bool allowEmpty,
        String spName, String funcCode, params string[] vars)
    {
        DataTable data = callQuery(spName, context, funcCode, vars);
        ddl.Items.Clear();
        GroupCardHelper.fillWoCode(ddl, data, allowEmpty);
    }

    public static void fill12DDLWoCode(CmnContext context, DropDownList ddl, bool allowEmpty,
    String spName, String funcCode, params string[] vars)
    {
        DataTable data = call12Query(spName, context, funcCode, vars);
        ddl.Items.Clear();
        GroupCardHelper.fillWoCode(ddl, data, allowEmpty);
    }


    public static DataTable callWAQuery(CmnContext context, string funcCode, params string[] vars)
    {
        return callQuery("SP_WA_Query", context, funcCode, vars);
    }

    public static DataTable callPSQuery(CmnContext context, string funcCode, params string[] vars)
    {
        return callQuery("SP_PS_Query", context, funcCode, vars);
    }
    
    public static DataTable callPBQuery(CmnContext context, string funcCode, params string[] vars)
    {
        return callQuery("SP_PB_Query", context, funcCode, vars);
	}

    public static DataTable callSDQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_SD_Query");
        return call12Query(pdo, context, funcCode, vars);
    }

    public static DataTable callTSQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_TS_Query");
        return call12Query(pdo, context, funcCode, vars);
    }

    public static DataTable callQuery(String pdoName, CmnContext context, string funcCode, params string[] vars)
    {
        SP_QueryPDO pdo = new SP_QueryPDO(pdoName);
        return callQuery(pdo, context, funcCode, vars);
    }
    public static DataTable call12Query(String pdoName, CmnContext context, string funcCode, params string[] vars)
    {
        SP_12QueryPDO pdo = new SP_12QueryPDO(pdoName);
        return call12Query(pdo, context, funcCode, vars);
    }
    public static DataTable callQuery(SP_QueryPDO pdo, CmnContext context, string funcCode, params string[] vars)
    {
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

    public static DataTable call12Query(SP_12QueryPDO pdo, CmnContext context, string funcCode, params string[] vars)
    {
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
                case 10:
                    pdo.var10 = var;
                    break;
                case 11:
                    pdo.var11 = var;
                    break;
                case 12:
                    pdo.var12 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        return storePro.Execute(context, pdo);
    }

    public static DataTable callITQuery(CmnContext context, string funcCode, params string[] vars)
    {
        return callQuery("SP_IT_Query", context, funcCode, vars);
    }

    public static void selectChargeType(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        selectCoding(context, ddl, "TD_M_CHARGETYPE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094570250: 充值营销模式失败");
        }
    }
    public static void selectCoding(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_PS_QueryPDO pdo = new SP_PS_QueryPDO();
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
