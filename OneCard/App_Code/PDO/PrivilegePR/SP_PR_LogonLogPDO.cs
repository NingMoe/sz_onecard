using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PrivilegePR
{
     // 登录日志录入
     public class SP_PR_LogonLogPDO : PDOBase
     {
          public SP_PR_LogonLogPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PR_LogonLog",8);

               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@IPADDR", "String", "15", "input");
               AddField("@LOGONPAGE", "String", "30", "input");

               InitEnd();
          }

          // 员工卡号
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // 允许登录IP地址
          public String IPADDR
          {
              get { return  GetString("IPADDR"); }
              set { SetString("IPADDR",value); }
          }

          // 登录界面
          public String LOGONPAGE
          {
              get { return  GetString("LOGONPAGE"); }
              set { SetString("LOGONPAGE",value); }
          }

     }
}


