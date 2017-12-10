using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using PDO.ResourceManage;
using System.IO;
using Master;
using Common;
using System.Drawing;


/// <summary>
/// 其他资源管理帮助类
/// </summary>
public class OtherResourceManagerHelper
{
    //绑定资源类型
    public static void selectResourceType(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "Query_ResourceType", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化资源类型列表失败");
        }
    } 
    //绑定资源非领用属性
    public static void queryAttribute(CmnContext context, DropDownList ddl, string funcCode, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---"));
        DataTable dataTable = SPHelper.callQuery("SP_RM_OTHER_Query", context, funcCode, vars);
        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem( itemArray[0].ToString());
            ddl.Items.Add(li);
        }
        if (dataTable.Rows.Count == 0)
        {
            return;
        }
        
    }


    //绑定资源
    public static void selectResource(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "Query_Resource", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化资源列表失败");
        }
    }

    //从制卡文件名表(TF_SYN_CARDFILE) 中读取数据放入下拉框
    public static void selFileNameSelect(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        DataTable dataTable = callOtherQuery(context, "GETFILENAME");

        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem(itemArray[0].ToString(), itemArray[1].ToString());
            ddl.Items.Add(li);
        }

        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094780001: 初始化金额参数列表失败");
        }
    }

    public static void selectManuWithCoding(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        selectCoding(context, ddl, "TD_M_MANUWITHCODING");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I03: 初始化厂商列表失败");
        }
    }

    public static void selectCoding(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_RM_QueryPDO pdo = new SP_RM_QueryPDO();
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
    }

    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：查询并为下拉选框赋值
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">待赋值的下拉选框</param>
    /// <param name="funcCode">存储过程功能编码</param>
    /// <param name="vars">存储过程参数</param>
    /// <returns></returns>
    public static void select(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        DataTable dataTable = SPHelper.callQuery("SP_RM_OTHER_Query", context, funcCode, vars);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }
        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], itemArray[1].ToString());
            ddl.Items.Add(li);
        }
    }
    public static void selectDepartment(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "Query_Department", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化部门列表失败");
        }
    }

    public static void selectStaff(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "Query_Staff", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化员工列表失败");
        }
    }

    /// <summary>
    /// 取最新资源编码
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="funcCode">功能编码</param>
    /// <returns>资源编码</returns>
    public static string selectMaxResourceCode(CmnContext context, string funcCode)
    {
        string resourceCode = string.Empty;

        DataTable dt = callOtherQuery(context, "Query_ResourceCode");

        try
        {
            resourceCode = "000000" + (int.Parse(dt.Rows[0][0].ToString()) + 1).ToString();
            resourceCode = resourceCode.Substring(resourceCode.Length - 6, 6);
        }
        catch
        {
            resourceCode = "000001";
        }

        return resourceCode;
    }




    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：调用通用查询存储过程SP_RM_OTHER_Query，查询资源管理相关信息
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_OTHER_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="funcCode">存储过程功能编码</param>
    /// <param name="vars">存储过程参数</param>
    /// <returns>DataTable,从数据库中查询出的结果</returns>
    public static DataTable callOtherQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_RM_OTHER_QueryPDO pdo = new SP_RM_OTHER_QueryPDO();
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