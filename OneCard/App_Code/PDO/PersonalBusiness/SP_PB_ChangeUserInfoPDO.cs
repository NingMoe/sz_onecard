using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // �޸Ŀͻ�����
     public class SP_PB_ChangeUserInfoPDO : PDOBase
     {
          public SP_PB_ChangeUserInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ChangeUserInfo",20);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CUSTSEX", "String", "2", "input");
               AddField("@CUSTBIRTH", "String", "8", "input");
               AddField("@PAPERTYPECODE", "String", "2", "input");
               AddField("@PAPERNO", "String", "20", "input");
               AddField("@CUSTPOST", "String", "6", "input");
               AddField("@CUSTEMAIL", "String", "30", "input");
               AddField("@REMARK", "String", "100", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@TRADEID", "string", "16", "output");

              //UPDATE BY JINAGBB 2012-04-19 �ֶμ��ܳ����޸�
               AddField("@CUSTNAME", "String", "200", "input");
               AddField("@CUSTADDR", "String", "600", "input");
               AddField("@CUSTPHONE", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");
               InitEnd();
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // �����ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


