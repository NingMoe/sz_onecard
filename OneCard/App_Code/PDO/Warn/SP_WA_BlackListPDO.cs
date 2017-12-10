using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Warn
{
     public class SP_WA_BlackListPDO : PDOBase
     {
          public SP_WA_BlackListPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_WA_BlackList",5 + 5);

               AddField("@funcCode", "String", "16", "input");
               AddField("@oldCardNo", "string", "16", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@warnType", "String", "16", "input");
               AddField("@warnLevel", "String", "1", "input");
               AddField("@remark", "string", "100", "input");

               InitEnd();
          }

          public String funcCode
          {
              get { return  GetString("funcCode"); }
              set { SetString("funcCode",value); }
          }

          public String warnType
          {
              get { return  GetString("warnType"); }
              set { SetString("warnType",value); }
          }
         public string oldCardNo
         {
             get { return Getstring("oldCardNo"); }
             set { Setstring("oldCardNo", value); }
         }

          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

         public string warnLevel
          {
              get { return Getstring("warnLevel"); }
              set { Setstring("warnLevel", value); }
          }

          public string remark
          {
              get { return  Getstring("remark"); }
              set { Setstring("remark",value); }
          }


     }
}


