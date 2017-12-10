using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // ������
     public class SP_UC_DistributionPDO : PDOBase
     {
          public SP_UC_DistributionPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_Distribution",7);

               AddField("@sessionId", "String", "32", "input");
               AddField("@assignedStaff", "string", "6", "input");

               InitEnd();
          }

          // �Ự���
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

          // ����Ա��
          public string assignedStaff
          {
              get { return  Getstring("assignedStaff"); }
              set { Setstring("assignedStaff",value); }
          }

     }
}


