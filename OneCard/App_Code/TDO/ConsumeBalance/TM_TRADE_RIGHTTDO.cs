using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // ���������嵥��ʱ��
     public class TM_TRADE_RIGHTTDO : DDOBase
     {
          public TM_TRADE_RIGHTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_TRADE_RIGHT";

               columns = new String[32][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"RECTYPE", "string"};
               columns[3] = new String[]{"ICTRADETYPECODE", "string"};
               columns[4] = new String[]{"ASN", "string"};
               columns[5] = new String[]{"CARDTRADENO", "string"};
               columns[6] = new String[]{"SAMNO", "string"};
               columns[7] = new String[]{"PSAMVERNO", "string"};
               columns[8] = new String[]{"POSNO", "string"};
               columns[9] = new String[]{"POSTRADENO", "string"};
               columns[10] = new String[]{"TRADEDATE", "string"};
               columns[11] = new String[]{"TRADETIME", "string"};
               columns[12] = new String[]{"PREMONEY", "Int32"};
               columns[13] = new String[]{"TRADEMONEY", "Int32"};
               columns[14] = new String[]{"SMONEY", "Int32"};
               columns[15] = new String[]{"TRADECOMFEE", "Int32"};
               columns[16] = new String[]{"BALUNITNO", "string"};
               columns[17] = new String[]{"CALLINGNO", "string"};
               columns[18] = new String[]{"CORPNO", "string"};
               columns[19] = new String[]{"DEPARTNO", "string"};
               columns[20] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[21] = new String[]{"CITYNO", "string"};
               columns[22] = new String[]{"TAC", "string"};
               columns[23] = new String[]{"TACSTATE", "string"};
               columns[24] = new String[]{"MAC", "string"};
               columns[25] = new String[]{"SOURCEID", "String"};
               columns[26] = new String[]{"BATCHNO", "string"};
               columns[27] = new String[]{"DEALTIME", "DateTime"};
               columns[28] = new String[]{"INLISTTIME", "DateTime"};
               columns[29] = new String[]{"MOVESTATE", "string"};
               columns[30] = new String[]{"CHNLTYPE", "string"};
               columns[31] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[32];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("RECTYPE", 2);
               hash.Add("ICTRADETYPECODE", 3);
               hash.Add("ASN", 4);
               hash.Add("CARDTRADENO", 5);
               hash.Add("SAMNO", 6);
               hash.Add("PSAMVERNO", 7);
               hash.Add("POSNO", 8);
               hash.Add("POSTRADENO", 9);
               hash.Add("TRADEDATE", 10);
               hash.Add("TRADETIME", 11);
               hash.Add("PREMONEY", 12);
               hash.Add("TRADEMONEY", 13);
               hash.Add("SMONEY", 14);
               hash.Add("TRADECOMFEE", 15);
               hash.Add("BALUNITNO", 16);
               hash.Add("CALLINGNO", 17);
               hash.Add("CORPNO", 18);
               hash.Add("DEPARTNO", 19);
               hash.Add("CALLINGSTAFFNO", 20);
               hash.Add("CITYNO", 21);
               hash.Add("TAC", 22);
               hash.Add("TACSTATE", 23);
               hash.Add("MAC", 24);
               hash.Add("SOURCEID", 25);
               hash.Add("BATCHNO", 26);
               hash.Add("DEALTIME", 27);
               hash.Add("INLISTTIME", 28);
               hash.Add("MOVESTATE", 29);
               hash.Add("CHNLTYPE", 30);
               hash.Add("RSRVCHAR", 31);
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

          // ���嵥ʱ��
          public DateTime INLISTTIME
          {
              get { return  GetDateTime("INLISTTIME"); }
              set { SetDateTime("INLISTTIME",value); }
          }

          // ��Ǩ״̬
          public string MOVESTATE
          {
              get { return  Getstring("MOVESTATE"); }
              set { Setstring("MOVESTATE",value); }
          }

          // ͨ������
          public string CHNLTYPE
          {
              get { return  Getstring("CHNLTYPE"); }
              set { Setstring("CHNLTYPE",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}

