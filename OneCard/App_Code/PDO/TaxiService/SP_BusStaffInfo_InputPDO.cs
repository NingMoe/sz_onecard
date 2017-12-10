using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 司机信息录入
     public class SP_BusStaffInfo_InputPDO : PDOBase
     {
          public SP_BusStaffInfo_InputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_BusStaffInfo_Input",7);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CALLINGNO", "string", "2", "input");

               InitEnd();
          }

          // 司机工号
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

     }
}


