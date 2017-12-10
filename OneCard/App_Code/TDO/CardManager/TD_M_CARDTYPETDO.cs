using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC卡类型编码表
     public class TD_M_CARDTYPETDO : DDOBase
     {
          public TD_M_CARDTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CARDTYPE";

               columns = new String[8][];
               columns[0] = new String[]{"CARDTYPECODE", "string"};
               columns[1] = new String[]{"CARDTYPENAME", "String"};
               columns[2] = new String[]{"CARDTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"CARDRETURN", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDTYPECODE",
               };


               array = new String[8];
               hash.Add("CARDTYPECODE", 0);
               hash.Add("CARDTYPENAME", 1);
               hash.Add("CARDTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("CARDRETURN", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // 卡类型编码
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 卡类型名称
          public String CARDTYPENAME
          {
              get { return  GetString("CARDTYPENAME"); }
              set { SetString("CARDTYPENAME",value); }
          }

          // 卡类型说明
          public String CARDTYPENOTE
          {
              get { return  GetString("CARDTYPENOTE"); }
              set { SetString("CARDTYPENOTE",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 是否允许退卡
          public string CARDRETURN
          {
              get { return  Getstring("CARDRETURN"); }
              set { Setstring("CARDRETURN",value); }
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

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


