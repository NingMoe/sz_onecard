using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // 卡片锁定类型编码表
     public class TD_M_LOCKTYPETDO : DDOBase
     {
          public TD_M_LOCKTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_LOCKTYPE";

               columns = new String[4][];
               columns[0] = new String[]{"LOCKTYPECODE", "string"};
               columns[1] = new String[]{"LOCKTYPE", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "LOCKTYPECODE",
               };


               array = new String[4];
               hash.Add("LOCKTYPECODE", 0);
               hash.Add("LOCKTYPE", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
          }

          // 锁定类型编码
          public string LOCKTYPECODE
          {
              get { return  Getstring("LOCKTYPECODE"); }
              set { Setstring("LOCKTYPECODE",value); }
          }

          // 锁定类型
          public String LOCKTYPE
          {
              get { return  GetString("LOCKTYPE"); }
              set { SetString("LOCKTYPE",value); }
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


