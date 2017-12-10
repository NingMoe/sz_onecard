using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Warn
{
     public class SP_WA_WarnCond_ANTIPDO : PDOBase
     {
         public SP_WA_WarnCond_ANTIPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_WA_WarnCond_ANTI", 10 + 5);

               AddField("@funcCode", "String", "16", "input");
               AddField("@oldCondCode", "String", "4", "input");
               AddField("@condCode", "String", "4", "input");
               AddField("@condName", "String", "200", "input");
               AddField("@riskGrade", "String", "2", "input");
               AddField("@subjectType", "String", "2", "input");
               AddField("@limitType", "String", "2", "input");
               AddField("@condStr", "string", "2000", "input");
               AddField("@usetag", "string", "1", "input");
               AddField("@remark", "string", "100", "input");
               AddField("@condCate", "String", "2", "input");
               AddField("@dateType", "String", "2", "input");
               AddField("@condWhere", "string", "2000", "input");
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

          public string riskGrade
          {
              get { return Getstring("riskGrade"); }
              set { Setstring("riskGrade", value); }
          }

          public string subjectType
          {
              get { return Getstring("subjectType"); }
              set { Setstring("subjectType", value); }
          }

          public string limitType
          {
              get { return Getstring("limitType"); }
              set { Setstring("limitType", value); }
          }

          public string condStr
          {
              get { return  Getstring("condStr"); }
              set { Setstring("condStr",value); }
          }
          public string usetag
          {
              get { return Getstring("usetag"); }
              set { Setstring("usetag", value); }
          }

          public string remark
          {
              get { return  Getstring("remark"); }
              set { Setstring("remark",value); }
          }

          public string condCate
          {
              get { return Getstring("condCate"); }
              set { Setstring("condCate", value); }
          }
          public string dateType
          {
              get { return Getstring("dateType"); }
              set { Setstring("dateType", value); }
          }
          public string condWhere
          {
              get { return Getstring("condWhere"); }
              set { Setstring("condWhere", value); }
          }
     }
}


