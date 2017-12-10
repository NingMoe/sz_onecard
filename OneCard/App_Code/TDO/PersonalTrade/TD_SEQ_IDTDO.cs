using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 业务流水号取值表
     public class TD_SEQ_IDTDO : DDOBase
     {
          public TD_SEQ_IDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_SEQ_ID";

               columns = new String[1][];
               columns[0] = new String[]{"TRADEID", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[1];
               hash.Add("TRADEID", 0);
          }

          // 业务流水号
          public Int32 TRADEID
          {
              get { return  GetInt32("TRADEID"); }
              set { SetInt32("TRADEID",value); }
          }

     }
}


