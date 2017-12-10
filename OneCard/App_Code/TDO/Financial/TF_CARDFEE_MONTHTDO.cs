using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 卡费月汇总表
     public class TF_CARDFEE_MONTHTDO : DDOBase
     {
          public TF_CARDFEE_MONTHTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARDFEE_MONTH";

               columns = new String[9][];
               columns[0] = new String[]{"COLLEXTDATE", "string"};
               columns[1] = new String[]{"USEDFEE", "Int32"};
               columns[2] = new String[]{"USEDFEETIMES", "Int32"};
               columns[3] = new String[]{"CARDCOST", "Int32"};
               columns[4] = new String[]{"CARDCOSTTIMES", "Int32"};
               columns[5] = new String[]{"SERVICEMONEY1", "Int32"};
               columns[6] = new String[]{"SERVICEMONEY1TIMES", "Int32"};
               columns[7] = new String[]{"SERVICEMONEY2", "Int32"};
               columns[8] = new String[]{"SERVICEMONEY2TIMES", "Int32"};

               columnKeys = new String[]{
                   "COLLEXTDATE",
               };


               array = new String[9];
               hash.Add("COLLEXTDATE", 0);
               hash.Add("USEDFEE", 1);
               hash.Add("USEDFEETIMES", 2);
               hash.Add("CARDCOST", 3);
               hash.Add("CARDCOSTTIMES", 4);
               hash.Add("SERVICEMONEY1", 5);
               hash.Add("SERVICEMONEY1TIMES", 6);
               hash.Add("SERVICEMONEY2", 7);
               hash.Add("SERVICEMONEY2TIMES", 8);
          }

          // 汇总时间
          public string COLLEXTDATE
          {
              get { return  Getstring("COLLEXTDATE"); }
              set { Setstring("COLLEXTDATE",value); }
          }

          // 卡使用费
          public Int32 USEDFEE
          {
              get { return  GetInt32("USEDFEE"); }
              set { SetInt32("USEDFEE",value); }
          }

          // 卡使用费笔数
          public Int32 USEDFEETIMES
          {
              get { return  GetInt32("USEDFEETIMES"); }
              set { SetInt32("USEDFEETIMES",value); }
          }

          // 售卡费
          public Int32 CARDCOST
          {
              get { return  GetInt32("CARDCOST"); }
              set { SetInt32("CARDCOST",value); }
          }

          // 售卡费笔数
          public Int32 CARDCOSTTIMES
          {
              get { return  GetInt32("CARDCOSTTIMES"); }
              set { SetInt32("CARDCOSTTIMES",value); }
          }

          // 退卡费1
          public Int32 SERVICEMONEY1
          {
              get { return  GetInt32("SERVICEMONEY1"); }
              set { SetInt32("SERVICEMONEY1",value); }
          }

          // 退卡费1笔数
          public Int32 SERVICEMONEY1TIMES
          {
              get { return  GetInt32("SERVICEMONEY1TIMES"); }
              set { SetInt32("SERVICEMONEY1TIMES",value); }
          }

          // 退卡费2
          public Int32 SERVICEMONEY2
          {
              get { return  GetInt32("SERVICEMONEY2"); }
              set { SetInt32("SERVICEMONEY2",value); }
          }

          // 退卡费2笔数
          public Int32 SERVICEMONEY2TIMES
          {
              get { return  GetInt32("SERVICEMONEY2TIMES"); }
              set { SetInt32("SERVICEMONEY2TIMES",value); }
          }

     }
}


