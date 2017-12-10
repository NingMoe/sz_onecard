using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // 角色权限对象表
     public class TD_M_ROLEPOWERTDO : DDOBase
     {
          public TD_M_ROLEPOWERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_ROLEPOWER";

               columns = new String[4][];
               columns[0] = new String[]{"ROLENO", "string"};
               columns[1] = new String[]{"POWERCODE", "string"};
               columns[2] = new String[]{"POWERTYPE", "string"};
               columns[3] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ROLENO",
                   "POWERCODE",
               };


               array = new String[4];
               hash.Add("ROLENO", 0);
               hash.Add("POWERCODE", 1);
               hash.Add("POWERTYPE", 2);
               hash.Add("REMARK", 3);
          }

          // 角色编码
          public string ROLENO
          {
              get { return  Getstring("ROLENO"); }
              set { Setstring("ROLENO",value); }
          }

          // 权限编码
          public string POWERCODE
          {
              get { return  Getstring("POWERCODE"); }
              set { Setstring("POWERCODE",value); }
          }

          // 权限类别
          public string POWERTYPE
          {
              get { return  Getstring("POWERTYPE"); }
              set { Setstring("POWERTYPE",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


