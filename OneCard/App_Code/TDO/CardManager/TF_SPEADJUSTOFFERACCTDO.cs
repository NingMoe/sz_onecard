using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 特殊调帐可充值账户表
     public class TF_SPEADJUSTOFFERACCTDO : DDOBase
     {
          public TF_SPEADJUSTOFFERACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SPEADJUSTOFFERACC";

               columns = new String[6][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"OFFERMONEY", "Int32"};
               columns[2] = new String[]{"TOTALSUPPLYTIMES", "Int32"};
               columns[3] = new String[]{"TOTALSUPPLYMONEY", "Int32"};
               columns[4] = new String[]{"RSRV1", "String"};
               columns[5] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[6];
               hash.Add("CARDNO", 0);
               hash.Add("OFFERMONEY", 1);
               hash.Add("TOTALSUPPLYTIMES", 2);
               hash.Add("TOTALSUPPLYMONEY", 3);
               hash.Add("RSRV1", 4);
               hash.Add("RSRV2", 5);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 可充金额
          public Int32 OFFERMONEY
          {
              get { return  GetInt32("OFFERMONEY"); }
              set { SetInt32("OFFERMONEY",value); }
          }

          // 总充值次数
          public Int32 TOTALSUPPLYTIMES
          {
              get { return  GetInt32("TOTALSUPPLYTIMES"); }
              set { SetInt32("TOTALSUPPLYTIMES",value); }
          }

          // 总充值金额
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // 备用2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

     }
}


