using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // �޸��û�����
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

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ���ſͻ�����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ������
          public string OLDPASSWD
          {
              get { return  Getstring("OLDPASSWD"); }
              set { Setstring("OLDPASSWD",value); }
          }

          // ������
          public string NEWPASSWD
          {
              get { return  Getstring("NEWPASSWD"); }
              set { Setstring("NEWPASSWD",value); }
          }

     }
}


