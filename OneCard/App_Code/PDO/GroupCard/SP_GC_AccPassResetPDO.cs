using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // √‹¬Î÷ÿ÷√
     public class SP_GC_AccPassResetPDO : PDOBase
     {
          public SP_GC_AccPassResetPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_AccPassReset",6);

               AddField("@cardNo", "String", "16", "input");

               InitEnd();
          }

          // ≤Ÿ◊˜ø®∫≈
          public String cardNo
          {
              get { return  GetString("cardNo"); }
              set { SetString("cardNo",value); }
          }

     }
}


