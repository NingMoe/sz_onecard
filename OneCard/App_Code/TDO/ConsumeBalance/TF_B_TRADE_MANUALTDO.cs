using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // �����쳣�˹�����̨�ʱ�
     public class TF_B_TRADE_MANUALTDO : DDOBase
     {
          public TF_B_TRADE_MANUALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADE_MANUAL";

               columns = new String[39][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"RECTYPE", "string"};
               columns[4] = new String[]{"ICTRADETYPECODE", "string"};
               columns[5] = new String[]{"ASN", "string"};
               columns[6] = new String[]{"CARDTRADENO", "string"};
               columns[7] = new String[]{"SAMNO", "string"};
               columns[8] = new String[]{"PSAMVERNO", "string"};
               columns[9] = new String[]{"POSNO", "string"};
               columns[10] = new String[]{"POSTRADENO", "string"};
               columns[11] = new String[]{"TRADEDATE", "string"};
               columns[12] = new String[]{"TRADETIME", "string"};
               columns[13] = new String[]{"PREMONEY", "Int32"};
               columns[14] = new String[]{"TRADEMONEY", "Int32"};
               columns[15] = new String[]{"SMONEY", "Int32"};
               columns[16] = new String[]{"TRADECOMFEE", "Int32"};
               columns[17] = new String[]{"BALUNITNO", "string"};
               columns[18] = new String[]{"CALLINGNO", "string"};
               columns[19] = new String[]{"CORPNO", "string"};
               columns[20] = new String[]{"DEPARTNO", "string"};
               columns[21] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[22] = new String[]{"CITYNO", "string"};
               columns[23] = new String[]{"TAC", "string"};
               columns[24] = new String[]{"TACSTATE", "string"};
               columns[25] = new String[]{"MAC", "string"};
               columns[26] = new String[]{"SOURCEID", "String"};
               columns[27] = new String[]{"BATCHNO", "string"};
               columns[28] = new String[]{"DEALTIME", "DateTime"};
               columns[29] = new String[]{"ERRORREASONCODE", "string"};
               columns[30] = new String[]{"RENEWTIME", "DateTime"};
               columns[31] = new String[]{"RENEWSTAFFNO", "string"};
               columns[32] = new String[]{"RENEWTYPECODE", "string"};
               columns[33] = new String[]{"RENEWREMARK", "String"};
               columns[34] = new String[]{"DEALSTATECODE", "string"};
               columns[35] = new String[]{"RENEWSTATECODE", "string"};
               columns[36] = new String[]{"RECTRADEID", "string"};
               columns[37] = new String[]{"RECSTAFFNO", "string"};
               columns[38] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[39];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("RECTYPE", 3);
               hash.Add("ICTRADETYPECODE", 4);
               hash.Add("ASN", 5);
               hash.Add("CARDTRADENO", 6);
               hash.Add("SAMNO", 7);
               hash.Add("PSAMVERNO", 8);
               hash.Add("POSNO", 9);
               hash.Add("POSTRADENO", 10);
               hash.Add("TRADEDATE", 11);
               hash.Add("TRADETIME", 12);
               hash.Add("PREMONEY", 13);
               hash.Add("TRADEMONEY", 14);
               hash.Add("SMONEY", 15);
               hash.Add("TRADECOMFEE", 16);
               hash.Add("BALUNITNO", 17);
               hash.Add("CALLINGNO", 18);
               hash.Add("CORPNO", 19);
               hash.Add("DEPARTNO", 20);
               hash.Add("CALLINGSTAFFNO", 21);
               hash.Add("CITYNO", 22);
               hash.Add("TAC", 23);
               hash.Add("TACSTATE", 24);
               hash.Add("MAC", 25);
               hash.Add("SOURCEID", 26);
               hash.Add("BATCHNO", 27);
               hash.Add("DEALTIME", 28);
               hash.Add("ERRORREASONCODE", 29);
               hash.Add("RENEWTIME", 30);
               hash.Add("RENEWSTAFFNO", 31);
               hash.Add("RENEWTYPECODE", 32);
               hash.Add("RENEWREMARK", 33);
               hash.Add("DEALSTATECODE", 34);
               hash.Add("RENEWSTATECODE", 35);
               hash.Add("RECTRADEID", 36);
               hash.Add("RECSTAFFNO", 37);
               hash.Add("RSRVCHAR", 38);
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

          // PSAM���汾��
          public string PSAMVERNO
          {
              get { return  Getstring("PSAMVERNO"); }
              set { Setstring("PSAMVERNO",value); }
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

          // ����Ӷ��
          public Int32 TRADECOMFEE
          {
              get { return  GetInt32("TRADECOMFEE"); }
              set { SetInt32("TRADECOMFEE",value); }
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

          // TAC��֤���
          public string TACSTATE
          {
              get { return  Getstring("TACSTATE"); }
              set { Setstring("TACSTATE",value); }
          }

          // MAC��
          public string MAC
          {
              get { return  Getstring("MAC"); }
              set { Setstring("MAC",value); }
          }

          // ��Դʶ���
          public String SOURCEID
          {
              get { return  GetString("SOURCEID"); }
              set { SetString("SOURCEID",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
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

          // �˹�����ʱ��
          public DateTime RENEWTIME
          {
              get { return  GetDateTime("RENEWTIME"); }
              set { SetDateTime("RENEWTIME",value); }
          }

          // �˹�����Ա�����
          public string RENEWSTAFFNO
          {
              get { return  Getstring("RENEWSTAFFNO"); }
              set { Setstring("RENEWSTAFFNO",value); }
          }

          // �˹����շ�ʽ����
          public string RENEWTYPECODE
          {
              get { return  Getstring("RENEWTYPECODE"); }
              set { Setstring("RENEWTYPECODE",value); }
          }

          // �˹�����˵��
          public String RENEWREMARK
          {
              get { return  GetString("RENEWREMARK"); }
              set { SetString("RENEWREMARK",value); }
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

          // ����ҵ����ˮ��
          public string RECTRADEID
          {
              get { return  Getstring("RECTRADEID"); }
              set { Setstring("RECTRADEID",value); }
          }

          // ����Ա������
          public string RECSTAFFNO
          {
              get { return  Getstring("RECSTAFFNO"); }
              set { Setstring("RECSTAFFNO",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


