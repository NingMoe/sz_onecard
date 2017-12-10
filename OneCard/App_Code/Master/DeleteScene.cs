/************************************************************************
 * DeleteScene
 * 类名:Delete执行类
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次开发
 ************************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Resources;
using System.Collections;
using Common;

namespace Master
{
    public class DeleteScene
    {
        public DeleteScene()
        {

        }

        /************************************************************************
         * 拼接Delete语句、执行 
         * @param CmnContext context         上下文环境
         * @param DDOBase ddoBase            输入的DDO对象
         * @param String sqlCondition        输入的执行语句（Delete语句）		
         * @return 		                     int
         ************************************************************************/
        public int Execute(CmnContext context, DDOBase ddoBase,String Sql)
        {
            String tablename = ddoBase.FullTableName;
            String[][] listColumns = ddoBase.Columns;

            String columnName;
            int index;
            String typeName;
            String columnValue;

            if (Sql != null)
            {
                Sql = DealString.GetResourceValue(context.ResourcePath, "SqlCondition", Sql);
            }

            //创建执行用的Command对象
            context.DBOpen("Delete");

            //将条件语句中的【INPUT.Parameter】替换成【?】，并将参数的值赋给CommandParameter对象
            int end = 0;
            int start = Sql.IndexOf("INPUT.");
            String replaceStr;
            Sql += " ";
            while (start > 0)
            {
                //得到字段名称、字段类型、字段的值
                end = Sql.IndexOf(" ", start + 1);
                replaceStr = Sql.Substring(start, end - start);
                columnName = replaceStr.Substring(6, end - start - 6);
                index = Convert.ToInt16(ddoBase.Hash[columnName]);
                typeName = listColumns[index][1];
                columnValue = ddoBase.ArrayList.GetValue(index).ToString();

                if ("oracle".Equals(context.DataBaseType))
                {
                    //将【INPUT.Parameter】替换成【:p + Parameter】
                    Sql = Sql.Replace(replaceStr, ":" + columnName);

                    //将参数的值赋给CommandParameter对象
                    context.AddDBParameter(typeName, columnName, columnValue);
                }
                else if ("sybase".Equals(context.DataBaseType))
                {
                    //将【INPUT.Parameter】替换成【?】
                    Sql = Sql.Replace(replaceStr, "?");

                    //将参数的值赋给CommandParameter对象
                    context.AddDBParameter(typeName, columnName, columnValue);
                }



                start = Sql.IndexOf("INPUT.");
            }

            //执行语句
            int rows = context.ExecuteNonQuery(Sql);
            return rows;
        }


    }
}
