using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // �����ظ�������ʱ��
     public class TM_TRADE_REPEAT_C1TDO : DDOBase
     {
          public TM_TRADE_REPEAT_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_TRADE_REPEAT_C1";

               columns = new String[23][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"RECTYPE", "string"};
               columns[2] = new String[]{"ICTRADETYPECODE", "string"};
               columns[3] = new String[]{"ASN", "string"};
               columns[4] = new String[]{"CARDTRADENO", "string"};
               columns[5] = new String[]{"SAMNO", "string"};
               columns[6] = new String[]{"PSAMVERNO", "string"};
               columns[7] = new String[]{"POSNO", "string"};
               columns[8] = new String[]{"POSTRADENO", "string"};
               columns[9] = new String[]{"TRADEDATE", "string"};
               columns[10] = new String[]{"TRADETIME", "string"};
               columns[11] = new String[]{"PREMONEY", "Int32"};
               columns[12] = new String[]{"TRADEMONEY", "Int32"};
               columns[13] = new String[]{"SMONEY", "Int32"};
               columns[14] = new String[]{"CITYNO", "string"};
               columns[15] = new String[]{"TAC", "string"};
               columns[16] = new String[]{"TACSTATE", "string"};
               columns[17] = new String[]{"MAC", "string"};
               columns[18] = new String[]{"SOURCEID", "String"};
               columns[19] = new String[]{"BATCHNO", "string"};
               columns[20] = new String[]{"DEALTIME", "DateTime"};
               columns[21] = new String[]{"REPEATTYPECODE", "string"};
               columns[22] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[23];
               hash.Add("ID", 0);
               hash.Add("RECTYPE", 1);
               hash.Add("ICTRADETYPECODE", 2);
               hash.Add("ASN", 3);
               hash.Add("CARDTRADENO", 4);
               hash.Add("SAMNO", 5);
               hash.Add("PSAMVERNO", 6);
               hash.Add("POSNO", 7);
               hash.Add("POSTRADENO", 8);
               hash.Add("TRADEDATE", 9);
               hash.Add("TRADETIME", 10);
               hash.Add("PREMONEY", 11);
               hash.Add("TRADEMONEY", 12);
               hash.Add("SMONEY", 13);
               hash.Add("CITYNO", 14);
               hash.Add("TAC", 15);
               hash.Add("TACSTATE", 16);
               hash.Add("MAC", 17);
               hash.Add("SOURCEID", 18);
               hash.Add("BATCHNO", 19);
               hash.Add("DEALTIME", 20);
               hash.Add("REPEATTYPECODE", 21);
               hash.Add("RSRVCHAR", 22);
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
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

          // �ظ����ͱ���
          public string REPEATTYPECODE
          {
              get { return  Getstring("REPEATTYPECODE"); }
              set { Setstring("REPEATTYPECODE",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}

