using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Warn
{
     public class SP_WA_WarnManagePDO : PDOBase
     {
        public SP_WA_WarnManagePDO()
        {
        }

        protected override void Init()
        {
           InitBegin("SP_WA_WarnManage",5 + 5);

           AddField("@funcCode" , "String", "16", "input");
           AddField("@backWhy"  , "String", "1" , "input");
           AddField("@condCode" , "String", "16", "input");
           AddField("@warnType" , "String", "4" , "input");
           AddField("@warnLevel", "String", "1" , "input");

           InitEnd();
        }

        public string funcCode
        {
          get { return  GetString("funcCode"); }
          set { SetString("funcCode",value); }
        }

        public string backWhy
        {
            get { return GetString("backWhy"); }
            set { SetString("backWhy", value); }
        }

        public string condCode
        {
            get { return GetString("condCode"); }
            set { SetString("condCode", value); }
        }

        public string warnType
        {
            get { return GetString("warnType"); }
            set { SetString("warnType", value); }
        }

        public string warnLevel
        {
            get { return GetString("warnLevel"); }
            set { SetString("warnLevel", value); }
        }

     }
}


