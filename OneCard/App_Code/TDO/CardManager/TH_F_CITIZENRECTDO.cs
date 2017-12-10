using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 市民卡资料历史表
     public class TH_F_CITIZENRECTDO : DDOBase
     {
          public TH_F_CITIZENRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TH_F_CITIZENREC";

               columns = new String[19][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"UPDATETIME", "DateTime"};
               columns[2] = new String[]{"CARDSFZ", "String"};
               columns[3] = new String[]{"CARDXM", "String"};
               columns[4] = new String[]{"XB", "string"};
               columns[5] = new String[]{"YHHM", "String"};
               columns[6] = new String[]{"SBHM", "String"};
               columns[7] = new String[]{"YBGRZH", "String"};
               columns[8] = new String[]{"MAKEDATE", "DateTime"};
               columns[9] = new String[]{"ZTBM", "string"};
               columns[10] = new String[]{"STSJ", "DateTime"};
               columns[11] = new String[]{"CARDDW", "String"};
               columns[12] = new String[]{"LDNO", "Decimal"};
               columns[13] = new String[]{"LDDATE", "DateTime"};
               columns[14] = new String[]{"UPDATESTAFFNO", "string"};
               columns[15] = new String[]{"RSRV1", "String"};
               columns[16] = new String[]{"RSRV2", "String"};
               columns[17] = new String[]{"RSRV3", "DateTime"};
               columns[18] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "UPDATETIME",
               };


               array = new String[19];
               hash.Add("CARDNO", 0);
               hash.Add("UPDATETIME", 1);
               hash.Add("CARDSFZ", 2);
               hash.Add("CARDXM", 3);
               hash.Add("XB", 4);
               hash.Add("YHHM", 5);
               hash.Add("SBHM", 6);
               hash.Add("YBGRZH", 7);
               hash.Add("MAKEDATE", 8);
               hash.Add("ZTBM", 9);
               hash.Add("STSJ", 10);
               hash.Add("CARDDW", 11);
               hash.Add("LDNO", 12);
               hash.Add("LDDATE", 13);
               hash.Add("UPDATESTAFFNO", 14);
               hash.Add("RSRV1", 15);
               hash.Add("RSRV2", 16);
               hash.Add("RSRV3", 17);
               hash.Add("REMARK", 18);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 变更时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 身份证号
          public String CARDSFZ
          {
              get { return  GetString("CARDSFZ"); }
              set { SetString("CARDSFZ",value); }
          }

          // 姓名
          public String CARDXM
          {
              get { return  GetString("CARDXM"); }
              set { SetString("CARDXM",value); }
          }

          // 性别
          public string XB
          {
              get { return  Getstring("XB"); }
              set { Setstring("XB",value); }
          }

          // 银行号
          public String YHHM
          {
              get { return  GetString("YHHM"); }
              set { SetString("YHHM",value); }
          }

          // 社保号
          public String SBHM
          {
              get { return  GetString("SBHM"); }
              set { SetString("SBHM",value); }
          }

          // 医保个人账户
          public String YBGRZH
          {
              get { return  GetString("YBGRZH"); }
              set { SetString("YBGRZH",value); }
          }

          // 制卡时间
          public DateTime MAKEDATE
          {
              get { return  GetDateTime("MAKEDATE"); }
              set { SetDateTime("MAKEDATE",value); }
          }

          // 状态编码
          public string ZTBM
          {
              get { return  Getstring("ZTBM"); }
              set { Setstring("ZTBM",value); }
          }

          // 状态更新时间
          public DateTime STSJ
          {
              get { return  GetDateTime("STSJ"); }
              set { SetDateTime("STSJ",value); }
          }

          // 单位
          public String CARDDW
          {
              get { return  GetString("CARDDW"); }
              set { SetString("CARDDW",value); }
          }

          // 领单号
          public Decimal LDNO
          {
              get { return  GetDecimal("LDNO"); }
              set { SetDecimal("LDNO",value); }
          }

          // 领用时间
          public DateTime LDDATE
          {
              get { return  GetDateTime("LDDATE"); }
              set { SetDateTime("LDDATE",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
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

          // 备用3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


