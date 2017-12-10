using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 业务功能关联表
     public class TF_F_CARDUSEAREATDO : DDOBase
     {
          public TF_F_CARDUSEAREATDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDUSEAREA";

               columns = new String[8][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"FUNCTIONTYPE", "string"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"ENDTIME", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};
               columns[7] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "FUNCTIONTYPE",
               };


               array = new String[8];
               hash.Add("CARDNO", 0);
               hash.Add("FUNCTIONTYPE", 1);
               hash.Add("USETAG", 2);
               hash.Add("ENDTIME", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
               hash.Add("RSRV2", 7);
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 功能编码
          public string FUNCTIONTYPE
          {
              get { return  Getstring("FUNCTIONTYPE"); }
              set { Setstring("FUNCTIONTYPE",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 有效时间
          public string ENDTIME
          {
              get { return  Getstring("ENDTIME"); }
              set { Setstring("ENDTIME",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
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


