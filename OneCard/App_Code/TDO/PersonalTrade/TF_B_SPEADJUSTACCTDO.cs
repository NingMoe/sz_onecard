using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 特殊调帐台帐表
     public class TF_B_SPEADJUSTACCTDO : DDOBase
     {
          public TF_B_SPEADJUSTACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_SPEADJUSTACC";

               columns = new String[24][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"ID", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"CARDTRADENO", "string"};
               columns[5] = new String[]{"TRADEDATE", "string"};
               columns[6] = new String[]{"TRADETIME", "string"};
               columns[7] = new String[]{"PREMONEY", "Int32"};
               columns[8] = new String[]{"TRADEMONEY", "Int32"};
               columns[9] = new String[]{"REFUNDMENT", "Int32"};
               columns[10] = new String[]{"CUSTPHONE", "String"};
               columns[11] = new String[]{"CUSTNAME", "String"};
               columns[12] = new String[]{"CALLINGNO", "string"};
               columns[13] = new String[]{"CORPNO", "string"};
               columns[14] = new String[]{"DEPARTNO", "string"};
               columns[15] = new String[]{"BALUNITNO", "string"};
               columns[16] = new String[]{"REASONCODE", "string"};
               columns[17] = new String[]{"REMARK", "String"};
               columns[18] = new String[]{"STATECODE", "string"};
               columns[19] = new String[]{"STAFFNO", "string"};
               columns[20] = new String[]{"OPERATETIME", "DateTime"};
               columns[21] = new String[]{"CHECKSTAFFNO", "string"};
               columns[22] = new String[]{"CHECKTIME", "DateTime"};
               columns[23] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[24];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("ID", 2);
               hash.Add("CARDNO", 3);
               hash.Add("CARDTRADENO", 4);
               hash.Add("TRADEDATE", 5);
               hash.Add("TRADETIME", 6);
               hash.Add("PREMONEY", 7);
               hash.Add("TRADEMONEY", 8);
               hash.Add("REFUNDMENT", 9);
               hash.Add("CUSTPHONE", 10);
               hash.Add("CUSTNAME", 11);
               hash.Add("CALLINGNO", 12);
               hash.Add("CORPNO", 13);
               hash.Add("DEPARTNO", 14);
               hash.Add("BALUNITNO", 15);
               hash.Add("REASONCODE", 16);
               hash.Add("REMARK", 17);
               hash.Add("STATECODE", 18);
               hash.Add("STAFFNO", 19);
               hash.Add("OPERATETIME", 20);
               hash.Add("CHECKSTAFFNO", 21);
               hash.Add("CHECKTIME", 22);
               hash.Add("RSRVCHAR", 23);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 卡交易序列号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 交易日期
          public string TRADEDATE
          {
              get { return  Getstring("TRADEDATE"); }
              set { Setstring("TRADEDATE",value); }
          }

          // 交易时间
          public string TRADETIME
          {
              get { return  Getstring("TRADETIME"); }
              set { Setstring("TRADETIME",value); }
          }

          // 交易前卡内余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // 交易金额
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // 退款金额
          public Int32 REFUNDMENT
          {
              get { return  GetInt32("REFUNDMENT"); }
              set { SetInt32("REFUNDMENT",value); }
          }

          // 持卡人电话
          public String CUSTPHONE
          {
              get { return  GetString("CUSTPHONE"); }
              set { SetString("CUSTPHONE",value); }
          }

          // 持卡人姓名
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
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

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 调帐原因编码
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // 交易情况说明
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // 审核状态
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // 操作员工编码
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // 审核员工
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // 审核时间
          public DateTime CHECKTIME
          {
              get { return  GetDateTime("CHECKTIME"); }
              set { SetDateTime("CHECKTIME",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


