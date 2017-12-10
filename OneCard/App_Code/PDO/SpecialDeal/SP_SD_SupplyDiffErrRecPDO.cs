using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // 充值比对消费信息回收
     public class SP_SD_SupplyDiffErrRecPDO : PDOBase
     {
          public SP_SD_SupplyDiffErrRecPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SupplyDiffErrRec",7);

               AddField("@renewRemark", "String", "150", "input");
               AddField("@sessionID", "String", "32", "input");

               InitEnd();
          }

          // 回收说明
          public String renewRemark
          {
              get { return  GetString("renewRemark"); }
              set { SetString("renewRemark",value); }
          }

          // 会话ID
          public String sessionID
          {
              get { return  GetString("sessionID"); }
              set { SetString("sessionID",value); }
          }

     }
}


