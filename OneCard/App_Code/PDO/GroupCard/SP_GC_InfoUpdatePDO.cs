using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // ������������
     public class SP_GC_InfoUpdatePDO : PDOBase
     {
          public SP_GC_InfoUpdatePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_InfoUpdate",6);

               AddField("@sessionId", "String", "32", "input");

               InitEnd();
          }

          // �Ự���
          public String sessionId
          {
              get { return  GetString("sessionId"); }
              set { SetString("sessionId",value); }
          }

     }
}


