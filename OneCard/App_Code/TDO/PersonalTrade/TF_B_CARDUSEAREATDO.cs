using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 卡内资料变更流水表
     public class TF_B_CARDUSEAREATDO : DDOBase
     {
          public TF_B_CARDUSEAREATDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_CARDUSEAREA";

               columns = new String[12][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"REASONCODE", "string"};
               columns[5] = new String[]{"CHANGECON", "string"};
               columns[6] = new String[]{"OPERATESTAFFNO", "string"};
               columns[7] = new String[]{"OPERATEDEPARTID", "string"};
               columns[8] = new String[]{"OPERATETIME", "DateTime"};
               columns[9] = new String[]{"CANCELTAG", "string"};
               columns[10] = new String[]{"RSRV1", "String"};
               columns[11] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[12];
               hash.Add("TRADEID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("ASN", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("REASONCODE", 4);
               hash.Add("CHANGECON", 5);
               hash.Add("OPERATESTAFFNO", 6);
               hash.Add("OPERATEDEPARTID", 7);
               hash.Add("OPERATETIME", 8);
               hash.Add("CANCELTAG", 9);
               hash.Add("RSRV1", 10);
               hash.Add("RSRV2", 11);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 原因编码
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // 变更内容
          public string CHANGECON
          {
              get { return  Getstring("CHANGECON"); }
              set { Setstring("CHANGECON",value); }
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

          // 回退标志
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
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

     }
}


