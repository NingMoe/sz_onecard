using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 充值SAM卡资源表
     public class TD_M_SAMTDO : DDOBase
     {
          public TD_M_SAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SAM";

               columns = new String[10][];
               columns[0] = new String[]{"SAMNO", "string"};
               columns[1] = new String[]{"VERNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"RSRV1", "String"};
               columns[8] = new String[]{"RSRV2", "String"};
               columns[9] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "SAMNO",
               };


               array = new String[10];
               hash.Add("SAMNO", 0);
               hash.Add("VERNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("USETAG", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("RSRV1", 7);
               hash.Add("RSRV2", 8);
               hash.Add("RSRV3", 9);
          }

          // 充值SAM卡号
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // 版本号
          public string VERNO
          {
              get { return  Getstring("VERNO"); }
              set { Setstring("VERNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 更新员工编码
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

          // 备用3
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


