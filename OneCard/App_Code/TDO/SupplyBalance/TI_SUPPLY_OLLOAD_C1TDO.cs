using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 非实时充值联机文件入库临时表
     public class TI_SUPPLY_OLLOAD_C1TDO : DDOBase
     {
          public TI_SUPPLY_OLLOAD_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TI_SUPPLY_OLLOAD_C1";

               columns = new String[15][];
               columns[0] = new String[]{"ASN", "string"};
               columns[1] = new String[]{"CARDTRADENO", "string"};
               columns[2] = new String[]{"TRADETYPECODE", "string"};
               columns[3] = new String[]{"SUPPLYLOCNO", "string"};
               columns[4] = new String[]{"SAMNO", "string"};
               columns[5] = new String[]{"STAFFNO", "string"};
               columns[6] = new String[]{"PREMONEY", "Int32"};
               columns[7] = new String[]{"TRADEMONEY", "Int32"};
               columns[8] = new String[]{"TRADEDATE", "string"};
               columns[9] = new String[]{"TRADETIME", "string"};
               columns[10] = new String[]{"RESULT", "string"};
               columns[11] = new String[]{"POSNO", "string"};
               columns[12] = new String[]{"TAC", "string"};
               columns[13] = new String[]{"FILENAME", "string"};
               columns[14] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[15];
               hash.Add("ASN", 0);
               hash.Add("CARDTRADENO", 1);
               hash.Add("TRADETYPECODE", 2);
               hash.Add("SUPPLYLOCNO", 3);
               hash.Add("SAMNO", 4);
               hash.Add("STAFFNO", 5);
               hash.Add("PREMONEY", 6);
               hash.Add("TRADEMONEY", 7);
               hash.Add("TRADEDATE", 8);
               hash.Add("TRADETIME", 9);
               hash.Add("RESULT", 10);
               hash.Add("POSNO", 11);
               hash.Add("TAC", 12);
               hash.Add("FILENAME", 13);
               hash.Add("RSRVCHAR", 14);
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

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


