using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 银行编码表
     public class TD_M_BANKTDO : DDOBase
     {
          public TD_M_BANKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_BANK";

               columns = new String[7][];
               columns[0] = new String[]{"BANKCODE", "string"};
               columns[1] = new String[]{"BANK", "String"};
               columns[2] = new String[]{"BANKADDR", "String"};
               columns[3] = new String[]{"BANKPHONE", "String"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "BANKCODE",
               };


               array = new String[7];
               hash.Add("BANKCODE", 0);
               hash.Add("BANK", 1);
               hash.Add("BANKADDR", 2);
               hash.Add("BANKPHONE", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // 银行编号
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // 银行名称
          public String BANK
          {
              get { return  GetString("BANK"); }
              set { SetString("BANK",value); }
          }

          // 银行地址
          public String BANKADDR
          {
              get { return  GetString("BANKADDR"); }
              set { SetString("BANKADDR",value); }
          }

          // 联系方式
          public String BANKPHONE
          {
              get { return  GetString("BANKPHONE"); }
              set { SetString("BANKPHONE",value); }
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


