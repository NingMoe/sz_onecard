using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // 充值卡帐户表
     public class TD_XFC_INITCARDTDO : DDOBase
     {
          public TD_XFC_INITCARDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_XFC_INITCARD";

               columns = new String[25][];
               columns[0] = new String[]{"XFCARDNO", "string"};
               columns[1] = new String[]{"PASSWD", "string"};
               columns[2] = new String[]{"YEAR", "string"};
               columns[3] = new String[]{"BATCHNO", "string"};
               columns[4] = new String[]{"VALUECODE", "string"};
               columns[5] = new String[]{"CORPCODE", "string"};
               columns[6] = new String[]{"CARDSTATECODE", "string"};
               columns[7] = new String[]{"PRODUCETIME", "DateTime"};
               columns[8] = new String[]{"PRODUCESTAFFNO", "string"};
               columns[9] = new String[]{"ENDDATE", "DateTime"};
               columns[10] = new String[]{"PRINTTIME", "DateTime"};
               columns[11] = new String[]{"PRINTSTAFFNO", "string"};
               columns[12] = new String[]{"INTIME", "DateTime"};
               columns[13] = new String[]{"INSTAFFNO", "string"};
               columns[14] = new String[]{"ACTIVETIME", "DateTime"};
               columns[15] = new String[]{"ACTIVESTAFFNO", "string"};
               columns[16] = new String[]{"SALETIME", "DateTime"};
               columns[17] = new String[]{"SALESTAFFNO", "string"};
               columns[18] = new String[]{"MERCHANTCODE", "string"};
               columns[19] = new String[]{"CANCELTIME", "DateTime"};
               columns[20] = new String[]{"CANCELSTAFFNO", "string"};
               columns[21] = new String[]{"RSRV1", "String"};
               columns[22] = new String[]{"RSRV2", "Int32"};
               columns[23] = new String[]{"RSRV3", "DateTime"};
               columns[24] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "XFCARDNO",
               };


               array = new String[25];
               hash.Add("XFCARDNO", 0);
               hash.Add("PASSWD", 1);
               hash.Add("YEAR", 2);
               hash.Add("BATCHNO", 3);
               hash.Add("VALUECODE", 4);
               hash.Add("CORPCODE", 5);
               hash.Add("CARDSTATECODE", 6);
               hash.Add("PRODUCETIME", 7);
               hash.Add("PRODUCESTAFFNO", 8);
               hash.Add("ENDDATE", 9);
               hash.Add("PRINTTIME", 10);
               hash.Add("PRINTSTAFFNO", 11);
               hash.Add("INTIME", 12);
               hash.Add("INSTAFFNO", 13);
               hash.Add("ACTIVETIME", 14);
               hash.Add("ACTIVESTAFFNO", 15);
               hash.Add("SALETIME", 16);
               hash.Add("SALESTAFFNO", 17);
               hash.Add("MERCHANTCODE", 18);
               hash.Add("CANCELTIME", 19);
               hash.Add("CANCELSTAFFNO", 20);
               hash.Add("RSRV1", 21);
               hash.Add("RSRV2", 22);
               hash.Add("RSRV3", 23);
               hash.Add("REMARK", 24);
          }

          // 冲值卡号
          public string XFCARDNO
          {
              get { return  Getstring("XFCARDNO"); }
              set { Setstring("XFCARDNO",value); }
          }

          // 密码
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // 制作年份
          public string YEAR
          {
              get { return  Getstring("YEAR"); }
              set { Setstring("YEAR",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // 金额代码
          public string VALUECODE
          {
              get { return  Getstring("VALUECODE"); }
              set { Setstring("VALUECODE",value); }
          }

          // 制作单位代码
          public string CORPCODE
          {
              get { return  Getstring("CORPCODE"); }
              set { Setstring("CORPCODE",value); }
          }

          // 卡状态
          public string CARDSTATECODE
          {
              get { return  Getstring("CARDSTATECODE"); }
              set { Setstring("CARDSTATECODE",value); }
          }

          // 产生时间
          public DateTime PRODUCETIME
          {
              get { return  GetDateTime("PRODUCETIME"); }
              set { SetDateTime("PRODUCETIME",value); }
          }

          // 产生员工
          public string PRODUCESTAFFNO
          {
              get { return  Getstring("PRODUCESTAFFNO"); }
              set { Setstring("PRODUCESTAFFNO",value); }
          }

          // 结束日期
          public DateTime ENDDATE
          {
              get { return  GetDateTime("ENDDATE"); }
              set { SetDateTime("ENDDATE",value); }
          }

          // 印刷时间
          public DateTime PRINTTIME
          {
              get { return  GetDateTime("PRINTTIME"); }
              set { SetDateTime("PRINTTIME",value); }
          }

          // 印刷员工
          public string PRINTSTAFFNO
          {
              get { return  Getstring("PRINTSTAFFNO"); }
              set { Setstring("PRINTSTAFFNO",value); }
          }

          // 入库时间
          public DateTime INTIME
          {
              get { return  GetDateTime("INTIME"); }
              set { SetDateTime("INTIME",value); }
          }

          // 入库员工
          public string INSTAFFNO
          {
              get { return  Getstring("INSTAFFNO"); }
              set { Setstring("INSTAFFNO",value); }
          }

          // 激活时间
          public DateTime ACTIVETIME
          {
              get { return  GetDateTime("ACTIVETIME"); }
              set { SetDateTime("ACTIVETIME",value); }
          }

          // 激活员工
          public string ACTIVESTAFFNO
          {
              get { return  Getstring("ACTIVESTAFFNO"); }
              set { Setstring("ACTIVESTAFFNO",value); }
          }

          // 售卡时间
          public DateTime SALETIME
          {
              get { return  GetDateTime("SALETIME"); }
              set { SetDateTime("SALETIME",value); }
          }

          // 售卡员工
          public string SALESTAFFNO
          {
              get { return  Getstring("SALESTAFFNO"); }
              set { Setstring("SALESTAFFNO",value); }
          }

          // 销售网点代码
          public string MERCHANTCODE
          {
              get { return  Getstring("MERCHANTCODE"); }
              set { Setstring("MERCHANTCODE",value); }
          }

          // 取消标志
          public DateTime CANCELTIME
          {
              get { return  GetDateTime("CANCELTIME"); }
              set { SetDateTime("CANCELTIME",value); }
          }

          // 取消员工
          public string CANCELSTAFFNO
          {
              get { return  Getstring("CANCELSTAFFNO"); }
              set { Setstring("CANCELSTAFFNO",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // 备用2
          public Int32 RSRV2
          {
              get { return  GetInt32("RSRV2"); }
              set { SetInt32("RSRV2",value); }
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


