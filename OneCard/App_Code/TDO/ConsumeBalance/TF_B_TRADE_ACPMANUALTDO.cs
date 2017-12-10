using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // �̻������쳣�˹�����̨�ʱ� 
     public class TF_B_TRADE_ACPMANUALTDO : DDOBase
     {
          public TF_B_TRADE_ACPMANUALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADE_ACPMANUAL";

               columns = new String[31][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"RECTYPE", "string"};
               columns[4] = new String[]{"ICTRADETYPECODE", "string"};
               columns[5] = new String[]{"ASN", "string"};
               columns[6] = new String[]{"CARDTRADENO", "string"};
               columns[7] = new String[]{"SAMNO", "string"};
               columns[8] = new String[]{"POSNO", "string"};
               columns[9] = new String[]{"POSTRADENO", "string"};
               columns[10] = new String[]{"TRADEDATE", "string"};
               columns[11] = new String[]{"TRADETIME", "string"};
               columns[12] = new String[]{"PREMONEY", "Int32"};
               columns[13] = new String[]{"TRADEMONEY", "Int32"};
               columns[14] = new String[]{"SMONEY", "Int32"};
               columns[15] = new String[]{"BALUNITNO", "string"};
               columns[16] = new String[]{"CALLINGNO", "string"};
               columns[17] = new String[]{"CORPNO", "string"};
               columns[18] = new String[]{"DEPARTNO", "string"};
               columns[19] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[20] = new String[]{"CITYNO", "string"};
               columns[21] = new String[]{"TAC", "string"};
               columns[22] = new String[]{"SOURCEID", "String"};
               columns[23] = new String[]{"DEALTIME", "DateTime"};
               columns[24] = new String[]{"ERRORREASONCODE", "string"};
               columns[25] = new String[]{"RENEWTYPECODE", "string"};
               columns[26] = new String[]{"DEALSTATECODE", "string"};
               columns[27] = new String[]{"RENEWSTATECODE", "string"};
               columns[28] = new String[]{"STAFFNO", "string"};
               columns[29] = new String[]{"OPERATETIME", "DateTime"};
               columns[30] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[31];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("RECTYPE", 3);
               hash.Add("ICTRADETYPECODE", 4);
               hash.Add("ASN", 5);
               hash.Add("CARDTRADENO", 6);
               hash.Add("SAMNO", 7);
               hash.Add("POSNO", 8);
               hash.Add("POSTRADENO", 9);
               hash.Add("TRADEDATE", 10);
               hash.Add("TRADETIME", 11);
               hash.Add("PREMONEY", 12);
               hash.Add("TRADEMONEY", 13);
               hash.Add("SMONEY", 14);
               hash.Add("BALUNITNO", 15);
               hash.Add("CALLINGNO", 16);
               hash.Add("CORPNO", 17);
               hash.Add("DEPARTNO", 18);
               hash.Add("CALLINGSTAFFNO", 19);
               hash.Add("CITYNO", 20);
               hash.Add("TAC", 21);
               hash.Add("SOURCEID", 22);
               hash.Add("DEALTIME", 23);
               hash.Add("ERRORREASONCODE", 24);
               hash.Add("RENEWTYPECODE", 25);
               hash.Add("DEALSTATECODE", 26);
               hash.Add("RENEWSTATECODE", 27);
               hash.Add("STAFFNO", 28);
               hash.Add("OPERATETIME", 29);
               hash.Add("RSRVCHAR", 30);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��¼����
          public string RECTYPE
          {
              get { return  Getstring("RECTYPE"); }
              set { Setstring("RECTYPE",value); }
          }

          // IC�������ͱ���
          public string ICTRADETYPECODE
          {
              get { return  Getstring("ICTRADETYPECODE"); }
              set { Setstring("ICTRADETYPECODE",value); }
          }

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // ���������к�
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // PSAM���
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // POS���
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // POS�������к�
          public string POSTRADENO
          {
              get { return  Getstring("POSTRADENO"); }
              set { Setstring("POSTRADENO",value); }
          }

          // ��������
          public string TRADEDATE
          {
              get { return  Getstring("TRADEDATE"); }
              set { Setstring("TRADEDATE",value); }
          }

          // ����ʱ��
          public string TRADETIME
          {
              get { return  Getstring("TRADETIME"); }
              set { Setstring("TRADETIME",value); }
          }

          // ����ǰ�������
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // Ӧ�ս��
          public Int32 SMONEY
          {
              get { return  GetInt32("SMONEY"); }
              set { SetInt32("SMONEY",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ��ҵԱ������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // ���д���
          public string CITYNO
          {
              get { return  Getstring("CITYNO"); }
              set { Setstring("CITYNO",value); }
          }

          // TAC��
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // ��Դʶ���
          public String SOURCEID
          {
              get { return  GetString("SOURCEID"); }
              set { SetString("SOURCEID",value); }
          }

          // ����ʱ��
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // ����ԭ�����
          public string ERRORREASONCODE
          {
              get { return  Getstring("ERRORREASONCODE"); }
              set { Setstring("ERRORREASONCODE",value); }
          }

          // �˹����շ�ʽ����
          public string RENEWTYPECODE
          {
              get { return  Getstring("RENEWTYPECODE"); }
              set { Setstring("RENEWTYPECODE",value); }
          }

          // ���㴦��״̬����
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // �˹�����ȷ��״̬
          public string RENEWSTATECODE
          {
              get { return  Getstring("RENEWSTATECODE"); }
              set { Setstring("RENEWSTATECODE",value); }
          }

          // ����Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


