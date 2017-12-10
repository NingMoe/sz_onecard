using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 实时充值比对表
     public class TP_SUPPLY_COMP_ONLINETDO : DDOBase
     {
          public TP_SUPPLY_COMP_ONLINETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_SUPPLY_COMP_ONLINE";

               columns = new String[20][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"ASN", "string"};
               columns[2] = new String[]{"CARDTRADENO", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"TRADEID", "string"};
               columns[6] = new String[]{"BANKCARDNO", "string"};
               columns[7] = new String[]{"TRADEDATE", "string"};
               columns[8] = new String[]{"TRADETIME", "string"};
               columns[9] = new String[]{"TRADEMONEY", "Int32"};
               columns[10] = new String[]{"PREMONEY", "Int32"};
               columns[11] = new String[]{"SUPPLYLOCNO", "string"};
               columns[12] = new String[]{"SAMNO", "string"};
               columns[13] = new String[]{"STAFFNO", "string"};
               columns[14] = new String[]{"STATECODE", "string"};
               columns[15] = new String[]{"OPERATETIME", "DateTime"};
               columns[16] = new String[]{"DEALSTATECODE", "string"};
               columns[17] = new String[]{"COMPMONEY", "Int32"};
               columns[18] = new String[]{"BALUNITNO", "string"};
               columns[19] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[20];
               hash.Add("ID", 0);
               hash.Add("ASN", 1);
               hash.Add("CARDTRADENO", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("TRADEID", 5);
               hash.Add("BANKCARDNO", 6);
               hash.Add("TRADEDATE", 7);
               hash.Add("TRADETIME", 8);
               hash.Add("TRADEMONEY", 9);
               hash.Add("PREMONEY", 10);
               hash.Add("SUPPLYLOCNO", 11);
               hash.Add("SAMNO", 12);
               hash.Add("STAFFNO", 13);
               hash.Add("STATECODE", 14);
               hash.Add("OPERATETIME", 15);
               hash.Add("DEALSTATECODE", 16);
               hash.Add("COMPMONEY", 17);
               hash.Add("BALUNITNO", 18);
               hash.Add("RSRVCHAR", 19);
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

          // 业务类型编码
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

          // 银行流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 银行卡号
          public string BANKCARDNO
          {
              get { return  Getstring("BANKCARDNO"); }
              set { Setstring("BANKCARDNO",value); }
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

          // 充值前卡内余额
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

          // 操作员编号
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 状态编码
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // 处理状态码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // 比对交易金额
          public Int32 COMPMONEY
          {
              get { return  GetInt32("COMPMONEY"); }
              set { SetInt32("COMPMONEY",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


