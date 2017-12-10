using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // �ֿ������ϱ��ݱ�
     public class TB_F_CUSTOMERRECTDO : DDOBase
     {
          public TB_F_CUSTOMERRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TB_F_CUSTOMERREC";

               columns = new String[15][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REUSEDATE", "DateTime"};
               columns[2] = new String[]{"CUSTNAME", "String"};
               columns[3] = new String[]{"CUSTSEX", "String"};
               columns[4] = new String[]{"CUSTBIRTH", "String"};
               columns[5] = new String[]{"PAPERTYPECODE", "String"};
               columns[6] = new String[]{"PAPERNO", "String"};
               columns[7] = new String[]{"CUSTADDR", "String"};
               columns[8] = new String[]{"CUSTPOST", "String"};
               columns[9] = new String[]{"CUSTPHONE", "String"};
               columns[10] = new String[]{"CUSTEMAIL", "String"};
               columns[11] = new String[]{"USETAG", "string"};
               columns[12] = new String[]{"UPDATESTAFFNO", "string"};
               columns[13] = new String[]{"UPDATETIME", "DateTime"};
               columns[14] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "REUSEDATE",
               };


               array = new String[15];
               hash.Add("CARDNO", 0);
               hash.Add("REUSEDATE", 1);
               hash.Add("CUSTNAME", 2);
               hash.Add("CUSTSEX", 3);
               hash.Add("CUSTBIRTH", 4);
               hash.Add("PAPERTYPECODE", 5);
               hash.Add("PAPERNO", 6);
               hash.Add("CUSTADDR", 7);
               hash.Add("CUSTPOST", 8);
               hash.Add("CUSTPHONE", 9);
               hash.Add("CUSTEMAIL", 10);
               hash.Add("USETAG", 11);
               hash.Add("UPDATESTAFFNO", 12);
               hash.Add("UPDATETIME", 13);
               hash.Add("REMARK", 14);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��������
          public DateTime REUSEDATE
          {
              get { return  GetDateTime("REUSEDATE"); }
              set { SetDateTime("REUSEDATE",value); }
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

          // ֤������
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

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


