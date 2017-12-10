using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 修改用户密码
     public class SP_GC_ChangeUserPassPDO : PDOBase
     {
          public SP_GC_ChangeUserPassPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_ChangeUserPass",9);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@OLDPASSWD", "string", "12", "input");
               AddField("@NEWPASSWD", "string", "12", "input");

               InitEnd();
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 集团客户编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 旧密码
          public string OLDPASSWD
          {
              get { return  Getstring("OLDPASSWD"); }
              set { Setstring("OLDPASSWD",value); }
          }

          // 新密码
          public string NEWPASSWD
          {
              get { return  Getstring("NEWPASSWD"); }
              set { Setstring("NEWPASSWD",value); }
          }

     }
}


