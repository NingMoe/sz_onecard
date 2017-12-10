using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PrivilegePR
{
     // ��Ϣ����
     public class SP_PR_SendMsgPDO : PDOBase
     {
          public SP_PR_SendMsgPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PR_SendMsg",14);

               AddField("@msgid", "Int32", "", "input");
               AddField("@msgtitle", "String", "64", "input");
               AddField("@msgbody", "String", "1024", "input");
               AddField("@msglevel", "Int32", "", "input");
               AddField("@msgattach", "String", "128", "input");
               AddField("@depts", "String", "512", "input");
               AddField("@roles", "String", "512", "input");
               AddField("@staffs", "String", "512", "input");
               AddField("@msgpos", "Int32", "", "input");

               InitEnd();
          }

          // ��Ϣ����
          public Int32 msgid
          {
              get { return  GetInt32("msgid"); }
              set { SetInt32("msgid",value); }
          }

          // ��Ϣ����
          public String msgtitle
          {
              get { return  GetString("msgtitle"); }
              set { SetString("msgtitle",value); }
          }

          // ��Ϣ��
          public String msgbody
          {
              get { return  GetString("msgbody"); }
              set { SetString("msgbody",value); }
          }

          // ��Ϣ����
          public Int32 msglevel
          {
              get { return  GetInt32("msglevel"); }
              set { SetInt32("msglevel",value); }
          }

          // ��Ϣ����
          public String msgattach
          {
              get { return  GetString("msgattach"); }
              set { SetString("msgattach",value); }
          }

          // ��Ϣ���������б�
          public String depts
          {
              get { return  GetString("depts"); }
              set { SetString("depts",value); }
          }

          // ��Ϣ������ɫ�б�
          public String roles
          {
              get { return  GetString("roles"); }
              set { SetString("roles",value); }
          }

          // ��Ϣ����Ա���б�
          public String staffs
          {
              get { return  GetString("staffs"); }
              set { SetString("staffs",value); }
          }

          // ��Ϣλ��
          public Int32 msgpos
          {
              get { return  GetInt32("msgpos"); }
              set { SetInt32("msgpos",value); }
          }

     }
}


