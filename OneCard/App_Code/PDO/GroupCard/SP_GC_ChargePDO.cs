using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 批量充值
     public class SP_GC_ChargePDO : PDOBase
     {
          public SP_GC_ChargePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_Charge",7);

               AddField("@sessionId", "String", "32", "input");
               AddField("@groupCode", "string", "4", "input");

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

     }
}


