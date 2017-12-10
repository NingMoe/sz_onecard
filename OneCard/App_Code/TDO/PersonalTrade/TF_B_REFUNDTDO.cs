using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 退款业务台帐表
     public class TF_B_REFUNDTDO : DDOBase
     {
          public TF_B_REFUNDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_REFUND";

               columns = new String[16][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"TRADETYPECODE", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"BANKCODE", "string"};
               columns[5] = new String[]{"BANKACCNO", "String"};
               columns[6] = new String[]{"BACKMONEY", "Int32"};
               columns[7] = new String[]{"CUSTNAME", "String"};
               columns[8] = new String[]{"BACKSLOPE", "Decimal"};
               columns[9] = new String[]{"FACTMONEY", "Int32"};
               columns[10] = new String[]{"COLLECTTAG", "string"};
               columns[11] = new String[]{"OPERATESTAFFNO", "string"};
               columns[12] = new String[]{"OPERATETIME", "DateTime"};
               columns[13] = new String[]{"RSRV1", "String"};
               columns[14] = new String[]{"RSRV2", "String"};
               columns[15] = new String[]{"RSRV3", "DateTime"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[16];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("TRADETYPECODE", 2);
               hash.Add("CARDNO", 3);
               hash.Add("BANKCODE", 4);
               hash.Add("BANKACCNO", 5);
               hash.Add("BACKMONEY", 6);
               hash.Add("CUSTNAME", 7);
               hash.Add("BACKSLOPE", 8);
               hash.Add("FACTMONEY", 9);
               hash.Add("COLLECTTAG", 10);
               hash.Add("OPERATESTAFFNO", 11);
               hash.Add("OPERATETIME", 12);
               hash.Add("RSRV1", 13);
               hash.Add("RSRV2", 14);
               hash.Add("RSRV3", 15);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 充值记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 开户银行编码
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // 银行帐号
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // 退款金额
          public Int32 BACKMONEY
          {
              get { return  GetInt32("BACKMONEY"); }
              set { SetInt32("BACKMONEY",value); }
          }

          // 姓名
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // 返还比例
          public Decimal BACKSLOPE
          {
              get { return  GetDecimal("BACKSLOPE"); }
              set { SetDecimal("BACKSLOPE",value); }
          }

          // 实际退款金额
          public Int32 FACTMONEY
          {
              get { return  GetInt32("FACTMONEY"); }
              set { SetInt32("FACTMONEY",value); }
          }

          // 汇总标志
          public string COLLECTTAG
          {
              get { return  Getstring("COLLECTTAG"); }
              set { Setstring("COLLECTTAG",value); }
          }

          // 操作员工编码
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
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

     }
}


