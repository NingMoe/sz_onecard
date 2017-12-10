using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PrivilegePR
{
     // ��¼��־¼��
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

          // Ա������
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // �����¼IP��ַ
          public String IPADDR
          {
              get { return  GetString("IPADDR"); }
              set { SetString("IPADDR",value); }
          }

          // ��¼����
          public String LOGONPAGE
          {
              get { return  GetString("LOGONPAGE"); }
              set { SetString("LOGONPAGE",value); }
          }

     }
}


