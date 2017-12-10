using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 售充结算单元编码表
     public class TF_SELSUP_BALUNITTDO : DDOBase
     {
          public TF_SELSUP_BALUNITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SELSUP_BALUNIT";

               columns = new String[25][];
               columns[0] = new String[]{"BALUNITNO", "string"};
               columns[1] = new String[]{"BALUNIT", "String"};
               columns[2] = new String[]{"BALUNITTYPECODE", "string"};
               columns[3] = new String[]{"CHANNELNO", "string"};
               columns[4] = new String[]{"CALLINGNO", "string"};
               columns[5] = new String[]{"CORPNO", "string"};
               columns[6] = new String[]{"DEPARTNO", "string"};
               columns[7] = new String[]{"BANKCODE", "string"};
               columns[8] = new String[]{"BANKACCNO", "String"};
               columns[9] = new String[]{"CREATETIME", "DateTime"};
               columns[10] = new String[]{"SERMANAGERCODE", "string"};
               columns[11] = new String[]{"BALLEVEL", "string"};
               columns[12] = new String[]{"BALCYCLETYPECODE", "string"};
               columns[13] = new String[]{"BALINTERVAL", "Int32"};
               columns[14] = new String[]{"FINCYCLETYPECODE", "string"};
               columns[15] = new String[]{"FININTERVAL", "Int32"};
               columns[16] = new String[]{"FINTYPECODE", "string"};
               columns[17] = new String[]{"COMFEETAKECODE", "string"};
               columns[18] = new String[]{"FINBANKCODE", "string"};
               columns[19] = new String[]{"LINKMAN", "String"};
               columns[20] = new String[]{"UNITPHONE", "String"};
               columns[21] = new String[]{"UNITADD", "String"};
               columns[22] = new String[]{"UPDATESTAFFNO", "string"};
               columns[23] = new String[]{"UPDATETIME", "DateTime"};
               columns[24] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "BALUNITNO",
               };


               array = new String[25];
               hash.Add("BALUNITNO", 0);
               hash.Add("BALUNIT", 1);
               hash.Add("BALUNITTYPECODE", 2);
               hash.Add("CHANNELNO", 3);
               hash.Add("CALLINGNO", 4);
               hash.Add("CORPNO", 5);
               hash.Add("DEPARTNO", 6);
               hash.Add("BANKCODE", 7);
               hash.Add("BANKACCNO", 8);
               hash.Add("CREATETIME", 9);
               hash.Add("SERMANAGERCODE", 10);
               hash.Add("BALLEVEL", 11);
               hash.Add("BALCYCLETYPECODE", 12);
               hash.Add("BALINTERVAL", 13);
               hash.Add("FINCYCLETYPECODE", 14);
               hash.Add("FININTERVAL", 15);
               hash.Add("FINTYPECODE", 16);
               hash.Add("COMFEETAKECODE", 17);
               hash.Add("FINBANKCODE", 18);
               hash.Add("LINKMAN", 19);
               hash.Add("UNITPHONE", 20);
               hash.Add("UNITADD", 21);
               hash.Add("UPDATESTAFFNO", 22);
               hash.Add("UPDATETIME", 23);
               hash.Add("REMARK", 24);
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 结算单元名称
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // 单元类型编码
          public string BALUNITTYPECODE
          {
              get { return  Getstring("BALUNITTYPECODE"); }
              set { Setstring("BALUNITTYPECODE",value); }
          }

          // 通道编码
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 单位编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 开户银行编码
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // 银行帐号
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // 合作时间
          public DateTime CREATETIME
          {
              get { return  GetDateTime("CREATETIME"); }
              set { SetDateTime("CREATETIME",value); }
          }

          // 客服经理编码
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // 结算级别编码
          public string BALLEVEL
          {
              get { return  Getstring("BALLEVEL"); }
              set { Setstring("BALLEVEL",value); }
          }

          // 结算周期类型编码
          public string BALCYCLETYPECODE
          {
              get { return  Getstring("BALCYCLETYPECODE"); }
              set { Setstring("BALCYCLETYPECODE",value); }
          }

          // 结算周期跨度
          public Int32 BALINTERVAL
          {
              get { return  GetInt32("BALINTERVAL"); }
              set { SetInt32("BALINTERVAL",value); }
          }

          // 划账周期类型编码
          public string FINCYCLETYPECODE
          {
              get { return  Getstring("FINCYCLETYPECODE"); }
              set { Setstring("FINCYCLETYPECODE",value); }
          }

          // 划账周期跨度
          public Int32 FININTERVAL
          {
              get { return  GetInt32("FININTERVAL"); }
              set { SetInt32("FININTERVAL",value); }
          }

          // 转账类型
          public string FINTYPECODE
          {
              get { return  Getstring("FINTYPECODE"); }
              set { Setstring("FINTYPECODE",value); }
          }

          // 佣金扣减方式编码
          public string COMFEETAKECODE
          {
              get { return  Getstring("COMFEETAKECODE"); }
              set { Setstring("COMFEETAKECODE",value); }
          }

          // 转入行银行代码
          public string FINBANKCODE
          {
              get { return  Getstring("FINBANKCODE"); }
              set { Setstring("FINBANKCODE",value); }
          }

          // 联系人
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // 联系电话
          public String UNITPHONE
          {
              get { return  GetString("UNITPHONE"); }
              set { SetString("UNITPHONE",value); }
          }

          // 联系地址
          public String UNITADD
          {
              get { return  GetString("UNITADD"); }
              set { SetString("UNITADD",value); }
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


