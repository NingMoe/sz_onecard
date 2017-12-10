using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ���ſͻ����ϱ���ӱ�
     public class TF_B_GROUP_CUSTOMERCHANGETDO : DDOBase
     {
          public TF_B_GROUP_CUSTOMERCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_GROUP_CUSTOMERCHANGE";

               columns = new String[10][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CORPCODE", "string"};
               columns[2] = new String[]{"CORPNAME", "String"};
               columns[3] = new String[]{"LINKMAN", "String"};
               columns[4] = new String[]{"CORPADD", "String"};
               columns[5] = new String[]{"CORPPHONE", "String"};
               columns[6] = new String[]{"CORPEMAIL", "String"};
               columns[7] = new String[]{"SERMANAGERCODE", "string"};
               columns[8] = new String[]{"RSRV1", "String"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[10];
               hash.Add("TRADEID", 0);
               hash.Add("CORPCODE", 1);
               hash.Add("CORPNAME", 2);
               hash.Add("LINKMAN", 3);
               hash.Add("CORPADD", 4);
               hash.Add("CORPPHONE", 5);
               hash.Add("CORPEMAIL", 6);
               hash.Add("SERMANAGERCODE", 7);
               hash.Add("RSRV1", 8);
               hash.Add("REMARK", 9);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ���ſͻ�����
          public string CORPCODE
          {
              get { return  Getstring("CORPCODE"); }
              set { Setstring("CORPCODE",value); }
          }

          // ���ſͻ�����
          public String CORPNAME
          {
              get { return  GetString("CORPNAME"); }
              set { SetString("CORPNAME",value); }
          }

          // ��ϵ��
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // ��ϵ��ַ
          public String CORPADD
          {
              get { return  GetString("CORPADD"); }
              set { SetString("CORPADD",value); }
          }

          // ��ϵ�绰
          public String CORPPHONE
          {
              get { return  GetString("CORPPHONE"); }
              set { SetString("CORPPHONE",value); }
          }

          // EMAIL��ַ
          public String CORPEMAIL
          {
              get { return  GetString("CORPEMAIL"); }
              set { SetString("CORPEMAIL",value); }
          }

          // �ͷ��������
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


