using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 更新写卡台帐
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

          // 交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 联机交易序号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

     }
}


