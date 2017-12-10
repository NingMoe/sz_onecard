using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 前台充值卡售卡台帐表
     public class TF_XFC_SELLTDO : DDOBase
     {
          public TF_XFC_SELLTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XFC_SELL";

               columns = new String[14][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"STARTCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"AMOUNT", "Int32"};
               columns[5] = new String[]{"MONEY", "Int32"};
               columns[6] = new String[]{"STAFFNO", "string"};
               columns[7] = new String[]{"OPERATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};
               columns[9] = new String[]{"CANCELTAG", "string"};
               columns[10] = new String[]{"CANCELTRADEID", "string"};
               columns[11] = new String[]{"RSRV1", "string"};
               columns[12] = new String[]{"RSRV2", "string"};
               columns[13] = new String[]{"RSRV3", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[14];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("STARTCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("AMOUNT", 4);
               hash.Add("MONEY", 5);
               hash.Add("STAFFNO", 6);
               hash.Add("OPERATETIME", 7);
               hash.Add("REMARK", 8);
               hash.Add("CANCELTAG", 9);
               hash.Add("CANCELTRADEID", 10);
               hash.Add("RSRV1", 11);
               hash.Add("RSRV2", 12);
               hash.Add("RSRV3", 13);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 起始卡号
          public string STARTCARDNO
          {
              get { return  Getstring("STARTCARDNO"); }
              set { Setstring("STARTCARDNO",value); }
          }

          // 结束卡号
          public string ENDCARDNO
          {
              get { return  Getstring("ENDCARDNO"); }
              set { Setstring("ENDCARDNO",value); }
          }

          // 卡数量
          public Int32 AMOUNT
          {
              get { return  GetInt32("AMOUNT"); }
              set { SetInt32("AMOUNT",value); }
          }

          // 金额
          public Int32 MONEY
          {
              get { return  GetInt32("MONEY"); }
              set { SetInt32("MONEY",value); }
          }

          // 操作员工编码
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // 回退标志
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // 回退业务流水号
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // 备用1
          public string RSRV1
          {
              get { return  Getstring("RSRV1"); }
              set { Setstring("RSRV1",value); }
          }

          // 备用2
          public string RSRV2
          {
              get { return  Getstring("RSRV2"); }
              set { Setstring("RSRV2",value); }
          }

          // 备用3
          public Int32 RSRV3
          {
              get { return  GetInt32("RSRV3"); }
              set { SetInt32("RSRV3",value); }
          }

     }
}


