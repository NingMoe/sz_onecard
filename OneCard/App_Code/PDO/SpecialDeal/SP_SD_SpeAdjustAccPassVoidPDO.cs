using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // ��������������
     public class SP_SD_SpeAdjustAccPassVoidPDO : PDOBase
     {
         public SP_SD_SpeAdjustAccPassVoidPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_SD_SpeAdjustAccPassVoid", 6);

               AddField("@sessionID", "String", "32", "input");

               InitEnd();
          }

          // �ỰID
          public String sessionID
          {
              get { return  GetString("sessionID"); }
              set { SetString("sessionID",value); }
          }

     }
}


