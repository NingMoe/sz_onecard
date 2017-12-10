using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC卡电子钱包退值表
     public class TF_F_CARDEWALLETACC_BACKTDO : DDOBase
     {
          public TF_F_CARDEWALLETACC_BACKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDEWALLETACC_BACK";

               columns = new String[7][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"JUDGEMONEY", "Int32"};
               columns[2] = new String[]{"JUDGEMODE", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[7];
               hash.Add("CARDNO", 0);
               hash.Add("JUDGEMONEY", 1);
               hash.Add("JUDGEMODE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 判断金额
          public Int32 JUDGEMONEY
          {
              get { return  GetInt32("JUDGEMONEY"); }
              set { SetInt32("JUDGEMONEY",value); }
          }

          // 判断方式
          public string JUDGEMODE
          {
              get { return  Getstring("JUDGEMODE"); }
              set { Setstring("JUDGEMODE",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


