using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 验证是否是市民卡
     public class SP_SmkCheckPDO : PDOBase
     {
         public SP_SmkCheckPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_SmkCheck", 6);

               AddField("@CARDNO", "string", "16", "input");

               InitEnd();
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

     }
}
