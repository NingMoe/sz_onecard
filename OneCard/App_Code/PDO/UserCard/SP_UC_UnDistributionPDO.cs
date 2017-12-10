using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // 取消分配
     public class SP_UC_UnDistributionPDO : PDOBase
     {
          public SP_UC_UnDistributionPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_UnDistribution",6);

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


