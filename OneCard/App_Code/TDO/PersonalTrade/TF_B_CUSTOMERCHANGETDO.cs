using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // �ͻ����ϱ���ӱ�
     public class TF_B_CUSTOMERCHANGETDO : DDOBase
     {
          public TF_B_CUSTOMERCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_CUSTOMERCHANGE";

               columns = new String[17][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"CUSTNAME", "String"};
               columns[3] = new String[]{"CUSTSEX", "String"};
               columns[4] = new String[]{"CUSTBIRTH", "String"};
               columns[5] = new String[]{"PAPERTYPECODE", "String"};
               columns[6] = new String[]{"PAPERNO", "String"};
               columns[7] = new String[]{"CUSTADDR", "String"};
               columns[8] = new String[]{"CUSTPOST", "String"};
               columns[9] = new String[]{"CUSTPHONE", "String"};
               columns[10] = new String[]{"CUSTEMAIL", "String"};
               columns[11] = new String[]{"PASSWD", "string"};
               columns[12] = new String[]{"CHGTYPECODE", "string"};
               columns[13] = new String[]{"OPERATESTAFFNO", "string"};
               columns[14] = new String[]{"OPERATEDEPARTID", "string"};
               columns[15] = new String[]{"OPERATETIME", "DateTime"};
               columns[16] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
                   "CARDNO",
               };


               array = new String[17];
               hash.Add("TRADEID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("CUSTNAME", 2);
               hash.Add("CUSTSEX", 3);
               hash.Add("CUSTBIRTH", 4);
               hash.Add("PAPERTYPECODE", 5);
               hash.Add("PAPERNO", 6);
               hash.Add("CUSTADDR", 7);
               hash.Add("CUSTPOST", 8);
               hash.Add("CUSTPHONE", 9);
               hash.Add("CUSTEMAIL", 10);
               hash.Add("PASSWD", 11);
               hash.Add("CHGTYPECODE", 12);
               hash.Add("OPERATESTAFFNO", 13);
               hash.Add("OPERATEDEPARTID", 14);
               hash.Add("OPERATETIME", 15);
               hash.Add("REMARK", 16);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ����
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // �Ա�
          public String CUSTSEX
          {
              get { return  GetString("CUSTSEX"); }
              set { SetString("CUSTSEX",value); }
          }

          // ��������
          public String CUSTBIRTH
          {
              get { return  GetString("CUSTBIRTH"); }
              set { SetString("CUSTBIRTH",value); }
          }

          // ֤�����ͱ���
          public String PAPERTYPECODE
          {
              get { return  GetString("PAPERTYPECODE"); }
              set { SetString("PAPERTYPECODE",value); }
          }

          // ֤������
          public String PAPERNO
          {
              get { return  GetString("PAPERNO"); }
              set { SetString("PAPERNO",value); }
          }

          // ��ϵ��ַ
          public String CUSTADDR
          {
              get { return  GetString("CUSTADDR"); }
              set { SetString("CUSTADDR",value); }
          }

          // ��������
          public String CUSTPOST
          {
              get { return  GetString("CUSTPOST"); }
              set { SetString("CUSTPOST",value); }
          }

          // ��ϵ�绰
          public String CUSTPHONE
          {
              get { return  GetString("CUSTPHONE"); }
              set { SetString("CUSTPHONE",value); }
          }

          // EMAIL��ַ
          public String CUSTEMAIL
          {
              get { return  GetString("CUSTEMAIL"); }
              set { SetString("CUSTEMAIL",value); }
          }

          // �ͻ�����
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // ������ͱ���
          public string CHGTYPECODE
          {
              get { return  Getstring("CHGTYPECODE"); }
              set { Setstring("CHGTYPECODE",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ���ű���
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


