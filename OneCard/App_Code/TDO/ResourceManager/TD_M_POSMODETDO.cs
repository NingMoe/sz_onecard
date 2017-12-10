using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS型号编码表
     public class TD_M_POSMODETDO : DDOBase
     {
          public TD_M_POSMODETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSMODE";

               columns = new String[7][];
               columns[0] = new String[]{"POSMODECODE", "string"};
               columns[1] = new String[]{"POSMODE", "String"};
               columns[2] = new String[]{"MODEMARK", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "POSMODECODE",
               };


               array = new String[7];
               hash.Add("POSMODECODE", 0);
               hash.Add("POSMODE", 1);
               hash.Add("MODEMARK", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // POS型号编码
          public string POSMODECODE
          {
              get { return  Getstring("POSMODECODE"); }
              set { Setstring("POSMODECODE",value); }
          }

          // POS型号
          public String POSMODE
          {
              get { return  GetString("POSMODE"); }
              set { SetString("POSMODE",value); }
          }

          // 型号说明
          public String MODEMARK
          {
              get { return  GetString("MODEMARK"); }
              set { SetString("MODEMARK",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


