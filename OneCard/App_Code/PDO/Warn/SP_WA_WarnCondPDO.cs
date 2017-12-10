using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Warn
{
     public class SP_WA_WarnCondPDO : PDOBase
     {
         public SP_WA_WarnCondPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_WA_WARNCOND", 10 + 5);

               AddField("@funcCode", "String", "16", "input");
               AddField("@oldCondCode", "String", "4", "input");
               AddField("@condCode", "String", "4", "input");
               AddField("@condName", "String", "100", "input");
               AddField("@condRange", "String", "1", "input");
               AddField("@warnType", "String", "16", "input");
               AddField("@warnLevel", "String", "1", "input");
               AddField("@condCate", "String", "1", "input");
               AddField("@condStr", "string", "256", "input");
               AddField("@remark", "string", "100", "input");

               InitEnd();
          }

          public String funcCode
          {
              get { return  GetString("funcCode"); }
              set { SetString("funcCode",value); }
          }

         public String oldCondCode
         {
             get { return GetString("oldCondCode"); }
             set { SetString("oldCondCode", value); }
         }

          public String condCode
          {
              get { return  GetString("condCode"); }
              set { SetString("condCode",value); }
          }

          public string condName
          {
              get { return  Getstring("condName"); }
              set { Setstring("condName",value); }
          }

         public string condRange
          {
              get { return Getstring("condRange"); }
              set { Setstring("condRange", value); }
          }

          public string warnType
          {
              get { return Getstring("warnType"); }
              set { Setstring("warnType", value); }
          }
          
         public string warnLevel
          {
              get { return Getstring("warnLevel"); }
              set { Setstring("warnLevel", value); }
          }

         public string condCate
          {
              get { return Getstring("condCate"); }
              set { Setstring("condCate", value); }
          }

          public string condStr
          {
              get { return  Getstring("condStr"); }
              set { Setstring("condStr",value); }
          }

          public string remark
          {
              get { return  Getstring("remark"); }
              set { Setstring("remark",value); }
          }


     }
}


