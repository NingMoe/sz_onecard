using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 批量充值财务审核
     public class SP_GC_ChargeFiApprovalPDO : PDOBase
     {
          public SP_GC_ChargeFiApprovalPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_ChargeFiApproval",7);

               AddField("@sessionId", "String", "32", "input");
               AddField("@stateCode", "string", "1", "input");

               InitEnd();
          }

          // 会话编号
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

          // 状态编码
          public string stateCode
          {
              get { return  Getstring("stateCode"); }
              set { Setstring("stateCode",value); }
          }

     }
}


