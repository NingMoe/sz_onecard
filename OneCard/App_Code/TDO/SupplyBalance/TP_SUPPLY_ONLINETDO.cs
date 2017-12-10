using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 非实时充值联机工作表
     public class TP_SUPPLY_ONLINETDO : DDOBase
     {
          public TP_SUPPLY_ONLINETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_SUPPLY_ONLINE";

               columns = new String[17][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"ASN", "string"};
               columns[2] = new String[]{"CARDTRADENO", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"SUPPLYLOCNO", "string"};
               columns[5] = new String[]{"SAMNO", "string"};
               columns[6] = new String[]{"STAFFNO", "string"};
               columns[7] = new String[]{"PREMONEY", "Int32"};
               columns[8] = new String[]{"TRADEMONEY", "Int32"};
               columns[9] = new String[]{"TRADEDATE", "string"};
               columns[10] = new String[]{"TRADETIME", "string"};
               columns[11] = new String[]{"RESULT", "string"};
               columns[12] = new String[]{"POSNO", "string"};
               columns[13] = new String[]{"TAC", "string"};
               columns[14] = new String[]{"FILENAME", "string"};
               columns[15] = new String[]{"DEALSTATECODE", "string"};
               columns[16] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[17];
               hash.Add("ID", 0);
               hash.Add("ASN", 1);
               hash.Add("CARDTRADENO", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("SUPPLYLOCNO", 4);
               hash.Add("SAMNO", 5);
               hash.Add("STAFFNO", 6);
               hash.Add("PREMONEY", 7);
               hash.Add("TRADEMONEY", 8);
               hash.Add("TRADEDATE", 9);
               hash.Add("TRADETIME", 10);
               hash.Add("RESULT", 11);
               hash.Add("POSNO", 12);
               hash.Add("TAC", 13);
               hash.Add("FILENAME", 14);
               hash.Add("DEALSTATECODE", 15);
               hash.Add("RSRVCHAR", 16);
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
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

          // 操作员号
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 交易前余额
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

          // 操作结果
          public string RESULT
          {
              get { return  Getstring("RESULT"); }
              set { Setstring("RESULT",value); }
          }

          // POS编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // TAC认证码
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // 联机文件名
          public string FILENAME
          {
              get { return  Getstring("FILENAME"); }
              set { Setstring("FILENAME",value); }
          }

          // 人工处理状态编码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


