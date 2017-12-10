using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 集团客户信息审批作废
     public class SP_PS_GroupCustApprovalCancelPDO : PDOBase
     {
          public SP_PS_GroupCustApprovalCancelPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_GroupCustApprovalCancel",5);


               InitEnd();
          }

     }
}


