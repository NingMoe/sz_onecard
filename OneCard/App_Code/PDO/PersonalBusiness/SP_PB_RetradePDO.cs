using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ²¹Ð´¿¨
     public class SP_PB_RetradePDO : PDOBase
     {
          public SP_PB_RetradePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Retrade",8);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@ID", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ¿¨ºÅ
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ²¹Ð´Á÷Ë®ºÅ
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ·µ»Ø½»Ò×ÐòÁÐºÅ
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


