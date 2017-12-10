/************************************************************************
 * SelectScene
 * 类名:Select执行类
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次开发
 ************************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Common;


namespace Master 
{
    public class SelectScene
    {
        /************************************************************************
         * 拼接Select语句、执行 
         * @param CmnContext context         上下文环境
         * @param DDOBase ddoBase            输入的DDO对象
         * @param String sqlCondition        输入的条件语句（WHERE语句）		
         * @return 		                     DataTable
         ************************************************************************/
        public DataTable Execute(CmnContext context, DDOBase ddoBase, String sqlCondition,int countsize)
        {
            DealString dealStr = new DealString();
            String[][] listColumns = null;
            String[] listColumnsPK = null;
            String columnName;

            if (ddoBase != null)
            {
                listColumns = ddoBase.Columns;
                listColumnsPK = ddoBase.ColumnKeys;
            }
            String Sql = "";

            if (sqlCondition == null)
                sqlCondition = " ";

            //创建执行用的Command对象
            context.DBOpen("Select");

            //1、检查输入的条件语句中有没有Select字段
            //2、当没有Select字段时，拼接查询语句的Select和From部分
            
            sqlCondition = sqlCondition.Trim();
            if (sqlCondition.IndexOf("select", System.StringComparison.OrdinalIgnoreCase) != 0)
            {
                Sql = "Select ";
                for (int i = 0; i < listColumns.Length; i++)
                {
                    if (i == 0)
                        Sql += " " + listColumns[i][0];
                    else
                        Sql += ", " + listColumns[i][0];
                }
                Sql += " From " + ddoBase.FullTableName;

                if (sqlCondition.Equals("") && listColumnsPK != null)
                {
                    for (int i = 0; i < listColumnsPK.Length; i++)
                    {
                        columnName = listColumnsPK[i].ToString();

                        if(i == 0)
                        {
                            Sql += " Order By " + columnName;

                        }else{

                            Sql += " ," + columnName;
                        }
                    }
                }
            }
            

            int start = 0;
            int end = 0;
            String replaceStr;
            int index;
            String typeName;
            String columnValue;

            //将条件语句中的【INPUT.Parameter】替换成【?】，并将参数的值赋给CommandParameter对象
            start = sqlCondition.IndexOf("INPUT.");
            sqlCondition += " ";
            while (start > 0)
            {
                //得到字段名称、字段类型、字段的值

                end = sqlCondition.IndexOf(" ", start + 1);
                replaceStr = sqlCondition.Substring(start, end - start);
                columnName = replaceStr.Substring(6, end - start - 6);
                index = Convert.ToInt16(ddoBase.Hash[columnName]);
                typeName = listColumns[index][1];
                columnValue = ddoBase.ArrayList.GetValue(index).ToString();

                if ("oracle".Equals(context.DataBaseType))
                {
                    //将【INPUT.Parameter】替换成【?】
                    sqlCondition = sqlCondition.Replace(replaceStr, ":" + columnName);

                    //将参数的值赋给CommandParameter对象
                    context.AddDBParameter(typeName, columnName, columnValue);
                }
                else if ("sybase".Equals(context.DataBaseType))
                {
                    //将【INPUT.Parameter】替换成【?】
                    sqlCondition = sqlCondition.Replace(replaceStr, "?");

                    //将参数的值赋给CommandParameter对象
                    context.AddDBParameter(typeName, columnName, columnValue);
                }

                start = sqlCondition.IndexOf("INPUT.");
            }

            //完成语句组装、执行
            Sql += " " + sqlCondition;

            //设置TOP N
            if(countsize > 0){
                if ("oracle".Equals(context.DataBaseType))
                {
                    Sql = "Select * From ( " + Sql + ") Where rownum <= " + countsize;
                }
                else if ("sybase".Equals(context.DataBaseType))
                    Sql = "set rowcount " + countsize + " " + Sql;
            }

            
            DataTable dataTable = context.ExecuteReader(Sql);

            return dataTable;
        }

        /************************************************************************
         * 拼接Select语句、执行，返回Object数组
         * @param CmnContext context         上下文环境
         * @param DDOBase ddoBase            输入的DDO对象
         * @param String sqlCondition        输入的条件语句（WHERE语句）
         * @param Type type                  输入的DDO类的类型
         * @return 		                     Object
         ************************************************************************/
        public Object Execute(CmnContext context, DDOBase ddoBaseIn, String sqlCondition, Type type)
        {
            //拼接Select语句、执行 
            DataTable dataTable = Execute(context, ddoBaseIn, sqlCondition,0);

            //将查询结果放入Object数组中、返回
            Type arrtype = type.MakeArrayType();
            Object arrObject = Activator.CreateInstance(arrtype, dataTable.Rows.Count);
            Object[] listDDOBase = (Object[])arrObject;

            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                DDOBase ddoBaseOut = (DDOBase)Activator.CreateInstance(type);
                ddoBaseOut.setArray(dataTable.Rows[i].ItemArray);
                listDDOBase[i] = ddoBaseOut;
            }

            return arrObject;
        }


    }
}
