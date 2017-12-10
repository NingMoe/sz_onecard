using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 资料批量更新
     public class SP_GC_InfoUpdatePDO : PDOBase
     {
          public SP_GC_InfoUpdatePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_InfoUpdate",6);

               AddField("@sessionId", "String", "32", "input");

               InitEnd();
          }

          // 会话编号
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

     }
}


