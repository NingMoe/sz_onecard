using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 单位编码资料变更子表
     public class TF_B_CORPCHANGETDO : DDOBase
     {
          public TF_B_CORPCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_CORPCHANGE";

               columns = new String[10][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CORPNO", "string"};
               columns[2] = new String[]{"CORP", "String"};
               columns[3] = new String[]{"CALLINGNO", "string"};
               columns[4] = new String[]{"SUBCITYNO", "string"};
               columns[5] = new String[]{"CORPADD", "String"};
               columns[6] = new String[]{"CORPMARK", "String"};
               columns[7] = new String[]{"LINKMAN", "String"};
               columns[8] = new String[]{"CORPPHONE", "String"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[10];
               hash.Add("TRADEID", 0);
               hash.Add("CORPNO", 1);
               hash.Add("CORP", 2);
               hash.Add("CALLINGNO", 3);
               hash.Add("SUBCITYNO", 4);
               hash.Add("CORPADD", 5);
               hash.Add("CORPMARK", 6);
               hash.Add("LINKMAN", 7);
               hash.Add("CORPPHONE", 8);
               hash.Add("REMARK", 9);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
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

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


