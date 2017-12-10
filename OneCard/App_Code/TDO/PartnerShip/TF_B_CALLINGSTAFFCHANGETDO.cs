using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 行业员工编码资料变更子表
     public class TF_B_CALLINGSTAFFCHANGETDO : DDOBase
     {
          public TF_B_CALLINGSTAFFCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_CALLINGSTAFFCHANGE";

               columns = new String[23][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"STAFFNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"STAFFNAME", "String"};
               columns[4] = new String[]{"STAFFPAPERTYPECODE", "string"};
               columns[5] = new String[]{"STAFFPAPERNO", "String"};
               columns[6] = new String[]{"STAFFADDR", "String"};
               columns[7] = new String[]{"STAFFPHONE", "String"};
               columns[8] = new String[]{"STAFFMOBILE", "String"};
               columns[9] = new String[]{"STAFFPOST", "String"};
               columns[10] = new String[]{"STAFFEMAIL", "String"};
               columns[11] = new String[]{"STAFFSEX", "string"};
               columns[12] = new String[]{"OPERCARDNO", "String"};
               columns[13] = new String[]{"OLDCARDNO", "String"};
               columns[14] = new String[]{"OPERCARDPWD", "String"};
               columns[15] = new String[]{"COLLECTCARDNO", "String"};
               columns[16] = new String[]{"COLLECTCARDPWD", "String"};
               columns[17] = new String[]{"POSID", "string"};
               columns[18] = new String[]{"CARNO", "string"};
               columns[19] = new String[]{"DIMISSIONTAG", "string"};
               columns[20] = new String[]{"SERVTAG1", "string"};
               columns[21] = new String[]{"SERVTAG2", "string"};
               columns[22] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[23];
               hash.Add("TRADEID", 0);
               hash.Add("STAFFNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("STAFFNAME", 3);
               hash.Add("STAFFPAPERTYPECODE", 4);
               hash.Add("STAFFPAPERNO", 5);
               hash.Add("STAFFADDR", 6);
               hash.Add("STAFFPHONE", 7);
               hash.Add("STAFFMOBILE", 8);
               hash.Add("STAFFPOST", 9);
               hash.Add("STAFFEMAIL", 10);
               hash.Add("STAFFSEX", 11);
               hash.Add("OPERCARDNO", 12);
               hash.Add("OLDCARDNO", 13);
               hash.Add("OPERCARDPWD", 14);
               hash.Add("COLLECTCARDNO", 15);
               hash.Add("COLLECTCARDPWD", 16);
               hash.Add("POSID", 17);
               hash.Add("CARNO", 18);
               hash.Add("DIMISSIONTAG", 19);
               hash.Add("SERVTAG1", 20);
               hash.Add("SERVTAG2", 21);
               hash.Add("REMARK", 22);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 员工编码
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 员工姓名
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // 员工证件类型
          public string STAFFPAPERTYPECODE
          {
              get { return  Getstring("STAFFPAPERTYPECODE"); }
              set { Setstring("STAFFPAPERTYPECODE",value); }
          }

          // 员工证件号码
          public String STAFFPAPERNO
          {
              get { return  GetString("STAFFPAPERNO"); }
              set { SetString("STAFFPAPERNO",value); }
          }

          // 员工联系地址
          public String STAFFADDR
          {
              get { return  GetString("STAFFADDR"); }
              set { SetString("STAFFADDR",value); }
          }

          // 员工联系电话
          public String STAFFPHONE
          {
              get { return  GetString("STAFFPHONE"); }
              set { SetString("STAFFPHONE",value); }
          }

          // 员工移动电话
          public String STAFFMOBILE
          {
              get { return  GetString("STAFFMOBILE"); }
              set { SetString("STAFFMOBILE",value); }
          }

          // 邮编地址
          public String STAFFPOST
          {
              get { return  GetString("STAFFPOST"); }
              set { SetString("STAFFPOST",value); }
          }

          // EMAIL地址
          public String STAFFEMAIL
          {
              get { return  GetString("STAFFEMAIL"); }
              set { SetString("STAFFEMAIL",value); }
          }

          // 员工性别
          public string STAFFSEX
          {
              get { return  Getstring("STAFFSEX"); }
              set { Setstring("STAFFSEX",value); }
          }

          // 员工卡号
          public String OPERCARDNO
          {
              get { return  GetString("OPERCARDNO"); }
              set { SetString("OPERCARDNO",value); }
          }

          // 旧卡卡号
          public String OLDCARDNO
          {
              get { return  GetString("OLDCARDNO"); }
              set { SetString("OLDCARDNO",value); }
          }

          // 员工卡密码
          public String OPERCARDPWD
          {
              get { return  GetString("OPERCARDPWD"); }
              set { SetString("OPERCARDPWD",value); }
          }

          // 采集卡号
          public String COLLECTCARDNO
          {
              get { return  GetString("COLLECTCARDNO"); }
              set { SetString("COLLECTCARDNO",value); }
          }

          // 采集卡密码
          public String COLLECTCARDPWD
          {
              get { return  GetString("COLLECTCARDPWD"); }
              set { SetString("COLLECTCARDPWD",value); }
          }

          // POS编号
          public string POSID
          {
              get { return  Getstring("POSID"); }
              set { Setstring("POSID",value); }
          }

          // 车号
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // 离职标志
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
          }

          // 服务标志1
          public string SERVTAG1
          {
              get { return  Getstring("SERVTAG1"); }
              set { Setstring("SERVTAG1",value); }
          }

          // 服务标志2
          public string SERVTAG2
          {
              get { return  Getstring("SERVTAG2"); }
              set { Setstring("SERVTAG2",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


