using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // �ۿ�COMMIT
     public class SP_PB_SaleCard_COMMITPDO : PDOBase
     {
          public SP_PB_SaleCard_COMMITPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_SaleCard_COMMIT",31);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@DEPOSIT", "Int32", "", "input");
               AddField("@CARDCOST", "Int32", "", "input");
               AddField("@OTHERFEE", "Int32", "", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@SELLCHANNELCODE", "string", "2", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CUSTSEX", "String", "2", "input");
               AddField("@CUSTBIRTH", "String", "8", "input");
               AddField("@PAPERTYPECODE", "String", "2", "input");
               AddField("@PAPERNO", "String", "250", "input");
               AddField("@CUSTPOST", "String", "6", "input");
               AddField("@CUSTEMAIL", "String", "30", "input");
               AddField("@REMARK", "String", "100", "input");
               AddField("@CUSTRECTYPECODE", "string", "1", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@CURRENTTIME", "DateTime", "", "output");
               AddField("@TRADEID", "string", "16", "output");

               //UPDATE BY JINAGBB 2012-04-19 �ֶμ��ܳ����޸�
               AddField("@CUSTNAME", "String", "250", "input");
               AddField("@CUSTADDR", "String", "600", "input");
               AddField("@CUSTPHONE", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��Ѻ��
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // ����
          public Int32 CARDCOST
          {
              get { return  GetInt32("CARDCOST"); }
              set { SetInt32("CARDCOST",value); }
          }

          // ��������
          public Int32 OTHERFEE
          {
              get { return  GetInt32("OTHERFEE"); }
              set { SetInt32("OTHERFEE",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ������
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

          // �ۿ���������
          public string SELLCHANNELCODE
          {
              get { return  Getstring("SELLCHANNELCODE"); }
              set { Setstring("SELLCHANNELCODE",value); }
          }

          // �������ȡ��־
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
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

          // �ֿ�����������
          public string CUSTRECTYPECODE
          {
              get { return  Getstring("CUSTRECTYPECODE"); }
              set { Setstring("CUSTRECTYPECODE",value); }
          }

          // �ն˺�
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ����Ա����
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // ����ϵͳʱ��
          public DateTime CURRENTTIME
          {
              get { return  GetDateTime("CURRENTTIME"); }
              set { SetDateTime("CURRENTTIME",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


