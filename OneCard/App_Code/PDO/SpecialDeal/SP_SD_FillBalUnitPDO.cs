using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // �����㵥Ԫ
     public class SP_SD_FillBalUnitPDO : PDOBase
     {
          public SP_SD_FillBalUnitPDO()
          {
          }

          protected override void Init()
          {
               InitBegin("SP_SD_FillBalUnit",7);

               AddField("@yearmonth", "String", "6", "input");
               AddField("@balUnitNo", "String", "8", "input");

               InitEnd();
          }

          // ��������
          public String yearmonth
          {
              get { return  GetString("yearmonth"); }
              set { SetString("yearmonth",value); }
          }
          public String balUnitNo
          {
              get { return GetString("balUnitNo"); }
              set { SetString("balUnitNo", value); }
          }
      }
}
