using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 持卡人资料历史表
     public class TH_F_CUSTOMERRECTDO : DDOBase
     {
          public TH_F_CUSTOMERRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TH_F_CUSTOMERREC";

               columns = new String[13][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"UPDATETIME", "DateTime"};
               columns[2] = new String[]{"CUSTNAME", "String"};
               columns[3] = new String[]{"CUSTSEX", "String"};
               columns[4] = new String[]{"CUSTBIRTH", "String"};
               columns[5] = new String[]{"PAPERTYPECODE", "String"};
               columns[6] = new String[]{"PAPERNO", "String"};
               columns[7] = new String[]{"CUSTADDR", "String"};
               columns[8] = new String[]{"CUSTPOST", "String"};
               columns[9] = new String[]{"CUSTPHONE", "String"};
               columns[10] = new String[]{"CUSTEMAIL", "String"};
               columns[11] = new String[]{"UPDATESTAFFNO", "string"};
               columns[12] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "UPDATETIME",
               };


               array = new String[13];
               hash.Add("CARDNO", 0);
               hash.Add("UPDATETIME", 1);
               hash.Add("CUSTNAME", 2);
               hash.Add("CUSTSEX", 3);
               hash.Add("CUSTBIRTH", 4);
               hash.Add("PAPERTYPECODE", 5);
               hash.Add("PAPERNO", 6);
               hash.Add("CUSTADDR", 7);
               hash.Add("CUSTPOST", 8);
               hash.Add("CUSTPHONE", 9);
               hash.Add("CUSTEMAIL", 10);
               hash.Add("UPDATESTAFFNO", 11);
               hash.Add("REMARK", 12);
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

          // 姓名
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // 性别
          public String CUSTSEX
          {
              get { return  GetString("CUSTSEX"); }
              set { SetString("CUSTSEX",value); }
          }

          // 出生日期
          public String CUSTBIRTH
          {
              get { return  GetString("CUSTBIRTH"); }
              set { SetString("CUSTBIRTH",value); }
          }

          // 证件类型
          public String PAPERTYPECODE
          {
              get { return  GetString("PAPERTYPECODE"); }
              set { SetString("PAPERTYPECODE",value); }
          }

          // 证件号码
          public String PAPERNO
          {
              get { return  GetString("PAPERNO"); }
              set { SetString("PAPERNO",value); }
          }

          // 联系地址
          public String CUSTADDR
          {
              get { return  GetString("CUSTADDR"); }
              set { SetString("CUSTADDR",value); }
          }

          // 邮政编码
          public String CUSTPOST
          {
              get { return  GetString("CUSTPOST"); }
              set { SetString("CUSTPOST",value); }
          }

          // 联系电话
          public String CUSTPHONE
          {
              get { return  GetString("CUSTPHONE"); }
              set { SetString("CUSTPHONE",value); }
          }

          // EMAIL地址
          public String CUSTEMAIL
          {
              get { return  GetString("CUSTEMAIL"); }
              set { SetString("CUSTEMAIL",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


