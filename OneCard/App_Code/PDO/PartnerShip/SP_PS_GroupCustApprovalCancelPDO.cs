using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���ſͻ���Ϣ��������
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


