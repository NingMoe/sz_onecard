using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // ��¼��־��
     public class TF_B_LOGONLOGTDO : DDOBase
     {
          public TF_B_LOGONLOGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_LOGONLOG";

               columns = new String[6][];
               columns[0] = new String[]{"DEPARTNO", "string"};
               columns[1] = new String[]{"STAFFNO", "string"};
               columns[2] = new String[]{"OPERCARDNO", "string"};
               columns[3] = new String[]{"IPADDR", "String"};
               columns[4] = new String[]{"LOGONTIME", "DateTime"};
               columns[5] = new String[]{"LOGONPAGE", "String"};

               columnKeys = new String[]{
               };


               array = new String[6];
               hash.Add("DEPARTNO", 0);
               hash.Add("STAFFNO", 1);
               hash.Add("OPERCARDNO", 2);
               hash.Add("IPADDR", 3);
               hash.Add("LOGONTIME", 4);
               hash.Add("LOGONPAGE", 5);
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
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

          // ��¼ʱ��
          public DateTime LOGONTIME
          {
              get { return  GetDateTime("LOGONTIME"); }
              set { SetDateTime("LOGONTIME",value); }
          }

          // ��¼����
          public String LOGONPAGE
          {
              get { return  GetString("LOGONPAGE"); }
              set { SetString("LOGONPAGE",value); }
          }

     }
}


