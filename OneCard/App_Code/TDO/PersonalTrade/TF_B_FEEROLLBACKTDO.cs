using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 现金返销授权台帐表
     public class TF_B_FEEROLLBACKTDO : DDOBase
     {
          public TF_B_FEEROLLBACKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_FEEROLLBACK";

               columns = new String[9][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CANCELTRADEID", "string"};
               columns[2] = new String[]{"CANCELTAG", "string"};
               columns[3] = new String[]{"OPERATESTAFFNO", "string"};
               columns[4] = new String[]{"OPERATEDEPARTID", "string"};
               columns[5] = new String[]{"OPERATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "Int32"};
               columns[7] = new String[]{"RSRV2", "String"};
               columns[8] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[9];
               hash.Add("TRADEID", 0);
               hash.Add("CANCELTRADEID", 1);
               hash.Add("CANCELTAG", 2);
               hash.Add("OPERATESTAFFNO", 3);
               hash.Add("OPERATEDEPARTID", 4);
               hash.Add("OPERATETIME", 5);
               hash.Add("RSRV1", 6);
               hash.Add("RSRV2", 7);
               hash.Add("RSRV3", 8);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 返销记录流水号
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // 返销状态
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // 操作员工编码
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // 部门编码
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // 备用1
          public Int32 RSRV1
          {
              get { return  GetInt32("RSRV1"); }
              set { SetInt32("RSRV1",value); }
          }

          // 备用2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // 备用3
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


