using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // 消费结算单元编码资料变更子表
     public class TF_B_TRADE_BALUNITCHANGETDO : DDOBase
     {
          public TF_B_TRADE_BALUNITCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADE_BALUNITCHANGE";

               columns = new String[27][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"BALUNIT", "String"};
               columns[3] = new String[]{"BALUNITTYPECODE", "string"};
               columns[4] = new String[]{"CHANNELNO", "string"};
               columns[5] = new String[]{"SOURCETYPECODE", "string"};
               columns[6] = new String[]{"CALLINGNO", "string"};
               columns[7] = new String[]{"CORPNO", "string"};
               columns[8] = new String[]{"DEPARTNO", "string"};
               columns[9] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[10] = new String[]{"BANKCODE", "string"};
               columns[11] = new String[]{"BANKACCNO", "String"};
               columns[12] = new String[]{"CREATETIME", "DateTime"};
               columns[13] = new String[]{"SERMANAGERCODE", "string"};
               columns[14] = new String[]{"BALLEVEL", "string"};
               columns[15] = new String[]{"BALCYCLETYPECODE", "string"};
               columns[16] = new String[]{"BALINTERVAL", "Int32"};
               columns[17] = new String[]{"FINCYCLETYPECODE", "string"};
               columns[18] = new String[]{"FININTERVAL", "Int32"};
               columns[19] = new String[]{"FINTYPECODE", "string"};
               columns[20] = new String[]{"COMFEETAKECODE", "string"};
               columns[21] = new String[]{"FINBANKCODE", "string"};
               columns[22] = new String[]{"LINKMAN", "String"};
               columns[23] = new String[]{"UNITPHONE", "String"};
               columns[24] = new String[]{"UNITADD", "String"};
               columns[25] = new String[]{"UNITEMAIL", "String"};
               columns[26] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[27];
               hash.Add("TRADEID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("BALUNIT", 2);
               hash.Add("BALUNITTYPECODE", 3);
               hash.Add("CHANNELNO", 4);
               hash.Add("SOURCETYPECODE", 5);
               hash.Add("CALLINGNO", 6);
               hash.Add("CORPNO", 7);
               hash.Add("DEPARTNO", 8);
               hash.Add("CALLINGSTAFFNO", 9);
               hash.Add("BANKCODE", 10);
               hash.Add("BANKACCNO", 11);
               hash.Add("CREATETIME", 12);
               hash.Add("SERMANAGERCODE", 13);
               hash.Add("BALLEVEL", 14);
               hash.Add("BALCYCLETYPECODE", 15);
               hash.Add("BALINTERVAL", 16);
               hash.Add("FINCYCLETYPECODE", 17);
               hash.Add("FININTERVAL", 18);
               hash.Add("FINTYPECODE", 19);
               hash.Add("COMFEETAKECODE", 20);
               hash.Add("FINBANKCODE", 21);
               hash.Add("LINKMAN", 22);
               hash.Add("UNITPHONE", 23);
               hash.Add("UNITADD", 24);
               hash.Add("UNITEMAIL", 25);
               hash.Add("REMARK", 26);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
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

          // 来源识别类型编码
          public string SOURCETYPECODE
          {
              get { return  Getstring("SOURCETYPECODE"); }
              set { Setstring("SOURCETYPECODE",value); }
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

          // 行业员工编码
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
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

          // 转出行银行代码
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

          // EMAIL地址
          public String UNITEMAIL
          {
              get { return  GetString("UNITEMAIL"); }
              set { SetString("UNITEMAIL",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


