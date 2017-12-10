using System;
using System.Data;
using System.Configuration;
using Master;
using System.Data.SqlClient;
using System.Resources;
using Common;
using System.Collections;



namespace DAO
{
    public class SelectDAO
    {
        public DDOBase selDDO(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey, Type type)
        {
            return selDDO(context, a_ddoBaseIn, SqlKey, type, null);
        }

        public DDOBase selDDO(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey, Type type, String Sql)
        {
            DDOBase ddoBaseOut = null;

            if (Sql == null)
            {
                Sql = DealString.GetResourceValue(context.ResourcePath, "SqlCondition", SqlKey);
            }

            SelectScene selectScene = new SelectScene();

            DataTable dataTable = selectScene.Execute(context, a_ddoBaseIn, Sql,0);

            if (dataTable.Rows.Count == 0)
            {
                ;
            }
            else if (dataTable.Rows.Count == 1)
            {
                ddoBaseOut = (DDOBase)Activator.CreateInstance(type);
                ddoBaseOut.setArray(dataTable.Rows[0].ItemArray);
            }
            else
            {
                //context.AplException();
            }

            return ddoBaseOut;
        }

        public Object selDDOArr(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey, Type type)
        {
            return selDDOArr(context, a_ddoBaseIn, SqlKey, type, null);
        }

        public Object selDDOArr(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey, Type type, String Sql)
        {
            if (Sql == null)
            {
                Sql = DealString.GetResourceValue(context.ResourcePath, "SqlCondition", SqlKey);
            }

            SelectScene selectScene = new SelectScene();

            Object arrObject = selectScene.Execute(context, a_ddoBaseIn, Sql, type);

            return arrObject;
        }

        public DataTable selDataTable(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey)
        {
            return selDataTable(context, a_ddoBaseIn, SqlKey, null,0);
        }

        public DataTable selDataTable(CmnContext context, DDOBase a_ddoBaseIn, String SqlKey, String Sql, int countsize)
        {
            if (Sql == null)
            {
                Sql = DealString.GetResourceValue(context.ResourcePath, "SqlCondition", SqlKey);
            }

            SelectScene selectScene = new SelectScene();

            DataTable dataTable = selectScene.Execute(context, a_ddoBaseIn, Sql,countsize);

            return dataTable;
        }

    }
}
