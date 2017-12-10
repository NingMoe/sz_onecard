using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 出租车消费补录
     public class SP_TS_ConsumeAppendPDO : PDOBase
     {
          public SP_TS_ConsumeAppendPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_TS_ConsumeAppend",21);

               AddField("@IDENTIFYNO", "string", "26", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "5", "input");
               AddField("@SAMNO", "string", "12", "input");
               AddField("@POSTRADENO", "string", "8", "input");
               AddField("@TRADEDATE", "string", "8", "input");
               AddField("@TRADETIME", "string", "6", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@TRADEMONEY", "Int32", "", "input");
               AddField("@BALUNITNO", "string", "8", "input");
               AddField("@CALLINGNO", "string", "2", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DEPARTNO", "string", "4", "input");
               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@TAC", "string", "8", "input");
               AddField("@DEALSTATECODE", "string", "1", "input");

               InitEnd();
          }

          // 记录流水号
          public string IDENTIFYNO
          {
              get { return  Getstring("IDENTIFYNO"); }
              set { Setstring("IDENTIFYNO",value); }
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

          // POS交易号
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

          // TAC码
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // 现金支付
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

     }
}


