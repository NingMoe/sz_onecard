using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Data.OleDb;
using Common;
using Master;
using System.Data.OracleClient;

/// <summary>
/// StoreProScene 的摘要说明
/// </summary>
namespace Master
{
    public class StoreProScene
    {
        public DDOBase Execute(CmnContext context, DDOBase ddoBase, Type type)
        {
            String tablename = ddoBase.FullTableName;
            String[][] listColumns = ddoBase.Columns;

            //创建执行用的Command对象
            context.DBOpen("StorePro");

            //1、检查输入的条件语句中有没有Select字段
            //2、当没有Select字段时，拼接查询语句的Select和From部分
            String columnName;
            int index;
            String typeName;
            String columnLen;
            String columnValue;
            String columnInputOutput;
            for (int i = 0; i < listColumns.Length; i++)
            {
                columnName = listColumns[i][0];

                typeName = listColumns[i][1];
                columnLen = listColumns[i][2];
                columnInputOutput = listColumns[i][3];

                if ("oracle".Equals(context.DataBaseType))
                {
                    index = Convert.ToInt16(ddoBase.Hash[columnName.Replace("p_", "")]);
                }
                else
                {
                    index = Convert.ToInt16(ddoBase.Hash[columnName.Replace("@", "")]);
                }
                columnValue = (String)ddoBase.ArrayList.GetValue(index);
                
                context.AddDBParameter(typeName, columnName, columnValue,columnLen,columnInputOutput);
            }
            DataTable dataTable = null;
            try
            {
                dataTable = context.ExecuteReader(tablename);
            }
            catch(Exception e)
            {
                throw e;
            }

            ArrayList listPara = context.GetDBParameter();
            DDOBase ddoBaseOut = null;
            if (listPara.Count > 0)
            {
                ddoBaseOut = (DDOBase)Activator.CreateInstance(type);
                ddoBaseOut.setArray(listPara.ToArray());
            }

            return ddoBaseOut;
        }

        public DataTable Execute(CmnContext context, DDOBase ddoBase)
        {
            String tablename = ddoBase.FullTableName;
            String[][] listColumns = ddoBase.Columns;

            //创建执行用的Command对象
            context.DBOpen("StorePro");

            //1、检查输入的条件语句中有没有Select字段
            //2、当没有Select字段时，拼接查询语句的Select和From部分
            String columnName;
            int index;
            String typeName;
            String columnLen;
            String columnValue;
            String columnInputOutput;
            for (int i = 0; i < listColumns.Length; i++)
            {
                columnName = listColumns[i][0];

                typeName = listColumns[i][1];
                columnLen = listColumns[i][2];
                columnInputOutput = listColumns[i][3];

                if ("oracle".Equals(context.DataBaseType))
                {
                    index = Convert.ToInt16(ddoBase.Hash[columnName.Replace("p_", "")]);
                }
                else
                {
                    index = Convert.ToInt16(ddoBase.Hash[columnName.Replace("@", "")]);
                }
                
                columnValue = (String)ddoBase.ArrayList.GetValue(index);

                context.AddDBParameter(typeName, columnName, columnValue, columnLen, columnInputOutput);
            }


            DataTable dataTable = null;
            try
            {
                dataTable = context.ExecuteReader(tablename);
            }
            catch (Exception e)
            {
                throw e;
            }

            ArrayList listPara = context.GetDBParameter();
            if (listPara.Count > 0)
            {
                ddoBase.setArray(listPara.ToArray());
            }

            return dataTable;
        }

    }
}
