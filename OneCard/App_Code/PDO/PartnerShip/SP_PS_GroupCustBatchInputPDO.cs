using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���ſͻ�����¼��
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

          // �ỰID
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

     }
}


