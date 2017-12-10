using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 特殊圈存作废
     public class SP_PB_SpeloadcancelPDO : PDOBase
     {
          public SP_PB_SpeloadcancelPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Speloadcancel",6);

               AddField("@TRADEID", "string", "16", "input");

               InitEnd();
          }

          // 交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


