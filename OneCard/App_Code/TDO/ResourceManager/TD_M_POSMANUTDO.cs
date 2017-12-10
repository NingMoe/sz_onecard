using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS厂商编码表
     public class TD_M_POSMANUTDO : DDOBase
     {
          public TD_M_POSMANUTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSMANU";

               columns = new String[11][];
               columns[0] = new String[]{"POSMANUCODE", "string"};
               columns[1] = new String[]{"POSMANUNAME", "String"};
               columns[2] = new String[]{"PHONE", "String"};
               columns[3] = new String[]{"FAX", "String"};
               columns[4] = new String[]{"ZIPCODE", "String"};
               columns[5] = new String[]{"EMAIL", "String"};
               columns[6] = new String[]{"ADDRESS", "String"};
               columns[7] = new String[]{"USETAG", "string"};
               columns[8] = new String[]{"UPDATESTAFFNO", "string"};
               columns[9] = new String[]{"UPDATETIME", "DateTime"};
               columns[10] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "POSMANUCODE",
               };


               array = new String[11];
               hash.Add("POSMANUCODE", 0);
               hash.Add("POSMANUNAME", 1);
               hash.Add("PHONE", 2);
               hash.Add("FAX", 3);
               hash.Add("ZIPCODE", 4);
               hash.Add("EMAIL", 5);
               hash.Add("ADDRESS", 6);
               hash.Add("USETAG", 7);
               hash.Add("UPDATESTAFFNO", 8);
               hash.Add("UPDATETIME", 9);
               hash.Add("RSRV1", 10);
          }

          // 厂商编码
          public string POSMANUCODE
          {
              get { return  Getstring("POSMANUCODE"); }
              set { Setstring("POSMANUCODE",value); }
          }

          // 厂商名称
          public String POSMANUNAME
          {
              get { return  GetString("POSMANUNAME"); }
              set { SetString("POSMANUNAME",value); }
          }

          // 厂商电话
          public String PHONE
          {
              get { return  GetString("PHONE"); }
              set { SetString("PHONE",value); }
          }

          // 厂商传真
          public String FAX
          {
              get { return  GetString("FAX"); }
              set { SetString("FAX",value); }
          }

          // 厂商邮编
          public String ZIPCODE
          {
              get { return  GetString("ZIPCODE"); }
              set { SetString("ZIPCODE",value); }
          }

          // 厂商EMAIL
          public String EMAIL
          {
              get { return  GetString("EMAIL"); }
              set { SetString("EMAIL",value); }
          }

          // 厂商地址
          public String ADDRESS
          {
              get { return  GetString("ADDRESS"); }
              set { SetString("ADDRESS",value); }
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


