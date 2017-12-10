using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 非实时充值结算帐单表
     public class TF_SUPPLY_BALANCETDO : DDOBase
     {
          public TF_SUPPLY_BALANCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_BALANCE";

               columns = new String[27][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"FEETYPECODE", "string"};
               columns[6] = new String[]{"BILLTYPECODE", "string"};
               columns[7] = new String[]{"ERRORREASONCODE", "string"};
               columns[8] = new String[]{"TOTALBALFEE", "Int32"};
               columns[9] = new String[]{"TOTALTIMES", "Int32"};
               columns[10] = new String[]{"SINCOMADDFEE", "Int32"};
               columns[11] = new String[]{"BALFEEA", "Int32"};
               columns[12] = new String[]{"TIMESA", "Int32"};
               columns[13] = new String[]{"BALFEEB", "Int32"};
               columns[14] = new String[]{"TIMESB", "Int32"};
               columns[15] = new String[]{"BALFEEC", "Int32"};
               columns[16] = new String[]{"TIMESC", "Int32"};
               columns[17] = new String[]{"BALFEED", "Int32"};
               columns[18] = new String[]{"TIMESD", "Int32"};
               columns[19] = new String[]{"BALFEEE", "Int32"};
               columns[20] = new String[]{"TIMESE", "Int32"};
               columns[21] = new String[]{"BEGINTIME", "DateTime"};
               columns[22] = new String[]{"ENDTIME", "DateTime"};
               columns[23] = new String[]{"BALANCETIME", "DateTime"};
               columns[24] = new String[]{"DEALSTATECODE", "string"};
               columns[25] = new String[]{"RSRVCHAR", "string"};
               columns[26] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[27];
               hash.Add("ID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("FEETYPECODE", 5);
               hash.Add("BILLTYPECODE", 6);
               hash.Add("ERRORREASONCODE", 7);
               hash.Add("TOTALBALFEE", 8);
               hash.Add("TOTALTIMES", 9);
               hash.Add("SINCOMADDFEE", 10);
               hash.Add("BALFEEA", 11);
               hash.Add("TIMESA", 12);
               hash.Add("BALFEEB", 13);
               hash.Add("TIMESB", 14);
               hash.Add("BALFEEC", 15);
               hash.Add("TIMESC", 16);
               hash.Add("BALFEED", 17);
               hash.Add("TIMESD", 18);
               hash.Add("BALFEEE", 19);
               hash.Add("TIMESE", 20);
               hash.Add("BEGINTIME", 21);
               hash.Add("ENDTIME", 22);
               hash.Add("BALANCETIME", 23);
               hash.Add("DEALSTATECODE", 24);
               hash.Add("RSRVCHAR", 25);
               hash.Add("REMARK", 26);
          }

          // 结算流水号
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
          }

          // 结算单元编号
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

          // 费用类型编码
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // 账单类型编码
          public string BILLTYPECODE
          {
              get { return  Getstring("BILLTYPECODE"); }
              set { Setstring("BILLTYPECODE",value); }
          }

          // 异常原因编码
          public string ERRORREASONCODE
          {
              get { return  Getstring("ERRORREASONCODE"); }
              set { Setstring("ERRORREASONCODE",value); }
          }

          // 结算总金额
          public Int32 TOTALBALFEE
          {
              get { return  GetInt32("TOTALBALFEE"); }
              set { SetInt32("TOTALBALFEE",value); }
          }

          // 结算总笔数
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // 单笔累计佣金
          public Int32 SINCOMADDFEE
          {
              get { return  GetInt32("SINCOMADDFEE"); }
              set { SetInt32("SINCOMADDFEE",value); }
          }

          // 结算金额A
          public Int32 BALFEEA
          {
              get { return  GetInt32("BALFEEA"); }
              set { SetInt32("BALFEEA",value); }
          }

          // 结算笔数A
          public Int32 TIMESA
          {
              get { return  GetInt32("TIMESA"); }
              set { SetInt32("TIMESA",value); }
          }

          // 结算金额B
          public Int32 BALFEEB
          {
              get { return  GetInt32("BALFEEB"); }
              set { SetInt32("BALFEEB",value); }
          }

          // 结算笔数B
          public Int32 TIMESB
          {
              get { return  GetInt32("TIMESB"); }
              set { SetInt32("TIMESB",value); }
          }

          // 结算金额C
          public Int32 BALFEEC
          {
              get { return  GetInt32("BALFEEC"); }
              set { SetInt32("BALFEEC",value); }
          }

          // 结算笔数C
          public Int32 TIMESC
          {
              get { return  GetInt32("TIMESC"); }
              set { SetInt32("TIMESC",value); }
          }

          // 结算金额D
          public Int32 BALFEED
          {
              get { return  GetInt32("BALFEED"); }
              set { SetInt32("BALFEED",value); }
          }

          // 结算笔数D
          public Int32 TIMESD
          {
              get { return  GetInt32("TIMESD"); }
              set { SetInt32("TIMESD",value); }
          }

          // 结算金额E
          public Int32 BALFEEE
          {
              get { return  GetInt32("BALFEEE"); }
              set { SetInt32("BALFEEE",value); }
          }

          // 结算笔数E
          public Int32 TIMESE
          {
              get { return  GetInt32("TIMESE"); }
              set { SetInt32("TIMESE",value); }
          }

          // 起始时间
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // 结束时间
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // 结算帐单时间
          public DateTime BALANCETIME
          {
              get { return  GetDateTime("BALANCETIME"); }
              set { SetDateTime("BALANCETIME",value); }
          }

          // 处理状态编码
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

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


