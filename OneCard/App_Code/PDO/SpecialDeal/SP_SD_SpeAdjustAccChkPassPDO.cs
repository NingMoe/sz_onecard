using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // ����������ͨ��
     public class SP_SD_SpeAdjustAccChkPassPDO : PDOBase
     {
          public SP_SD_SpeAdjustAccChkPassPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SpeAdjustAccChkPass",6);

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


