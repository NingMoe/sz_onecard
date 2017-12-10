using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 结算单元信息财务审核作废
     public class SP_PS_TransferFiApprovalCancelPDO : PDOBase
     {
          public SP_PS_TransferFiApprovalCancelPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_TransferFiApprovalCancel",6);

               AddField("@tradeId", "string", "16", "input");

               InitEnd();
          }

          // 业务流水号
          public string tradeId
          {
              get { return  Getstring("tradeId"); }
              set { Setstring("tradeId",value); }
          }

     }
}


