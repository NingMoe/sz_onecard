using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS放置类型编码表
     public class TD_M_POSLAYTYPETDO : DDOBase
     {
          public TD_M_POSLAYTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSLAYTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"LAYTYPECODE", "string"};
               columns[1] = new String[]{"LAYTYPE", "String"};
               columns[2] = new String[]{"LAYTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "LAYTYPECODE",
               };


               array = new String[7];
               hash.Add("LAYTYPECODE", 0);
               hash.Add("LAYTYPE", 1);
               hash.Add("LAYTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // POS放置类型编码
          public string LAYTYPECODE
          {
              get { return  Getstring("LAYTYPECODE"); }
              set { Setstring("LAYTYPECODE",value); }
          }

          // POS放置类型
          public String LAYTYPE
          {
              get { return  GetString("LAYTYPE"); }
              set { SetString("LAYTYPE",value); }
          }

          // POS放置类型说明
          public String LAYTYPENOTE
          {
              get { return  GetString("LAYTYPENOTE"); }
              set { SetString("LAYTYPENOTE",value); }
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


