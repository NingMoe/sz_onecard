using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // ���������������
     public class SP_GC_OpenFiApprovalPDO : PDOBase
     {
          public SP_GC_OpenFiApprovalPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_OpenFiApproval",7);

               AddField("@sessionId", "String", "32", "input");
               AddField("@stateCode", "string", "1", "input");

               InitEnd();
          }

          // �Ự���
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

          // ״̬����
          public string stateCode
          {
              get { return  Getstring("stateCode"); }
              set { Setstring("stateCode",value); }
          }

     }
}


