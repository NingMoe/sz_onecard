using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // ��ɫ�����
     public class TD_M_ROLETDO : DDOBase
     {
          public TD_M_ROLETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_ROLE";

               columns = new String[5][];
               columns[0] = new String[]{"ROLENO", "string"};
               columns[1] = new String[]{"ROLENAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ROLENO",
               };


               array = new String[5];
               hash.Add("ROLENO", 0);
               hash.Add("ROLENAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("REMARK", 4);
          }

          // ��ɫ����
          public string ROLENO
          {
              get { return  Getstring("ROLENO"); }
              set { Setstring("ROLENO",value); }
          }

          // ��ɫ����
          public String ROLENAME
          {
              get { return  GetString("ROLENAME"); }
              set { SetString("ROLENAME",value); }
          }

          // ����Ա��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


