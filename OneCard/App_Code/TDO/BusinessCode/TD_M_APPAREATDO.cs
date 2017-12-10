using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // 月票类型和行政区域对应关系编码表
     public class TD_M_APPAREATDO : DDOBase
     {
          public TD_M_APPAREATDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_APPAREA";

               columns = new String[6][];
               columns[0] = new String[]{"APPTYPE", "string"};
               columns[1] = new String[]{"AREACODE", "string"};
               columns[2] = new String[]{"FLAG", "string"};
               columns[3] = new String[]{"AREANAME", "String"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "APPTYPE",
                   "AREACODE",
               };


               array = new String[6];
               hash.Add("APPTYPE", 0);
               hash.Add("AREACODE", 1);
               hash.Add("FLAG", 2);
               hash.Add("AREANAME", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
          }

          // 月票类型
          public string APPTYPE
          {
              get { return  Getstring("APPTYPE"); }
              set { Setstring("APPTYPE",value); }
          }

          // 行政区域编码
          public string AREACODE
          {
              get { return  Getstring("AREACODE"); }
              set { Setstring("AREACODE",value); }
          }

          // 新旧标识
          public string FLAG
          {
              get { return  Getstring("FLAG"); }
              set { Setstring("FLAG",value); }
          }

          // 行政区域名称
          public String AREANAME
          {
              get { return  GetString("AREANAME"); }
              set { SetString("AREANAME",value); }
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

     }
}


