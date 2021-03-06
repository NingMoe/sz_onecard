using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // 消费重复数据清单表
     public class TF_TRADE_REPEAT_01TDO : DDOBase
     {
          public TF_TRADE_REPEAT_01TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADE_REPEAT_01";

               columns = new String[24][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"RECTYPE", "string"};
               columns[2] = new String[]{"ICTRADETYPECODE", "string"};
               columns[3] = new String[]{"ASN", "string"};
               columns[4] = new String[]{"CARDTRADENO", "string"};
               columns[5] = new String[]{"SAMNO", "string"};
               columns[6] = new String[]{"PSAMVERNO", "string"};
               columns[7] = new String[]{"POSNO", "string"};
               columns[8] = new String[]{"POSTRADENO", "string"};
               columns[9] = new String[]{"TRADEDATE", "string"};
               columns[10] = new String[]{"TRADETIME", "string"};
               columns[11] = new String[]{"PREMONEY", "Int32"};
               columns[12] = new String[]{"TRADEMONEY", "Int32"};
               columns[13] = new String[]{"SMONEY", "Int32"};
               columns[14] = new String[]{"CITYNO", "string"};
               columns[15] = new String[]{"TAC", "string"};
               columns[16] = new String[]{"TACSTATE", "string"};
               columns[17] = new String[]{"MAC", "string"};
               columns[18] = new String[]{"SOURCEID", "String"};
               columns[19] = new String[]{"BATCHNO", "string"};
               columns[20] = new String[]{"DEALTIME", "DateTime"};
               columns[21] = new String[]{"REPEATTYPECODE", "string"};
               columns[22] = new String[]{"INLISTTIME", "DateTime"};
               columns[23] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[24];
               hash.Add("ID", 0);
               hash.Add("RECTYPE", 1);
               hash.Add("ICTRADETYPECODE", 2);
               hash.Add("ASN", 3);
               hash.Add("CARDTRADENO", 4);
               hash.Add("SAMNO", 5);
               hash.Add("PSAMVERNO", 6);
               hash.Add("POSNO", 7);
               hash.Add("POSTRADENO", 8);
               hash.Add("TRADEDATE", 9);
               hash.Add("TRADETIME", 10);
               hash.Add("PREMONEY", 11);
               hash.Add("TRADEMONEY", 12);
               hash.Add("SMONEY", 13);
               hash.Add("CITYNO", 14);
               hash.Add("TAC", 15);
               hash.Add("TACSTATE", 16);
               hash.Add("MAC", 17);
               hash.Add("SOURCEID", 18);
               hash.Add("BATCHNO", 19);
               hash.Add("DEALTIME", 20);
               hash.Add("REPEATTYPECODE", 21);
               hash.Add("INLISTTIME", 22);
               hash.Add("RSRVCHAR", 23);
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
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

          // 重复类型编码
          public string REPEATTYPECODE
          {
              get { return  Getstring("REPEATTYPECODE"); }
              set { Setstring("REPEATTYPECODE",value); }
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


