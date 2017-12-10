/***************************************************************
 * DBConnectionOleDB
 * 类名:数据库类
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Data;
using System.Data.OleDb;
using System.Collections;

namespace Master
{
    public class DBConnectionOleDB
    {
        private OleDbConnection sqlConnection;
        private OleDbTransaction sqlTransaction;
        private OleDbCommand sqlCommand;
        private Boolean connFlag = false;
        private Boolean transFlag = false;

        //private static String connStr = ConfigurationManager.ConnectionStrings["connStr"].ConnectionString;

        //update by jiangbb 2012-06-14 解密 
        private static String connStr = GetConnStr();

        private static string GetConnStr()
        {
            string connectString = ConfigurationManager.ConnectionStrings["connStr"].ConnectionString;
            string[] strs = connectString.Split(';');
            string pwd = string.Empty;
            for (int i = 0; i < strs.Length; i++)
            {
                if (strs[i].ToLower().Contains("password="))
                {
                    pwd = strs[i].Trim().Substring(9);
                    break;
                }
            }
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESDeEncrypt(pwd, ref strBuilder);
            connectString = connectString.Replace(pwd, strBuilder.ToString().Trim());
            return connectString;
        }

        /************************************************************************
         * 数据库打开，生成Command的对象。根据要执行的语句类型，设定Command类型、
         * 以及是否打开事务处理
         * @param String cmdType             语句类型（Select：不使用事务，CommandType=Text(默认值)；
         *                                             Update：使用事务，CommandType=Text(默认值)；
         *                                             Insert：使用事务，CommandType=Text(默认值)；
         *                                             StorePro：使用事务，CommandType=StoredProcedure；
         * @return 		                     void
         ************************************************************************/
        public void Open(String cmdType)
        {
            //当没有打开数据库连接时，打开数据库连接

            if (connFlag == false)
            {
                try
                {
                    sqlConnection = new System.Data.OleDb.OleDbConnection(connStr);
                    sqlConnection.Open();
                    connFlag = true;
                }
                catch (Exception e)
                {
                    throw e;
                }
            }

            //创建DBCommand
            sqlCommand = sqlConnection.CreateCommand();
            sqlCommand.CommandTimeout = 600;

            //根据语句类型，确定是否使用事务，以及CommandType类型
            if (cmdType == "Update" || cmdType == "Insert" || cmdType == "Delete")
            {
                BeginTrans();

                sqlCommand.Transaction = sqlTransaction;
            }
            else if (cmdType == "StorePro")
            {
                sqlCommand.CommandType = CommandType.StoredProcedure;
            }

        }

        /************************************************************************
         * 打开事务
         * @return 		                     void
         ************************************************************************/
        public void BeginTrans()
        {
            if (transFlag == false)
            {
                sqlTransaction = sqlConnection.BeginTransaction();
                transFlag = true;
            }
        }

        /************************************************************************
         * 数据库关闭
         * @return 		                     void
         ************************************************************************/
        public void Close()
        {
            if (connFlag == true)
                sqlConnection.Close();

            connFlag = false;
        }

        /************************************************************************
         * 事务回滚
         * @return 		                     void
         ************************************************************************/
        public void RollBack()
        {
            if (transFlag == true)
                sqlTransaction.Rollback();

            transFlag = false;
        }

        /************************************************************************
         * 事务提交
         * @return 		                     void
         ************************************************************************/
        public void Commit()
        {
            if (transFlag == true)
                sqlTransaction.Commit();

            transFlag = false;
        }

        /************************************************************************
         * 为Command的对象添加DB参数
         * @param String typeName            参数类型
         * @param String columnName          参数名
         * @param String columnValue         参数值
         * @return 		                     void
         ************************************************************************/
        public void AddDBParameter(String typeName, String columnName, String columnValue, String columnLen, String paraType)
        {

            OleDbParameter parameter = null;

            if (typeName == "String")
            {
                if (columnLen == "")
                    parameter = new OleDbParameter(columnName, OleDbType.VarChar);
                else
                    parameter = new OleDbParameter(columnName, OleDbType.VarChar, Convert.ToInt16(columnLen));

                if (columnValue != null)
                    parameter.Value = columnValue;
            }
            else if (typeName == "Decimal")
            {
                parameter = new OleDbParameter(columnName, OleDbType.Decimal);

                if (columnValue != null)
                    parameter.Value = Convert.ToDecimal(columnValue);
            }
            else if (typeName == "Int32")
            {
                parameter = new OleDbParameter(columnName, OleDbType.Integer);

                if (columnValue != null)
                    parameter.Value = Convert.ToInt32(columnValue);
            }
            else if (typeName == "DateTime")
            {
                parameter = new OleDbParameter(columnName, OleDbType.Date);

                if (columnValue != null)
                    parameter.Value = Convert.ToDateTime(columnValue);
            }
            else
            {
                throw new Exception("DDO的数据类型超出了定义！");
            }


            if (paraType.Equals("Input", System.StringComparison.OrdinalIgnoreCase))
                parameter.Direction = ParameterDirection.Input;
            else if (paraType.Equals("Output", System.StringComparison.OrdinalIgnoreCase))
                parameter.Direction = ParameterDirection.Output;
            else if (paraType.Equals("InputOutput", System.StringComparison.OrdinalIgnoreCase))
                parameter.Direction = ParameterDirection.InputOutput;
            else if (paraType.Equals("ReturnValue", System.StringComparison.OrdinalIgnoreCase))
                parameter.Direction = ParameterDirection.ReturnValue;
            else
                throw new Exception("DDO的参数类型超出了定义！");

            AddDBParameter(parameter);
        }

        /************************************************************************
         * 为Command的对象添加DB参数
         * @param OleDbParameter parameter   DB参数对象
         * @return 		                     void
         ************************************************************************/
        public void AddDBParameter(OleDbParameter parameter)
        {
            sqlCommand.Parameters.Add(parameter);
        }

        /************************************************************************
         * 从Command的Parameters对象中获取参数的值
         * @return 		                     ArrayList
         ************************************************************************/
        public ArrayList GetDBParameter()
        {
            ArrayList list = new ArrayList();
            for (int i = 0; i < sqlCommand.Parameters.Count; i++)
            {
                list.Add(sqlCommand.Parameters[i].Value);
            }

            return list;
        }

        /************************************************************************
         * 从数据库中读出数据、返回数据
         * @param String sql                 执行语句
         * @return 		                     DataTable
         ************************************************************************/
        public DataTable ExecuteReader(String sql)
        {
            DataTable dataTable = new DataTable();
            try
            {
                sqlCommand.CommandText = sql;
                OleDbDataReader sqlReader = sqlCommand.ExecuteReader();

                if (sqlReader != null)
                {
                    dataTable.Load(sqlReader);
                    sqlReader.Close();
                }
                else
                    throw new InvalidOperationException("ExecuteReader返回值为null");
            }
            catch (Exception e)
            {
                throw e;
            }

            return dataTable;
        }

        /************************************************************************
         * 执行语句、返回影响的行数
         * @param String sql                 执行语句
         * @return 		                     int
         ************************************************************************/
        public int ExecuteNonQuery(String sql)
        {
            int rows;
            try
            {
                sqlCommand.CommandText = sql;
                rows = sqlCommand.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                throw e;
            }
            return rows;
        }

    }
}
