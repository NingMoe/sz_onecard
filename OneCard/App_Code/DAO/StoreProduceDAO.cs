using System;
using System.Data;
using System.Configuration;
using Master;
using System.Data.SqlClient;
using System.Collections;
using System.Reflection;
using System.IO;


namespace DAO
{
    public class StoreProduceDAO
    {
        public DDOBase Excute(CmnContext context, DDOBase a_ddoBaseIn, Type type)
        {
            DDOBase ddoBaseOut = null;

            StoreProScene storeProScene = new StoreProScene();
            
            ddoBaseOut = (DDOBase)storeProScene.Execute(context, a_ddoBaseIn, type);

            return ddoBaseOut;

        }

    }
}
