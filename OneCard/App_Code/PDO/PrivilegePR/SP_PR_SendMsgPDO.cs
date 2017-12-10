using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PrivilegePR
{
     // 消息发送
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

          // 消息编码
          public Int32 msgid
          {
              get { return  GetInt32("msgid"); }
              set { SetInt32("msgid",value); }
          }

          // 消息主题
          public String msgtitle
          {
              get { return  GetString("msgtitle"); }
              set { SetString("msgtitle",value); }
          }

          // 消息体
          public String msgbody
          {
              get { return  GetString("msgbody"); }
              set { SetString("msgbody",value); }
          }

          // 消息级别
          public Int32 msglevel
          {
              get { return  GetInt32("msglevel"); }
              set { SetInt32("msglevel",value); }
          }

          // 消息附件
          public String msgattach
          {
              get { return  GetString("msgattach"); }
              set { SetString("msgattach",value); }
          }

          // 消息发往部门列表
          public String depts
          {
              get { return  GetString("depts"); }
              set { SetString("depts",value); }
          }

          // 消息发往角色列表
          public String roles
          {
              get { return  GetString("roles"); }
              set { SetString("roles",value); }
          }

          // 消息发往员工列表
          public String staffs
          {
              get { return  GetString("staffs"); }
              set { SetString("staffs",value); }
          }

          // 消息位置
          public Int32 msgpos
          {
              get { return  GetInt32("msgpos"); }
              set { SetInt32("msgpos",value); }
          }

     }
}


