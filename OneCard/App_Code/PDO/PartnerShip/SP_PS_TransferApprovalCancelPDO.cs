using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���㵥Ԫ��Ϣ��������
     public class SP_PS_TransferApprovalCancelPDO : PDOBase
     {
          public SP_PS_TransferApprovalCancelPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_TransferApprovalCancel",6);

               AddField("@tradeId", "string", "16", "input");

               InitEnd();
          }

          // ҵ����ˮ��
          public string tradeId
          {
              get { return  Getstring("tradeId"); }
              set { Setstring("tradeId",value); }
          }

     }
}


