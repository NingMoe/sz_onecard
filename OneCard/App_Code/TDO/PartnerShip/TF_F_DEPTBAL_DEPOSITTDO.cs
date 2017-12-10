using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 网点结算单元保证金账户表
     public class TF_F_DEPTBAL_DEPOSITTDO : DDOBase
     {
          public TF_F_DEPTBAL_DEPOSITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_DEPTBAL_DEPOSIT";

               columns = new String[8][];
               columns[0] = new String[]{"DBALUNITNO", "string"};
               columns[1] = new String[]{"DEPOSIT", "Int32"};
               columns[2] = new String[]{"USABLEVALUE", "Int32"};
               columns[3] = new String[]{"STOCKVALUE", "Int32"};
               columns[4] = new String[]{"ACCSTATECODE", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DBALUNITNO",
               };


               array = new String[8];
               hash.Add("DBALUNITNO", 0);
               hash.Add("DEPOSIT", 1);
               hash.Add("USABLEVALUE", 2);
               hash.Add("STOCKVALUE", 3);
               hash.Add("ACCSTATECODE", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // 结算单元编码
          public string DBALUNITNO
          {
              get { return  Getstring("DBALUNITNO"); }
              set { Setstring("DBALUNITNO",value); }
          }

          // 保证金余额
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // 可领卡价值额度
          public Int32 USABLEVALUE
          {
              get { return  GetInt32("USABLEVALUE"); }
              set { SetInt32("USABLEVALUE",value); }
          }

          // 网点剩余卡价值
          public Int32 STOCKVALUE
          {
              get { return  GetInt32("STOCKVALUE"); }
              set { SetInt32("STOCKVALUE",value); }
          }

          // 帐户状态
          public string ACCSTATECODE
          {
              get { return  Getstring("ACCSTATECODE"); }
              set { Setstring("ACCSTATECODE",value); }
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


