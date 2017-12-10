/************************************************************************
 * InsertScene
 * 类名:Insert执行类
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
    public class InsertScene 
    {
        /************************************************************************
         * 拼接Insert语句、执行 
         * @param CmnContext context         上下文环境
         * @param DDOBase ddoBase            输入的DDO对象	
         * @return 		                     DataTable
         ************************************************************************/
        public int Execute(CmnContext context, DDOBase ddoBase)
        {
            return Execute(context, ddoBase, "");
        }

        /************************************************************************
         * 拼接Insert语句、执行 
         * @param CmnContext context         上下文环境
         * @param DDOBase ddoBase            输入的DDO对象
         * @param String sqlCondition        输入的条件语句（Insert语句）		
         * @return 		                     DataTable
         ************************************************************************/
        public int Execute(CmnContext context, DDOBase ddoBase,String Sql)
        {
            String tablename = ddoBase.FullTableName;
            DealString dealStr = new DealString();
            String[][] listColumns = ddoBase.Columns;

            String SqlValues = "";
            String columnName;
            int index;
            String typeName;
            String columnValue;

            //创建执行用的Command对象
            context.DBOpen("Insert");

            //检查是否有执行语句
            if (Sql == "")
            {
                //拼接修改语句的Insert部分
                Sql = "Insert Into " + tablename + "(";

                for (int i = 0; i < listColumns.Length; i++)
                {
                    //得到字段名称、字段类型
                    columnName = listColumns[i][0];
                    index = Convert.ToInt16(ddoBase.Hash[columnName]);
                    typeName = listColumns[i][1];

                    //当字段的值不为空的时候，设置修改值
                    if (ddoBase.ArrayList.GetValue(index) != null)
                    {
                        columnValue = ddoBase.ArrayList.GetValue(index).ToString();

                        if (i > 0)
                        {
                            Sql += ",";
                            SqlValues += ",";
                        }

                        Sql += columnName;
                        

                        if ("oracle".Equals(context.DataBaseType))
                        {
                            SqlValues += " :" + columnName + " ";

                            //将参数的值赋给CommandParameter对象
                            context.AddDBParameter(typeName, columnName, columnValue);
                        }
                        else if ("sybase".Equals(context.DataBaseType))
                        {
                            SqlValues += " ? ";

                            //将参数的值赋给CommandParameter对象
                            context.AddDBParameter(typeName, columnName, columnValue);
                        }
                    }
                }

                //完成语句组装
                Sql += ") Values(" + SqlValues + ")";
            }
            else
            {
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

                    //将【INPUT.Parameter】替换成【?】
                    if ("oracle".Equals(context.DataBaseType))
                    {
                        Sql = Sql.Replace(replaceStr, columnName);
                    }
                    else if ("sybase".Equals(context.DataBaseType))
                    {
                        Sql = Sql.Replace(replaceStr, "?");
                    }

                    //将参数的值赋给CommandParameter对象
                    context.AddDBParameter(typeName, columnName, columnValue);

                    start = Sql.IndexOf("INPUT.");
                }
            }

            //执行语句
            int rows = context.ExecuteNonQuery(Sql);
            return rows;

        }

    }
}
