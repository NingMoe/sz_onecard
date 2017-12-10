using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // COS类型编码表
     public class TD_M_COSTYPETDO : DDOBase
     {
          public TD_M_COSTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_COSTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"COSTYPECODE", "string"};
               columns[1] = new String[]{"COSTYPE", "String"};
               columns[2] = new String[]{"COSTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "COSTYPECODE",
               };


               array = new String[7];
               hash.Add("COSTYPECODE", 0);
               hash.Add("COSTYPE", 1);
               hash.Add("COSTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // COS类型编码
          public string COSTYPECODE
          {
              get { return  Getstring("COSTYPECODE"); }
              set { Setstring("COSTYPECODE",value); }
          }

          // COS类型
          public String COSTYPE
          {
              get { return  GetString("COSTYPE"); }
              set { SetString("COSTYPE",value); }
          }

          // COS类型说明
          public String COSTYPENOTE
          {
              get { return  GetString("COSTYPENOTE"); }
              set { SetString("COSTYPENOTE",value); }
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


