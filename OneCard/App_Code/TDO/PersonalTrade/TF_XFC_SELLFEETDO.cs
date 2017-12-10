using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 充值卡现金台帐表
     public class TF_XFC_SELLFEETDO : DDOBase
     {
          public TF_XFC_SELLFEETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XFC_SELLFEE";

               columns = new String[11][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"STARTCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"MONEY", "Int32"};
               columns[5] = new String[]{"STAFFNO", "string"};
               columns[6] = new String[]{"OPERATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};
               columns[8] = new String[]{"RSRV1", "string"};
               columns[9] = new String[]{"RSRV2", "string"};
               columns[10] = new String[]{"RSRV3", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[11];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("STARTCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("MONEY", 4);
               hash.Add("STAFFNO", 5);
               hash.Add("OPERATETIME", 6);
               hash.Add("REMARK", 7);
               hash.Add("RSRV1", 8);
               hash.Add("RSRV2", 9);
               hash.Add("RSRV3", 10);
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


