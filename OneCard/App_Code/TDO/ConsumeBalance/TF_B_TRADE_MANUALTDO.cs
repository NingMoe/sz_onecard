using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // 消费异常人工回收台帐表
     public class TF_B_TRADE_MANUALTDO : DDOBase
     {
          public TF_B_TRADE_MANUALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADE_MANUAL";

               columns = new String[39][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"RECTYPE", "string"};
               columns[4] = new String[]{"ICTRADETYPECODE", "string"};
               columns[5] = new String[]{"ASN", "string"};
               columns[6] = new String[]{"CARDTRADENO", "string"};
               columns[7] = new String[]{"SAMNO", "string"};
               columns[8] = new String[]{"PSAMVERNO", "string"};
               columns[9] = new String[]{"POSNO", "string"};
               columns[10] = new String[]{"POSTRADENO", "string"};
               columns[11] = new String[]{"TRADEDATE", "string"};
               columns[12] = new String[]{"TRADETIME", "string"};
               columns[13] = new String[]{"PREMONEY", "Int32"};
               columns[14] = new String[]{"TRADEMONEY", "Int32"};
               columns[15] = new String[]{"SMONEY", "Int32"};
               columns[16] = new String[]{"TRADECOMFEE", "Int32"};
               columns[17] = new String[]{"BALUNITNO", "string"};
               columns[18] = new String[]{"CALLINGNO", "string"};
               columns[19] = new String[]{"CORPNO", "string"};
               columns[20] = new String[]{"DEPARTNO", "string"};
               columns[21] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[22] = new String[]{"CITYNO", "string"};
               columns[23] = new String[]{"TAC", "string"};
               columns[24] = new String[]{"TACSTATE", "string"};
               columns[25] = new String[]{"MAC", "string"};
               columns[26] = new String[]{"SOURCEID", "String"};
               columns[27] = new String[]{"BATCHNO", "string"};
               columns[28] = new String[]{"DEALTIME", "DateTime"};
               columns[29] = new String[]{"ERRORREASONCODE", "string"};
               columns[30] = new String[]{"RENEWTIME", "DateTime"};
               columns[31] = new String[]{"RENEWSTAFFNO", "string"};
               columns[32] = new String[]{"RENEWTYPECODE", "string"};
               columns[33] = new String[]{"RENEWREMARK", "String"};
               columns[34] = new String[]{"DEALSTATECODE", "string"};
               columns[35] = new String[]{"RENEWSTATECODE", "string"};
               columns[36] = new String[]{"RECTRADEID", "string"};
               columns[37] = new String[]{"RECSTAFFNO", "string"};
               columns[38] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[39];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("RECTYPE", 3);
               hash.Add("ICTRADETYPECODE", 4);
               hash.Add("ASN", 5);
               hash.Add("CARDTRADENO", 6);
               hash.Add("SAMNO", 7);
               hash.Add("PSAMVERNO", 8);
               hash.Add("POSNO", 9);
               hash.Add("POSTRADENO", 10);
               hash.Add("TRADEDATE", 11);
               hash.Add("TRADETIME", 12);
               hash.Add("PREMONEY", 13);
               hash.Add("TRADEMONEY", 14);
               hash.Add("SMONEY", 15);
               hash.Add("TRADECOMFEE", 16);
               hash.Add("BALUNITNO", 17);
               hash.Add("CALLINGNO", 18);
               hash.Add("CORPNO", 19);
               hash.Add("DEPARTNO", 20);
               hash.Add("CALLINGSTAFFNO", 21);
               hash.Add("CITYNO", 22);
               hash.Add("TAC", 23);
               hash.Add("TACSTATE", 24);
               hash.Add("MAC", 25);
               hash.Add("SOURCEID", 26);
               hash.Add("BATCHNO", 27);
               hash.Add("DEALTIME", 28);
               hash.Add("ERRORREASONCODE", 29);
               hash.Add("RENEWTIME", 30);
               hash.Add("RENEWSTAFFNO", 31);
               hash.Add("RENEWTYPECODE", 32);
               hash.Add("RENEWREMARK", 33);
               hash.Add("DEALSTATECODE", 34);
               hash.Add("RENEWSTATECODE", 35);
               hash.Add("RECTRADEID", 36);
               hash.Add("RECSTAFFNO", 37);
               hash.Add("RSRVCHAR", 38);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
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

          // 记录类型
          public string RECTYPE
          {
              get { return  Getstring("RECTYPE"); }
              set { Setstring("RECTYPE",value); }
          }

          // IC交易类型编码
          public string ICTRADETYPECODE
          {
              get { return  Getstring("ICTRADETYPECODE"); }
              set { Setstring("ICTRADETYPECODE",value); }
          }

          // 应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 卡交易序列号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // PSAM编号
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // PSAM卡版本号
          public string PSAMVERNO
          {
              get { return  Getstring("PSAMVERNO"); }
              set { Setstring("PSAMVERNO",value); }
          }

          // POS编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // POS交易序列号
          public string POSTRADENO
          {
              get { return  Getstring("POSTRADENO"); }
              set { Setstring("POSTRADENO",value); }
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

          // 应收金额
          public Int32 SMONEY
          {
              get { return  GetInt32("SMONEY"); }
              set { SetInt32("SMONEY",value); }
          }

          // 结算佣金
          public Int32 TRADECOMFEE
          {
              get { return  GetInt32("TRADECOMFEE"); }
              set { SetInt32("TRADECOMFEE",value); }
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

          // 行业员工编码
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 城市代码
          public string CITYNO
          {
              get { return  Getstring("CITYNO"); }
              set { Setstring("CITYNO",value); }
          }

          // TAC码
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // TAC验证结果
          public string TACSTATE
          {
              get { return  Getstring("TACSTATE"); }
              set { Setstring("TACSTATE",value); }
          }

          // MAC码
          public string MAC
          {
              get { return  Getstring("MAC"); }
              set { Setstring("MAC",value); }
          }

          // 来源识别号
          public String SOURCEID
          {
              get { return  GetString("SOURCEID"); }
              set { SetString("SOURCEID",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
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

          // 结算处理状态编码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // 人工回收确认状态
          public string RENEWSTATECODE
          {
              get { return  Getstring("RENEWSTATECODE"); }
              set { Setstring("RENEWSTATECODE",value); }
          }

          // 受理业务流水号
          public string RECTRADEID
          {
              get { return  Getstring("RECTRADEID"); }
              set { Setstring("RECTRADEID",value); }
          }

          // 受理员工编码
          public string RECSTAFFNO
          {
              get { return  Getstring("RECSTAFFNO"); }
              set { Setstring("RECSTAFFNO",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


