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
/// 项目管理帮助类
/// </summary>
public class ProjectManageHelper
{
    //绑定资源类型
    public static void selectProject(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "Query_ProjectList", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化项目列表失败");
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
        DataTable dataTable = SPHelper.callQuery("SP_PM_Query", context, funcCode, vars);
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
}