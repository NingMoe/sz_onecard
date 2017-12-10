using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // 内部员工编码表
     public class TD_M_INSIDESTAFFTDO : DDOBase
     {
          public TD_M_INSIDESTAFFTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDESTAFF";

               columns = new String[9][];
               columns[0] = new String[]{"STAFFNO", "string"};
               columns[1] = new String[]{"STAFFNAME", "String"};
               columns[2] = new String[]{"OPERCARDNO", "string"};
               columns[3] = new String[]{"OPERCARDPWD", "String"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"DIMISSIONTAG", "string"};
               columns[6] = new String[]{"UPDATESTAFFNO", "string"};
               columns[7] = new String[]{"UPDATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "STAFFNO",
               };


               array = new String[9];
               hash.Add("STAFFNO", 0);
               hash.Add("STAFFNAME", 1);
               hash.Add("OPERCARDNO", 2);
               hash.Add("OPERCARDPWD", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("DIMISSIONTAG", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("UPDATETIME", 7);
               hash.Add("REMARK", 8);
          }

          // 员工编码
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // 员工姓名
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // 员工卡号
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // 员工卡密码
          public String OPERCARDPWD
          {
              get { return  GetString("OPERCARDPWD"); }
              set { SetString("OPERCARDPWD",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 离职标志
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
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


