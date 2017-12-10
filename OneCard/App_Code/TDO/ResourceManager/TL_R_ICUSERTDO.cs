using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // �û�������
     public class TL_R_ICUSERTDO : DDOBase
     {
          public TL_R_ICUSERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_R_ICUSER";

               columns = new String[29][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"RESSTATECODE", "string"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"COSTYPECODE", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"CARDPRICE", "Int32"};
               columns[6] = new String[]{"MANUTYPECODE", "string"};
               columns[7] = new String[]{"CARDSURFACECODE", "string"};
               columns[8] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[9] = new String[]{"VALIDBEGINDATE", "string"};
               columns[10] = new String[]{"VALIDENDDATE", "string"};
               columns[11] = new String[]{"APPTYPECODE", "string"};
               columns[12] = new String[]{"APPVERNO", "string"};
               columns[13] = new String[]{"PRESUPPLYMONEY", "Int32"};
               columns[14] = new String[]{"SERVICECYCLE", "string"};
               columns[15] = new String[]{"EVESERVICEPRICE", "Int32"};
               columns[16] = new String[]{"INSTIME", "DateTime"};
               columns[17] = new String[]{"OUTTIME", "DateTime"};
               columns[18] = new String[]{"ALLOCTIME", "DateTime"};
               columns[19] = new String[]{"SELLTIME", "DateTime"};
               columns[20] = new String[]{"DESTROYTIME", "DateTime"};
               columns[21] = new String[]{"RECLAIMTIME", "DateTime"};
               columns[22] = new String[]{"FREEZEDATE", "DateTime"};
               columns[23] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[24] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[25] = new String[]{"UPDATESTAFFNO", "string"};
               columns[26] = new String[]{"UPDATETIME", "DateTime"};
               columns[27] = new String[]{"RSRV1", "String"};
               columns[28] = new String[] { "SALETYPE", "String" };

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[29];
               hash.Add("CARDNO", 0);
               hash.Add("RESSTATECODE", 1);
               hash.Add("ASN", 2);
               hash.Add("COSTYPECODE", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("CARDPRICE", 5);
               hash.Add("MANUTYPECODE", 6);
               hash.Add("CARDSURFACECODE", 7);
               hash.Add("CARDCHIPTYPECODE", 8);
               hash.Add("VALIDBEGINDATE", 9);
               hash.Add("VALIDENDDATE", 10);
               hash.Add("APPTYPECODE", 11);
               hash.Add("APPVERNO", 12);
               hash.Add("PRESUPPLYMONEY", 13);
               hash.Add("SERVICECYCLE", 14);
               hash.Add("EVESERVICEPRICE", 15);
               hash.Add("INSTIME", 16);
               hash.Add("OUTTIME", 17);
               hash.Add("ALLOCTIME", 18);
               hash.Add("SELLTIME", 19);
               hash.Add("DESTROYTIME", 20);
               hash.Add("RECLAIMTIME", 21);
               hash.Add("FREEZEDATE", 22);
               hash.Add("ASSIGNEDSTAFFNO", 23);
               hash.Add("ASSIGNEDDEPARTID", 24);
               hash.Add("UPDATESTAFFNO", 25);
               hash.Add("UPDATETIME", 26);
               hash.Add("RSRV1", 27);
               hash.Add("SALETYPE", 28);
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��Ƭ���״̬
          public string RESSTATECODE
          {
              get { return  Getstring("RESSTATECODE"); }
              set { Setstring("RESSTATECODE",value); }
          }

          // �����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // COS����
          public string COSTYPECODE
          {
              get { return  Getstring("COSTYPECODE"); }
              set { Setstring("COSTYPECODE",value); }
          }

          // ��Ƭ����
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // ��Ƭ����
          public Int32 CARDPRICE
          {
              get { return  GetInt32("CARDPRICE"); }
              set { SetInt32("CARDPRICE",value); }
          }

          // ��Ƭ����
          public string MANUTYPECODE
          {
              get { return  Getstring("MANUTYPECODE"); }
              set { Setstring("MANUTYPECODE",value); }
          }

          // �������
          public string CARDSURFACECODE
          {
              get { return  Getstring("CARDSURFACECODE"); }
              set { Setstring("CARDSURFACECODE",value); }
          }

          // ��оƬ����
          public string CARDCHIPTYPECODE
          {
              get { return  Getstring("CARDCHIPTYPECODE"); }
              set { Setstring("CARDCHIPTYPECODE",value); }
          }

          // ��ʼ��Ч��
          public string VALIDBEGINDATE
          {
              get { return  Getstring("VALIDBEGINDATE"); }
              set { Setstring("VALIDBEGINDATE",value); }
          }

          // ��ֹ��Ч��
          public string VALIDENDDATE
          {
              get { return  Getstring("VALIDENDDATE"); }
              set { Setstring("VALIDENDDATE",value); }
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

          // Ԥ����
          public Int32 PRESUPPLYMONEY
          {
              get { return  GetInt32("PRESUPPLYMONEY"); }
              set { SetInt32("PRESUPPLYMONEY",value); }
          }

          // ��������
          public string SERVICECYCLE
          {
              get { return  Getstring("SERVICECYCLE"); }
              set { Setstring("SERVICECYCLE",value); }
          }

          // ÿ�ڷ������
          public Int32 EVESERVICEPRICE
          {
              get { return  GetInt32("EVESERVICEPRICE"); }
              set { SetInt32("EVESERVICEPRICE",value); }
          }

          // ���ʱ��
          public DateTime INSTIME
          {
              get { return  GetDateTime("INSTIME"); }
              set { SetDateTime("INSTIME",value); }
          }

          // ����ʱ��
          public DateTime OUTTIME
          {
              get { return  GetDateTime("OUTTIME"); }
              set { SetDateTime("OUTTIME",value); }
          }

          // ����ʱ��
          public DateTime ALLOCTIME
          {
              get { return  GetDateTime("ALLOCTIME"); }
              set { SetDateTime("ALLOCTIME",value); }
          }

          // ����ʱ��
          public DateTime SELLTIME
          {
              get { return  GetDateTime("SELLTIME"); }
              set { SetDateTime("SELLTIME",value); }
          }

          // ����ʱ��
          public DateTime DESTROYTIME
          {
              get { return  GetDateTime("DESTROYTIME"); }
              set { SetDateTime("DESTROYTIME",value); }
          }

          // ����ʱ��
          public DateTime RECLAIMTIME
          {
              get { return  GetDateTime("RECLAIMTIME"); }
              set { SetDateTime("RECLAIMTIME",value); }
          }

          // �����������
          public DateTime FREEZEDATE
          {
              get { return  GetDateTime("FREEZEDATE"); }
              set { SetDateTime("FREEZEDATE",value); }
          }

          // ����Ա������
          public string ASSIGNEDSTAFFNO
          {
              get { return  Getstring("ASSIGNEDSTAFFNO"); }
              set { Setstring("ASSIGNEDSTAFFNO",value); }
          }

          // ����Ա�����ű���
          public string ASSIGNEDDEPARTID
          {
              get { return  Getstring("ASSIGNEDDEPARTID"); }
              set { Setstring("ASSIGNEDDEPARTID",value); }
          }

          // ����Ա������
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

          // �ۿ���ʽ1
          public String SALETYPE
          {
              get { return GetString("SALETYPE"); }
              set { SetString("SALETYPE", value); }
          }

     }
}


