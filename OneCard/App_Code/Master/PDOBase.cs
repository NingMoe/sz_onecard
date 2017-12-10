using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections;

/// <summary>
/// PDOBase 的摘要说明
/// </summary>
/// 
namespace Master
{
public class PDOBase:DDOBase
{
    public PDOBase()
    {}

    public PDOBase(String pdoName):base(pdoName)
    { }

    //列类型
    protected ArrayList columnsList = new ArrayList();

    protected void InitBegin(string tblName, int fieldsNum)
    {
        tableName = tblName;

        //AddField("RETVALUE", "Int32", "", "ReturnValue");
    }
    protected void InitEnd()
    {
        AddField("@currOper", "String", "6", "input");
        AddField("@currDept", "String", "4", "input");
        AddField("@retCode", "String", "10", "output");
        AddField("@retMsg", "String", "127", "output");
    }
    protected override void InitComplete()
    {
        columns = new String[columnsList.Count][];
        for (int i = 0; i < columnsList.Count; ++i)
        {
            String[] colDef = (String[])columnsList[i];
            columns[i] = colDef;
        }

        array = new String[columnsList.Count];
    }

    protected void AddField(string fldName, string fldType, string fldLen, string ioMode)
    {
        hash.Add(fldName.Replace("@", ""), columnsList.Count);
        columnsList.Add(new String[] { fldName.Replace("@", "p_"), fldType, fldLen, ioMode });
    }

    // 
    //public Int32 RETVALUE
    //{
    //    get { return GetInt32("RETVALUE"); }
    //    set { SetInt32("RETVALUE", value); }
    //}


   
    // 更新员工编码
    public String currOper
    {
        get { return GetString("currOper"); }
        set { SetString("currOper", value); }
    }

    // 更新部门编码
    public String currDept
    {
        get { return GetString("currDept"); }
        set { SetString("currDept", value); }
    }

    // 过程返回代码
    public String retCode
    {
        get { return GetString("retCode"); }
        set { SetString("retCode", value); }
    }

    // 过程返回消息
    public String retMsg
    {
        get { return GetString("retMsg"); }
        set { SetString("retMsg", value); }
    }
}
}

