using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC�����ϱ��ݱ�
     public class TB_F_CARDRECTDO : DDOBase
     {
          public TB_F_CARDRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TB_F_CARDREC";

               columns = new String[28][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REUSEDATE", "DateTime"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"CARDTYPECODE", "string"};
               columns[4] = new String[]{"CARDSURFACECODE", "string"};
               columns[5] = new String[]{"CARDMANUCODE", "string"};
               columns[6] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[7] = new String[]{"APPTYPECODE", "string"};
               columns[8] = new String[]{"APPVERNO", "string"};
               columns[9] = new String[]{"DEPOSIT", "Int32"};
               columns[10] = new String[]{"CARDCOST", "Int32"};
               columns[11] = new String[]{"PRESUPPLYMONEY", "Int32"};
               columns[12] = new String[]{"CUSTRECTYPECODE", "string"};
               columns[13] = new String[]{"SELLTIME", "DateTime"};
               columns[14] = new String[]{"SELLCHANNELCODE", "string"};
               columns[15] = new String[]{"DEPARTNO", "string"};
               columns[16] = new String[]{"STAFFNO", "string"};
               columns[17] = new String[]{"CARDSTATE", "string"};
               columns[18] = new String[]{"USETAG", "string"};
               columns[19] = new String[]{"SERSTARTTIME", "DateTime"};
               columns[20] = new String[]{"SERTAKETAG", "string"};
               columns[21] = new String[]{"SERVICEMONEY", "Int32"};
               columns[22] = new String[]{"UPDATESTAFFNO", "string"};
               columns[23] = new String[]{"UPDATETIME", "DateTime"};
               columns[24] = new String[]{"RSRV1", "String"};
               columns[25] = new String[]{"RSRV2", "String"};
               columns[26] = new String[]{"RSRV3", "DateTime"};
               columns[27] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "REUSEDATE",
               };


               array = new String[28];
               hash.Add("CARDNO", 0);
               hash.Add("REUSEDATE", 1);
               hash.Add("ASN", 2);
               hash.Add("CARDTYPECODE", 3);
               hash.Add("CARDSURFACECODE", 4);
               hash.Add("CARDMANUCODE", 5);
               hash.Add("CARDCHIPTYPECODE", 6);
               hash.Add("APPTYPECODE", 7);
               hash.Add("APPVERNO", 8);
               hash.Add("DEPOSIT", 9);
               hash.Add("CARDCOST", 10);
               hash.Add("PRESUPPLYMONEY", 11);
               hash.Add("CUSTRECTYPECODE", 12);
               hash.Add("SELLTIME", 13);
               hash.Add("SELLCHANNELCODE", 14);
               hash.Add("DEPARTNO", 15);
               hash.Add("STAFFNO", 16);
               hash.Add("CARDSTATE", 17);
               hash.Add("USETAG", 18);
               hash.Add("SERSTARTTIME", 19);
               hash.Add("SERTAKETAG", 20);
               hash.Add("SERVICEMONEY", 21);
               hash.Add("UPDATESTAFFNO", 22);
               hash.Add("UPDATETIME", 23);
               hash.Add("RSRV1", 24);
               hash.Add("RSRV2", 25);
               hash.Add("RSRV3", 26);
               hash.Add("REMARK", 27);
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

          // �����к�
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

          // �������
          public string CARDSURFACECODE
          {
              get { return  Getstring("CARDSURFACECODE"); }
              set { Setstring("CARDSURFACECODE",value); }
          }

          // �����̱���
          public string CARDMANUCODE
          {
              get { return  Getstring("CARDMANUCODE"); }
              set { Setstring("CARDMANUCODE",value); }
          }

          // ��оƬ���ͱ���
          public string CARDCHIPTYPECODE
          {
              get { return  Getstring("CARDCHIPTYPECODE"); }
              set { Setstring("CARDCHIPTYPECODE",value); }
          }

          // Ӧ������
          public string APPTYPECODE
          {
              get { return  Getstring("APPTYPECODE"); }
              set { Setstring("APPTYPECODE",value); }
          }

          // Ӧ�ð汾
          public string APPVERNO
          {
              get { return  Getstring("APPVERNO"); }
              set { Setstring("APPVERNO",value); }
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

          // Ԥ����
          public Int32 PRESUPPLYMONEY
          {
              get { return  GetInt32("PRESUPPLYMONEY"); }
              set { SetInt32("PRESUPPLYMONEY",value); }
          }

          // �ֿ�����������
          public string CUSTRECTYPECODE
          {
              get { return  Getstring("CUSTRECTYPECODE"); }
              set { Setstring("CUSTRECTYPECODE",value); }
          }

          // �ۿ�ʱ��
          public DateTime SELLTIME
          {
              get { return  GetDateTime("SELLTIME"); }
              set { SetDateTime("SELLTIME",value); }
          }

          // �ۿ���������
          public string SELLCHANNELCODE
          {
              get { return  Getstring("SELLCHANNELCODE"); }
              set { Setstring("SELLCHANNELCODE",value); }
          }

          // �ۿ�����
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // �ۿ�����Ա���
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ��״̬
          public string CARDSTATE
          {
              get { return  Getstring("CARDSTATE"); }
              set { Setstring("CARDSTATE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ����ʼʱ��
          public DateTime SERSTARTTIME
          {
              get { return  GetDateTime("SERSTARTTIME"); }
              set { SetDateTime("SERSTARTTIME",value); }
          }

          // �������ȡ��־
          public string SERTAKETAG
          {
              get { return  Getstring("SERTAKETAG"); }
              set { Setstring("SERTAKETAG",value); }
          }

          // ʵ�տ������
          public Int32 SERVICEMONEY
          {
              get { return  GetInt32("SERVICEMONEY"); }
              set { SetInt32("SERVICEMONEY",value); }
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


