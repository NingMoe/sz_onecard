using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 充值对外认证随机数表
     public class TD_B_RANDOMTDO : DDOBase
     {
          public TD_B_RANDOMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_B_RANDOM";

               columns = new String[6][];
               columns[0] = new String[]{"RANDOM", "string"};
               columns[1] = new String[]{"STATUS", "string"};
               columns[2] = new String[]{"RSRVSTRING1", "string"};
               columns[3] = new String[]{"RSRVSTRING2", "string"};
               columns[4] = new String[]{"RSRVSTRING3", "string"};
               columns[5] = new String[]{"RSRVSTRING4", "string"};

               columnKeys = new String[]{
                   "RANDOM",
               };


               array = new String[6];
               hash.Add("RANDOM", 0);
               hash.Add("STATUS", 1);
               hash.Add("RSRVSTRING1", 2);
               hash.Add("RSRVSTRING2", 3);
               hash.Add("RSRVSTRING3", 4);
               hash.Add("RSRVSTRING4", 5);
          }

          // 随机数
          public string RANDOM
          {
              get { return  Getstring("RANDOM"); }
              set { Setstring("RANDOM",value); }
          }

          // 状态
          public string STATUS
          {
              get { return  Getstring("STATUS"); }
              set { Setstring("STATUS",value); }
          }

          // 备用1
          public string RSRVSTRING1
          {
              get { return  Getstring("RSRVSTRING1"); }
              set { Setstring("RSRVSTRING1",value); }
          }

          // 备用2
          public string RSRVSTRING2
          {
              get { return  Getstring("RSRVSTRING2"); }
              set { Setstring("RSRVSTRING2",value); }
          }

          // 备用3
          public string RSRVSTRING3
          {
              get { return  Getstring("RSRVSTRING3"); }
              set { Setstring("RSRVSTRING3",value); }
          }

          // 备用4
          public string RSRVSTRING4
          {
              get { return  Getstring("RSRVSTRING4"); }
              set { Setstring("RSRVSTRING4",value); }
          }

     }
}


