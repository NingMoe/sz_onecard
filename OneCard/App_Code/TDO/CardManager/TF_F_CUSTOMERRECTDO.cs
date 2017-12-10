using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // �ֿ������ϱ�
     public class TF_F_CUSTOMERRECTDO : DDOBase
     {
          public TF_F_CUSTOMERRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CUSTOMERREC";

               columns = new String[14][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"CUSTNAME", "String"};
               columns[2] = new String[]{"CUSTSEX", "String"};
               columns[3] = new String[]{"CUSTBIRTH", "String"};
               columns[4] = new String[]{"PAPERTYPECODE", "String"};
               columns[5] = new String[]{"PAPERNO", "String"};
               columns[6] = new String[]{"CUSTADDR", "String"};
               columns[7] = new String[]{"CUSTPOST", "String"};
               columns[8] = new String[]{"CUSTPHONE", "String"};
               columns[9] = new String[]{"CUSTEMAIL", "String"};
               columns[10] = new String[]{"USETAG", "string"};
               columns[11] = new String[]{"UPDATESTAFFNO", "string"};
               columns[12] = new String[]{"UPDATETIME", "DateTime"};
               columns[13] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[14];
               hash.Add("CARDNO", 0);
               hash.Add("CUSTNAME", 1);
               hash.Add("CUSTSEX", 2);
               hash.Add("CUSTBIRTH", 3);
               hash.Add("PAPERTYPECODE", 4);
               hash.Add("PAPERNO", 5);
               hash.Add("CUSTADDR", 6);
               hash.Add("CUSTPOST", 7);
               hash.Add("CUSTPHONE", 8);
               hash.Add("CUSTEMAIL", 9);
               hash.Add("USETAG", 10);
               hash.Add("UPDATESTAFFNO", 11);
               hash.Add("UPDATETIME", 12);
               hash.Add("REMARK", 13);
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


