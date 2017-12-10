using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ×÷·Ï
     public class SP_IT_AdoptPDO : PDOBase
     {
         public SP_IT_AdoptPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_Adopt",7);
               InitEnd();
          }

     }
}


