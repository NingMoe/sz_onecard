using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 单位编码表
     public class TD_M_CORPTDO : DDOBase
     {
          public TD_M_CORPTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CORP";

               columns = new String[12][];
               columns[0] = new String[]{"CORPNO", "string"};
               columns[1] = new String[]{"CORP", "String"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"SUBCITYNO", "string"};
               columns[4] = new String[]{"CORPADD", "String"};
               columns[5] = new String[]{"CORPMARK", "String"};
               columns[6] = new String[]{"LINKMAN", "String"};
               columns[7] = new String[]{"CORPPHONE", "String"};
               columns[8] = new String[]{"USETAG", "string"};
               columns[9] = new String[]{"UPDATESTAFFNO", "string"};
               columns[10] = new String[]{"UPDATETIME", "DateTime"};
               columns[11] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CORPNO",
               };


               array = new String[12];
               hash.Add("CORPNO", 0);
               hash.Add("CORP", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("SUBCITYNO", 3);
               hash.Add("CORPADD", 4);
               hash.Add("CORPMARK", 5);
               hash.Add("LINKMAN", 6);
               hash.Add("CORPPHONE", 7);
               hash.Add("USETAG", 8);
               hash.Add("UPDATESTAFFNO", 9);
               hash.Add("UPDATETIME", 10);
               hash.Add("REMARK", 11);
          }

          // 单位编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 单位名称
          public String CORP
          {
              get { return  GetString("CORP"); }
              set { SetString("CORP",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 市县编码
          public string SUBCITYNO
          {
              get { return  Getstring("SUBCITYNO"); }
              set { Setstring("SUBCITYNO",value); }
          }

          // 单位地址
          public String CORPADD
          {
              get { return  GetString("CORPADD"); }
              set { SetString("CORPADD",value); }
          }

          // 单位说明
          public String CORPMARK
          {
              get { return  GetString("CORPMARK"); }
              set { SetString("CORPMARK",value); }
          }

          // 联系人
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // 联系电话
          public String CORPPHONE
          {
              get { return  GetString("CORPPHONE"); }
              set { SetString("CORPPHONE",value); }
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


