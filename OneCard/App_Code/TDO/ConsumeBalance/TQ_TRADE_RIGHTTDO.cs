using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // 消费正常清单查询表
     public class TQ_TRADE_RIGHTTDO : DDOBase
     {
          public TQ_TRADE_RIGHTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TQ_TRADE_RIGHT";

               columns = new String[30][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"RECTYPE", "string"};
               columns[3] = new String[]{"ICTRADETYPECODE", "string"};
               columns[4] = new String[]{"ASN", "string"};
               columns[5] = new String[]{"CARDTRADENO", "string"};
               columns[6] = new String[]{"SAMNO", "string"};
               columns[7] = new String[]{"PSAMVERNO", "string"};
               columns[8] = new String[]{"POSNO", "string"};
               columns[9] = new String[]{"POSTRADENO", "string"};
               columns[10] = new String[]{"TRADEDATE", "string"};
               columns[11] = new String[]{"TRADETIME", "string"};
               columns[12] = new String[]{"PREMONEY", "Int32"};
               columns[13] = new String[]{"TRADEMONEY", "Int32"};
               columns[14] = new String[]{"SMONEY", "Int32"};
               columns[15] = new String[]{"TRADECOMFEE", "Int32"};
               columns[16] = new String[]{"BALUNITNO", "string"};
               columns[17] = new String[]{"CALLINGNO", "string"};
               columns[18] = new String[]{"CORPNO", "string"};
               columns[19] = new String[]{"DEPARTNO", "string"};
               columns[20] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[21] = new String[]{"CITYNO", "string"};
               columns[22] = new String[]{"TAC", "string"};
               columns[23] = new String[]{"TACSTATE", "string"};
               columns[24] = new String[]{"MAC", "string"};
               columns[25] = new String[]{"SOURCEID", "String"};
               columns[26] = new String[]{"BATCHNO", "string"};
               columns[27] = new String[]{"DEALTIME", "DateTime"};
               columns[28] = new String[]{"INLISTTIME", "DateTime"};
               columns[29] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[30];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("RECTYPE", 2);
               hash.Add("ICTRADETYPECODE", 3);
               hash.Add("ASN", 4);
               hash.Add("CARDTRADENO", 5);
               hash.Add("SAMNO", 6);
               hash.Add("PSAMVERNO", 7);
               hash.Add("POSNO", 8);
               hash.Add("POSTRADENO", 9);
               hash.Add("TRADEDATE", 10);
               hash.Add("TRADETIME", 11);
               hash.Add("PREMONEY", 12);
               hash.Add("TRADEMONEY", 13);
               hash.Add("SMONEY", 14);
               hash.Add("TRADECOMFEE", 15);
               hash.Add("BALUNITNO", 16);
               hash.Add("CALLINGNO", 17);
               hash.Add("CORPNO", 18);
               hash.Add("DEPARTNO", 19);
               hash.Add("CALLINGSTAFFNO", 20);
               hash.Add("CITYNO", 21);
               hash.Add("TAC", 22);
               hash.Add("TACSTATE", 23);
               hash.Add("MAC", 24);
               hash.Add("SOURCEID", 25);
               hash.Add("BATCHNO", 26);
               hash.Add("DEALTIME", 27);
               hash.Add("INLISTTIME", 28);
               hash.Add("RSRVCHAR", 29);
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

          // 入清单时间
          public DateTime INLISTTIME
          {
              get { return  GetDateTime("INLISTTIME"); }
              set { SetDateTime("INLISTTIME",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


