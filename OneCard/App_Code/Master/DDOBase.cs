/************************************************************************
 * DDOBase
 * 类名:DDO基类
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次开发

 ************************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Collections;

namespace Master
{
    public class DDOBase
    {

        //库名
        protected String dbConnDataBase;
        public String DBConnDataBase
        {
            get { return dbConnDataBase; }
            set { dbConnDataBase = value; }
        }

        //用户名

        protected String dbConnUserName;
        public String DBConnUserName
        {
            get { return dbConnUserName; }
            set { dbConnUserName = value; }
        }

        //表名
        protected String tableName;
        public String TableName
        {
            get { return tableName; }
        }

        //全表名

        protected String fullTableName;
        public String FullTableName
        {
            get {

                fullTableName = tableName;
                bool hasUserName = false;

                if (dbConnUserName != null && !dbConnUserName.Trim().Equals(""))
                {
                    String strUserName = ConfigurationManager.AppSettings.Get(dbConnUserName.Trim());

                    if (strUserName != null && !strUserName.Trim().Equals(""))
                    {
                        fullTableName = strUserName + "." + fullTableName;
                        hasUserName = true;
                    }
                }

                if (dbConnDataBase != null && !dbConnDataBase.Trim().Equals(""))
                {
                    String strDataBase = ConfigurationManager.AppSettings.Get(dbConnDataBase.Trim());

                    if (strDataBase != null && !strDataBase.Trim().Equals(""))
                    {
                        if(hasUserName)
                            fullTableName = strDataBase + "." + fullTableName;
                        else
                            fullTableName = strDataBase + ".." + fullTableName;
                    }
                }

                return fullTableName; 
            }
        }

        //主键
        protected String[] columnKeys;
        public String[] ColumnKeys
        {
            get { return columnKeys; }
        }

        //列类型
        protected String[][] columns;
        public String[][] Columns
        {
            get { return columns; }
            set { columns = value;}
        }
	    
        protected DataTable dataTable;

        //列的索引
        protected Hashtable hash = new Hashtable();
        public Hashtable Hash
        {
            get { return hash; }
        }

        //值

        protected Array array;
        public Array ArrayList
        {
            get { return array; }
        }
	
        protected virtual void Init()
        {
        }
        protected virtual void Init(String pdoName)
        {
        }
        protected virtual void InitComplete()
        {
        }

        //检查值是否为空

        public Boolean IsEmpty(String strInput)
        {
            Object getvalue = array.GetValue(Convert.ToInt16(hash[strInput]));
            if (getvalue == null || getvalue.ToString() == "")
                return true;
            else
                return false;
        }

        //得到String值

        public String GetString(String strInput)
        { 
            return GetStringNoTrim(strInput).Trim();
        }

        public String GetStringNoTrim(String strInput)
        {
            object ddoProperty = array.GetValue(Convert.ToInt16(hash[strInput]));
            if (ddoProperty != null)
            {
                return ddoProperty.ToString();
            }
            else
            {
                return string.Empty;
            }
        }

        //设置String值


        protected void SetString(String strInput, String value)
        {
            array.SetValue(value, Convert.ToInt16(hash[strInput]));
        }

        //设置String值

        protected void Setstring(String strInput,String value)
        {
            array.SetValue(value, Convert.ToInt16(hash[strInput]));
        }

        //得到String值


        public String Getstring(String strInput)
        {
            return array.GetValue(Convert.ToInt16(hash[strInput])).ToString().Trim();
        }



        //得到Decimal值

        protected Decimal GetDecimal(String strInput)
        {
            return Convert.ToDecimal(array.GetValue(Convert.ToInt16(hash[strInput])));
        }

        //设置Decimal值

        protected void SetDecimal(String strInput, Decimal value)
        {
            array.SetValue(value.ToString(), Convert.ToInt16(hash[strInput]));
        }

        //得到DateTime值

        protected DateTime GetDateTime(String strInput)
        {
            return Convert.ToDateTime(array.GetValue(Convert.ToInt16(hash[strInput])));
        }

        //设置DateTime值

        protected void SetDateTime(String strInput, DateTime value)
        {
            array.SetValue(value.ToString(), Convert.ToInt16(hash[strInput]));
        }

        //得到Int值

        protected Int32 GetInt32(String strInput)
        {
            return Convert.ToInt32(array.GetValue(Convert.ToInt16(hash[strInput])));
        }

        //设置Int值

        protected void SetInt32(String strInput, Int32 value)
        {
            array.SetValue(value.ToString(), Convert.ToInt16(hash[strInput]));
        }

        //设置DataTable
        public void setDataTable(DataTable newDataTable)
        {
            dataTable = newDataTable;
        }

        //设置DDO值

        public void setArray(Array inputArray)
        {
            array = inputArray;
        }

        
        public DDOBase()
        {
            Init();
            InitComplete();
        }

        public DDOBase(String pdoName)
        {
            Init(pdoName);
            InitComplete();
        }
    }
}
