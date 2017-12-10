using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 企服卡可充值账户表
     public class TF_F_CARDOFFERACCTDO : DDOBase
     {
          public TF_F_CARDOFFERACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDOFFERACC";

               columns = new String[13][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"OFFERMONEY", "Int32"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"PASSWD", "string"};
               columns[4] = new String[]{"BEGINTIME", "DateTime"};
               columns[5] = new String[]{"ENDTIME", "DateTime"};
               columns[6] = new String[]{"LASUPPLYMONEY", "Int32"};
               columns[7] = new String[]{"LASUPPLYTIME", "DateTime"};
               columns[8] = new String[]{"TOTALSUPPLYTIMES", "Int32"};
               columns[9] = new String[]{"TOTALSUPPLYMONEY", "Int32"};
               columns[10] = new String[]{"LASTSUPPLYPOSNO", "string"};
               columns[11] = new String[]{"LASTSUPPLYSAMNO", "string"};
               columns[12] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[13];
               hash.Add("CARDNO", 0);
               hash.Add("OFFERMONEY", 1);
               hash.Add("USETAG", 2);
               hash.Add("PASSWD", 3);
               hash.Add("BEGINTIME", 4);
               hash.Add("ENDTIME", 5);
               hash.Add("LASUPPLYMONEY", 6);
               hash.Add("LASUPPLYTIME", 7);
               hash.Add("TOTALSUPPLYTIMES", 8);
               hash.Add("TOTALSUPPLYMONEY", 9);
               hash.Add("LASTSUPPLYPOSNO", 10);
               hash.Add("LASTSUPPLYSAMNO", 11);
               hash.Add("REMARK", 12);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 可充金额
          public Int32 OFFERMONEY
          {
              get { return  GetInt32("OFFERMONEY"); }
              set { SetInt32("OFFERMONEY",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 充值密码
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // 有效起始日期
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // 有效结束日期
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // 最近实际充值金额
          public Int32 LASUPPLYMONEY
          {
              get { return  GetInt32("LASUPPLYMONEY"); }
              set { SetInt32("LASUPPLYMONEY",value); }
          }

          // 最近实际充值时间
          public DateTime LASUPPLYTIME
          {
              get { return  GetDateTime("LASUPPLYTIME"); }
              set { SetDateTime("LASUPPLYTIME",value); }
          }

          // 总充值次数
          public Int32 TOTALSUPPLYTIMES
          {
              get { return  GetInt32("TOTALSUPPLYTIMES"); }
              set { SetInt32("TOTALSUPPLYTIMES",value); }
          }

          // 总充值金额
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // 最近实际充值POS编号
          public string LASTSUPPLYPOSNO
          {
              get { return  Getstring("LASTSUPPLYPOSNO"); }
              set { Setstring("LASTSUPPLYPOSNO",value); }
          }

          // 最近实际充值PSAM编号
          public string LASTSUPPLYSAMNO
          {
              get { return  Getstring("LASTSUPPLYSAMNO"); }
              set { Setstring("LASTSUPPLYSAMNO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


