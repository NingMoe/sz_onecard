using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 集团客户资料变更子表
     public class TF_B_GROUP_CUSTOMERCHANGETDO : DDOBase
     {
          public TF_B_GROUP_CUSTOMERCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_GROUP_CUSTOMERCHANGE";

               columns = new String[10][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CORPCODE", "string"};
               columns[2] = new String[]{"CORPNAME", "String"};
               columns[3] = new String[]{"LINKMAN", "String"};
               columns[4] = new String[]{"CORPADD", "String"};
               columns[5] = new String[]{"CORPPHONE", "String"};
               columns[6] = new String[]{"CORPEMAIL", "String"};
               columns[7] = new String[]{"SERMANAGERCODE", "string"};
               columns[8] = new String[]{"RSRV1", "String"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[10];
               hash.Add("TRADEID", 0);
               hash.Add("CORPCODE", 1);
               hash.Add("CORPNAME", 2);
               hash.Add("LINKMAN", 3);
               hash.Add("CORPADD", 4);
               hash.Add("CORPPHONE", 5);
               hash.Add("CORPEMAIL", 6);
               hash.Add("SERMANAGERCODE", 7);
               hash.Add("RSRV1", 8);
               hash.Add("REMARK", 9);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 集团客户编码
          public string CORPCODE
          {
              get { return  Getstring("CORPCODE"); }
              set { Setstring("CORPCODE",value); }
          }

          // 集团客户名称
          public String CORPNAME
          {
              get { return  GetString("CORPNAME"); }
              set { SetString("CORPNAME",value); }
          }

          // 联系人
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // 联系地址
          public String CORPADD
          {
              get { return  GetString("CORPADD"); }
              set { SetString("CORPADD",value); }
          }

          // 联系电话
          public String CORPPHONE
          {
              get { return  GetString("CORPPHONE"); }
              set { SetString("CORPPHONE",value); }
          }

          // EMAIL地址
          public String CORPEMAIL
          {
              get { return  GetString("CORPEMAIL"); }
              set { SetString("CORPEMAIL",value); }
          }

          // 客服经理编码
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


