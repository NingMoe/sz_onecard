using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 批量开卡
     public class SP_GC_OpenPDO : PDOBase
     {
          public SP_GC_OpenPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_Open",8);

               AddField("@sessionId", "String", "32", "input");
               AddField("@groupCode", "string", "4", "input");
               AddField("@oldFlag", "string", "2", "input");

               InitEnd();
          }

          // 会话编号
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

          // 集团客户
          public string groupCode
          {
              get { return  Getstring("groupCode"); }
              set { Setstring("groupCode",value); }
          }

          // 是否旧卡开卡
          public string oldFlag
          {
              get { return  Getstring("oldFlag"); }
              set { Setstring("oldFlag",value); }
          }

     }
}


