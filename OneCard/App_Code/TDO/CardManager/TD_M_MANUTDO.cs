using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 厂商编码表
     public class TD_M_MANUTDO : DDOBase
     {
          public TD_M_MANUTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_MANU";

               columns = new String[7][];
               columns[0] = new String[]{"MANUCODE", "string"};
               columns[1] = new String[]{"MANUNAME", "String"};
               columns[2] = new String[]{"MANUNOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "MANUCODE",
               };


               array = new String[7];
               hash.Add("MANUCODE", 0);
               hash.Add("MANUNAME", 1);
               hash.Add("MANUNOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // 厂商编码
          public string MANUCODE
          {
              get { return  Getstring("MANUCODE"); }
              set { Setstring("MANUCODE",value); }
          }

          // 厂商名称
          public String MANUNAME
          {
              get { return  GetString("MANUNAME"); }
              set { SetString("MANUNAME",value); }
          }

          // 厂商说明
          public String MANUNOTE
          {
              get { return  GetString("MANUNOTE"); }
              set { SetString("MANUNOTE",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


