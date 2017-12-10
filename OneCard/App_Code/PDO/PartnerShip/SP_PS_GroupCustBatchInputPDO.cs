using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 集团客户批量录入
     public class SP_PS_GroupCustBatchInputPDO : PDOBase
     {
          public SP_PS_GroupCustBatchInputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_GroupCustBatchInput",6);

               AddField("@sessionId", "String", "32", "input");

               InitEnd();
          }

          // 会话ID
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

     }
}


