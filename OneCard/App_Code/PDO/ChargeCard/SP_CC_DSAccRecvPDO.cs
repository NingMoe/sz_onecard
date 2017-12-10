using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // 充值卡到帐设置
     public class SP_CC_DSAccRecvPDO : PDOBase
     {
          public SP_CC_DSAccRecvPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_DSAccRecv",6);

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


