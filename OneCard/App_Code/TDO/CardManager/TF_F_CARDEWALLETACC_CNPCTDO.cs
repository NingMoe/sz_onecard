using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 中石油IC卡电子钱包账户表
     public class TF_F_CARDEWALLETACC_CNPCTDO : DDOBase
     {
          public TF_F_CARDEWALLETACC_CNPCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDEWALLETACC_CNPC";

               columns = new String[24][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"CARDACCMONEY", "Int32"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"CREDITSTATECODE", "string"};
               columns[4] = new String[]{"CREDITSTACHANGETIME", "DateTime"};
               columns[5] = new String[]{"CREDITCONTROLCODE", "string"};
               columns[6] = new String[]{"CREDITCOLCHANGETIME", "DateTime"};
               columns[7] = new String[]{"ACCSTATECODE", "string"};
               columns[8] = new String[]{"CONSUMEREALMONEY", "Int32"};
               columns[9] = new String[]{"SUPPLYREALMONEY", "Int32"};
               columns[10] = new String[]{"TOTALCONSUMETIMES", "Int32"};
               columns[11] = new String[]{"TOTALSUPPLYTIMES", "Int32"};
               columns[12] = new String[]{"TOTALCONSUMEMONEY", "Int32"};
               columns[13] = new String[]{"TOTALSUPPLYMONEY", "Int32"};
               columns[14] = new String[]{"FIRSTCONSUMETIME", "DateTime"};
               columns[15] = new String[]{"LASTCONSUMETIME", "DateTime"};
               columns[16] = new String[]{"FIRSTSUPPLYTIME", "DateTime"};
               columns[17] = new String[]{"LASTSUPPLYTIME", "DateTime"};
               columns[18] = new String[]{"OFFLINECARDTRADENO", "string"};
               columns[19] = new String[]{"ONLINECARDTRADENO", "string"};
               columns[20] = new String[]{"RSRV1", "String"};
               columns[21] = new String[]{"RSRV2", "String"};
               columns[22] = new String[]{"RSRV3", "DateTime"};
               columns[23] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[24];
               hash.Add("CARDNO", 0);
               hash.Add("CARDACCMONEY", 1);
               hash.Add("USETAG", 2);
               hash.Add("CREDITSTATECODE", 3);
               hash.Add("CREDITSTACHANGETIME", 4);
               hash.Add("CREDITCONTROLCODE", 5);
               hash.Add("CREDITCOLCHANGETIME", 6);
               hash.Add("ACCSTATECODE", 7);
               hash.Add("CONSUMEREALMONEY", 8);
               hash.Add("SUPPLYREALMONEY", 9);
               hash.Add("TOTALCONSUMETIMES", 10);
               hash.Add("TOTALSUPPLYTIMES", 11);
               hash.Add("TOTALCONSUMEMONEY", 12);
               hash.Add("TOTALSUPPLYMONEY", 13);
               hash.Add("FIRSTCONSUMETIME", 14);
               hash.Add("LASTCONSUMETIME", 15);
               hash.Add("FIRSTSUPPLYTIME", 16);
               hash.Add("LASTSUPPLYTIME", 17);
               hash.Add("OFFLINECARDTRADENO", 18);
               hash.Add("ONLINECARDTRADENO", 19);
               hash.Add("RSRV1", 20);
               hash.Add("RSRV2", 21);
               hash.Add("RSRV3", 22);
               hash.Add("REMARK", 23);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 账户余额
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 信用状态编码
          public string CREDITSTATECODE
          {
              get { return  Getstring("CREDITSTATECODE"); }
              set { Setstring("CREDITSTATECODE",value); }
          }

          // 信用状态更新时间
          public DateTime CREDITSTACHANGETIME
          {
              get { return  GetDateTime("CREDITSTACHANGETIME"); }
              set { SetDateTime("CREDITSTACHANGETIME",value); }
          }

          // 信用控制方式编码
          public string CREDITCONTROLCODE
          {
              get { return  Getstring("CREDITCONTROLCODE"); }
              set { Setstring("CREDITCONTROLCODE",value); }
          }

          // 信用控制方式更新时间
          public DateTime CREDITCOLCHANGETIME
          {
              get { return  GetDateTime("CREDITCOLCHANGETIME"); }
              set { SetDateTime("CREDITCOLCHANGETIME",value); }
          }

          // 帐户状态
          public string ACCSTATECODE
          {
              get { return  Getstring("ACCSTATECODE"); }
              set { Setstring("ACCSTATECODE",value); }
          }

          // 最近卡消费实际余额
          public Int32 CONSUMEREALMONEY
          {
              get { return  GetInt32("CONSUMEREALMONEY"); }
              set { SetInt32("CONSUMEREALMONEY",value); }
          }

          // 最近卡充值实际余额
          public Int32 SUPPLYREALMONEY
          {
              get { return  GetInt32("SUPPLYREALMONEY"); }
              set { SetInt32("SUPPLYREALMONEY",value); }
          }

          // 总消费次数
          public Int32 TOTALCONSUMETIMES
          {
              get { return  GetInt32("TOTALCONSUMETIMES"); }
              set { SetInt32("TOTALCONSUMETIMES",value); }
          }

          // 总充值次数
          public Int32 TOTALSUPPLYTIMES
          {
              get { return  GetInt32("TOTALSUPPLYTIMES"); }
              set { SetInt32("TOTALSUPPLYTIMES",value); }
          }

          // 总消费金额
          public Int32 TOTALCONSUMEMONEY
          {
              get { return  GetInt32("TOTALCONSUMEMONEY"); }
              set { SetInt32("TOTALCONSUMEMONEY",value); }
          }

          // 总充值金额
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // 首次消费时间
          public DateTime FIRSTCONSUMETIME
          {
              get { return  GetDateTime("FIRSTCONSUMETIME"); }
              set { SetDateTime("FIRSTCONSUMETIME",value); }
          }

          // 最近消费时间
          public DateTime LASTCONSUMETIME
          {
              get { return  GetDateTime("LASTCONSUMETIME"); }
              set { SetDateTime("LASTCONSUMETIME",value); }
          }

          // 首次充值时间
          public DateTime FIRSTSUPPLYTIME
          {
              get { return  GetDateTime("FIRSTSUPPLYTIME"); }
              set { SetDateTime("FIRSTSUPPLYTIME",value); }
          }

          // 最近充值时间
          public DateTime LASTSUPPLYTIME
          {
              get { return  GetDateTime("LASTSUPPLYTIME"); }
              set { SetDateTime("LASTSUPPLYTIME",value); }
          }

          // 最近脱机交易序号
          public string OFFLINECARDTRADENO
          {
              get { return  Getstring("OFFLINECARDTRADENO"); }
              set { Setstring("OFFLINECARDTRADENO",value); }
          }

          // 最近联机交易序号
          public string ONLINECARDTRADENO
          {
              get { return  Getstring("ONLINECARDTRADENO"); }
              set { Setstring("ONLINECARDTRADENO",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // 备用2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // 备用3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


