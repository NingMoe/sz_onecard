using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // ���ſͻ����ϱ�
     public class TD_GROUP_CUSTOMERTDO : DDOBase
     {
          public TD_GROUP_CUSTOMERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_GROUP_CUSTOMER";

               columns = new String[14][];
               columns[0] = new String[]{"CORPCODE", "string"};
               columns[1] = new String[]{"CORPNAME", "String"};
               columns[2] = new String[]{"LINKMAN", "String"};
               columns[3] = new String[]{"CORPADD", "String"};
               columns[4] = new String[]{"CORPPHONE", "String"};
               columns[5] = new String[]{"CORPEMAIL", "String"};
               columns[6] = new String[]{"USETAG", "string"};
               columns[7] = new String[]{"SERMANAGERCODE", "string"};
               columns[8] = new String[]{"UPDATESTAFFNO", "string"};
               columns[9] = new String[]{"UPDATETIME", "DateTime"};
               columns[10] = new String[]{"RSRV1", "String"};
               columns[11] = new String[]{"RSRV2", "String"};
               columns[12] = new String[]{"RSRV3", "DateTime"};
               columns[13] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CORPCODE",
               };


               array = new String[14];
               hash.Add("CORPCODE", 0);
               hash.Add("CORPNAME", 1);
               hash.Add("LINKMAN", 2);
               hash.Add("CORPADD", 3);
               hash.Add("CORPPHONE", 4);
               hash.Add("CORPEMAIL", 5);
               hash.Add("USETAG", 6);
               hash.Add("SERMANAGERCODE", 7);
               hash.Add("UPDATESTAFFNO", 8);
               hash.Add("UPDATETIME", 9);
               hash.Add("RSRV1", 10);
               hash.Add("RSRV2", 11);
               hash.Add("RSRV3", 12);
               hash.Add("REMARK", 13);
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

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // �ͷ��������
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
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

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


