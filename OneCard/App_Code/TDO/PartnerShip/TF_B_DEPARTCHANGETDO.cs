using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 部门编码资料变更子表
     public class TF_B_DEPARTCHANGETDO : DDOBase
     {
          public TF_B_DEPARTCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_DEPARTCHANGE";

               columns = new String[8][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"DEPARTNO", "string"};
               columns[2] = new String[]{"DEPART", "String"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DPARTMARK", "String"};
               columns[5] = new String[]{"LINKMAN", "String"};
               columns[6] = new String[]{"DEPARTPHONE", "String"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[8];
               hash.Add("TRADEID", 0);
               hash.Add("DEPARTNO", 1);
               hash.Add("DEPART", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DPARTMARK", 4);
               hash.Add("LINKMAN", 5);
               hash.Add("DEPARTPHONE", 6);
               hash.Add("REMARK", 7);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 部门名称
          public String DEPART
          {
              get { return  GetString("DEPART"); }
              set { SetString("DEPART",value); }
          }

          // 单位编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 部门说明
          public String DPARTMARK
          {
              get { return  GetString("DPARTMARK"); }
              set { SetString("DPARTMARK",value); }
          }

          // 联系人
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // 联系电话
          public String DEPARTPHONE
          {
              get { return  GetString("DEPARTPHONE"); }
              set { SetString("DEPARTPHONE",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


