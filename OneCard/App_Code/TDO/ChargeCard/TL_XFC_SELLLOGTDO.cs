using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // 前台充值卡售卡日志表
     public class TL_XFC_SELLLOGTDO : DDOBase
     {
          public TL_XFC_SELLLOGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_XFC_SELLLOG";

               columns = new String[7][];
               columns[0] = new String[]{"XFCARDNO", "string"};
               columns[1] = new String[]{"STAFFNO", "string"};
               columns[2] = new String[]{"SELLTIME", "DateTime"};
               columns[3] = new String[]{"REMARK", "String"};
               columns[4] = new String[]{"RSRV1", "string"};
               columns[5] = new String[]{"RSRV2", "string"};
               columns[6] = new String[]{"RSRV3", "Int32"};

               columnKeys = new String[]{
                   "XFCARDNO",
               };


               array = new String[7];
               hash.Add("XFCARDNO", 0);
               hash.Add("STAFFNO", 1);
               hash.Add("SELLTIME", 2);
               hash.Add("REMARK", 3);
               hash.Add("RSRV1", 4);
               hash.Add("RSRV2", 5);
               hash.Add("RSRV3", 6);
          }

          // 充值卡号
          public string XFCARDNO
          {
              get { return  Getstring("XFCARDNO"); }
              set { Setstring("XFCARDNO",value); }
          }

          // 操作员
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 售出日期
          public DateTime SELLTIME
          {
              get { return  GetDateTime("SELLTIME"); }
              set { SetDateTime("SELLTIME",value); }
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


