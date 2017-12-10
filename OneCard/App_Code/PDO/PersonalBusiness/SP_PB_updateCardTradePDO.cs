using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ����д��̨��
     public class SP_PB_updateCardTradePDO : PDOBase
     {
          public SP_PB_updateCardTradePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_updateCardTrade",7);

               AddField("@TRADEID", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "4", "input");

               InitEnd();
          }

          // �������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

     }
}


