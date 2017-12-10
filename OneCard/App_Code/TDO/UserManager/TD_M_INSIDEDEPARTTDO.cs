using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // 内部部门编码表
     public class TD_M_INSIDEDEPARTTDO : DDOBase
     {
          public TD_M_INSIDEDEPARTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDEDEPART";

               columns = new String[7][];
               columns[0] = new String[]{"DEPARTNO", "string"};
               columns[1] = new String[]{"DEPARTNAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"REMARK", "String"};
               columns[5] = new String[]{"REGIONCODE", "String" };
               columns[6] = new String[] { "USETAG", "String" };
               columnKeys = new String[]{
                   "DEPARTNO",
               };


               array = new String[7];
               hash.Add("DEPARTNO", 0);
               hash.Add("DEPARTNAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("REMARK", 4);
               hash.Add("REGIONCODE", 5);
               hash.Add("USETAG", 6);
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 部门名称
          public String DEPARTNAME
          {
              get { return  GetString("DEPARTNAME"); }
              set { SetString("DEPARTNAME",value); }
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
          // 归属区域
          public String REGIONCODE
          {
              get { return GetString("REGIONCODE"); }
              set { SetString("REGIONCODE", value); }
          }

         //有效标识
          public String USETAG
          {
              get { return GetString("USETAG"); }
              set { SetString("USETAG", value); }
          }

     }
}


