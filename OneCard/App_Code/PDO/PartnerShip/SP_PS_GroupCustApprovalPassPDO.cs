using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���ſͻ���Ϣ����ͨ��
     public class SP_PS_GroupCustApprovalPassPDO : PDOBase
     {
          public SP_PS_GroupCustApprovalPassPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_GroupCustApprovalPass",5);


               InitEnd();
          }

     }
}


