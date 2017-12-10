using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 非实时充值人工回收台帐表
     public class TF_B_SUPPLY_MANUALTDO : DDOBase
     {
          public TF_B_SUPPLY_MANUALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_SUPPLY_MANUAL";

               columns = new String[34][];
               columns[0] = new String[]{"BUSINESSID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"CARDTRADENO", "string"};
               columns[4] = new String[]{"TRADETYPECODE", "string"};
               columns[5] = new String[]{"CARDTYPECODE", "string"};
               columns[6] = new String[]{"TRADEDATE", "string"};
               columns[7] = new String[]{"TRADETIME", "string"};
               columns[8] = new String[]{"TRADEMONEY", "Int32"};
               columns[9] = new String[]{"PREMONEY", "Int32"};
               columns[10] = new String[]{"SUPPLYLOCNO", "string"};
               columns[11] = new String[]{"SAMNO", "string"};
               columns[12] = new String[]{"POSNO", "string"};
               columns[13] = new String[]{"STAFFNO", "string"};
               columns[14] = new String[]{"TAC", "string"};
               columns[15] = new String[]{"TRADEID", "string"};
               columns[16] = new String[]{"TACSTATE", "string"};
               columns[17] = new String[]{"BATCHNO", "string"};
               columns[18] = new String[]{"SUPPLYCOMFEE", "Int32"};
               columns[19] = new String[]{"BALUNITNO", "string"};
               columns[20] = new String[]{"CALLINGNO", "string"};
               columns[21] = new String[]{"CORPNO", "string"};
               columns[22] = new String[]{"DEPARTNO", "string"};
               columns[23] = new String[]{"DEALTIME", "DateTime"};
               columns[24] = new String[]{"ERRORREASONCODE", "string"};
               columns[25] = new String[]{"COMPTTIME", "DateTime"};
               columns[26] = new String[]{"COMPMONEY", "Int32"};
               columns[27] = new String[]{"COMPSTATE", "string"};
               columns[28] = new String[]{"RENEWMONEY", "Int32"};
               columns[29] = new String[]{"RENEWTIME", "DateTime"};
               columns[30] = new String[]{"RENEWSTAFFNO", "string"};
               columns[31] = new String[]{"RENEWTYPECODE", "string"};
               columns[32] = new String[]{"RENEWREMARK", "String"};
               columns[33] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "BUSINESSID",
               };


               array = new String[34];
               hash.Add("BUSINESSID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("ASN", 2);
               hash.Add("CARDTRADENO", 3);
               hash.Add("TRADETYPECODE", 4);
               hash.Add("CARDTYPECODE", 5);
               hash.Add("TRADEDATE", 6);
               hash.Add("TRADETIME", 7);
               hash.Add("TRADEMONEY", 8);
               hash.Add("PREMONEY", 9);
               hash.Add("SUPPLYLOCNO", 10);
               hash.Add("SAMNO", 11);
               hash.Add("POSNO", 12);
               hash.Add("STAFFNO", 13);
               hash.Add("TAC", 14);
               hash.Add("TRADEID", 15);
               hash.Add("TACSTATE", 16);
               hash.Add("BATCHNO", 17);
               hash.Add("SUPPLYCOMFEE", 18);
               hash.Add("BALUNITNO", 19);
               hash.Add("CALLINGNO", 20);
               hash.Add("CORPNO", 21);
               hash.Add("DEPARTNO", 22);
               hash.Add("DEALTIME", 23);
               hash.Add("ERRORREASONCODE", 24);
               hash.Add("COMPTTIME", 25);
               hash.Add("COMPMONEY", 26);
               hash.Add("COMPSTATE", 27);
               hash.Add("RENEWMONEY", 28);
               hash.Add("RENEWTIME", 29);
               hash.Add("RENEWSTAFFNO", 30);
               hash.Add("RENEWTYPECODE", 31);
               hash.Add("RENEWREMARK", 32);
               hash.Add("RSRVCHAR", 33);
          }

          // 业务流水号
          public string BUSINESSID
          {
              get { return  Getstring("BUSINESSID"); }
              set { Setstring("BUSINESSID",value); }
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // IC应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // IC交易序列号 
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 交易类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 卡片类型编码
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
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

          // 交易金额
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // 交易前余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // 充值点编号
          public string SUPPLYLOCNO
          {
              get { return  Getstring("SUPPLYLOCNO"); }
              set { Setstring("SUPPLYLOCNO",value); }
          }

          // SAM编号
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // POS编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // 操作员号
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // TAC认证码
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // 银行交易流水
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // TAC码验证结果
          public string TACSTATE
          {
              get { return  Getstring("TACSTATE"); }
              set { Setstring("TACSTATE",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // 结算佣金
          public Int32 SUPPLYCOMFEE
          {
              get { return  GetInt32("SUPPLYCOMFEE"); }
              set { SetInt32("SUPPLYCOMFEE",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
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

          // 处理时间
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // 错误原因编码
          public string ERRORREASONCODE
          {
              get { return  Getstring("ERRORREASONCODE"); }
              set { Setstring("ERRORREASONCODE",value); }
          }

          // 比对时间
          public DateTime COMPTTIME
          {
              get { return  GetDateTime("COMPTTIME"); }
              set { SetDateTime("COMPTTIME",value); }
          }

          // 比对交易金额
          public Int32 COMPMONEY
          {
              get { return  GetInt32("COMPMONEY"); }
              set { SetInt32("COMPMONEY",value); }
          }

          // 比对结果
          public string COMPSTATE
          {
              get { return  Getstring("COMPSTATE"); }
              set { Setstring("COMPSTATE",value); }
          }

          // 回收金额
          public Int32 RENEWMONEY
          {
              get { return  GetInt32("RENEWMONEY"); }
              set { SetInt32("RENEWMONEY",value); }
          }

          // 人工回收时间
          public DateTime RENEWTIME
          {
              get { return  GetDateTime("RENEWTIME"); }
              set { SetDateTime("RENEWTIME",value); }
          }

          // 人工回收员工编号
          public string RENEWSTAFFNO
          {
              get { return  Getstring("RENEWSTAFFNO"); }
              set { Setstring("RENEWSTAFFNO",value); }
          }

          // 人工回收方式编码
          public string RENEWTYPECODE
          {
              get { return  Getstring("RENEWTYPECODE"); }
              set { Setstring("RENEWTYPECODE",value); }
          }

          // 人工回收说明
          public String RENEWREMARK
          {
              get { return  GetString("RENEWREMARK"); }
              set { SetString("RENEWREMARK",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


