using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 资源状态编码表
     public class TD_M_RESOURCESTATETDO : DDOBase
     {
          public TD_M_RESOURCESTATETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_RESOURCESTATE";

               columns = new String[5][];
               columns[0] = new String[]{"RESSTATECODE", "string"};
               columns[1] = new String[]{"RESSTATE", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "RESSTATECODE",
               };


               array = new String[5];
               hash.Add("RESSTATECODE", 0);
               hash.Add("RESSTATE", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("RSRV1", 4);
          }

          // 资源状态编码
          public string RESSTATECODE
          {
              get { return  Getstring("RESSTATECODE"); }
              set { Setstring("RESSTATECODE",value); }
          }

          // 状态描述
          public String RESSTATE
          {
              get { return  GetString("RESSTATE"); }
              set { SetString("RESSTATE",value); }
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

     }
}


