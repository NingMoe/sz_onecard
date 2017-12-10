using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ�쳣�嵥��
     public class TF_SUPPLY_ERROR_01TDO : DDOBase
     {
          public TF_SUPPLY_ERROR_01TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_ERROR_01";

               columns = new String[27][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"CARDTRADENO", "string"};
               columns[4] = new String[]{"TRADETYPECODE", "string"};
               columns[5] = new String[]{"CARDTYPECODE", "string"};
               columns[6] = new String[]{"TRADEDATE", "string"};
               columns[7] = new String[]{"TRADETIME", "string"};
               columns[8] = new String[]{"TRADEMONEY", "Int32"};
               columns[9] = new String[]{"PREMONEY", "Int32"};
               columns[10] = new String[]{"SUPPLYLOCNO", "string"};
               columns[11] = new String[]{"SAMNO", "string"};
               columns[12] = new String[]{"POSNO", "string"};
               columns[13] = new String[]{"STAFFNO", "string"};
               columns[14] = new String[]{"TAC", "string"};
               columns[15] = new String[]{"TRADEID", "string"};
               columns[16] = new String[]{"TACSTATE", "string"};
               columns[17] = new String[]{"BATCHNO", "string"};
               columns[18] = new String[]{"BALUNITNO", "string"};
               columns[19] = new String[]{"CALLINGNO", "string"};
               columns[20] = new String[]{"CORPNO", "string"};
               columns[21] = new String[]{"DEPARTNO", "string"};
               columns[22] = new String[]{"DEALTIME", "DateTime"};
               columns[23] = new String[]{"ERRORREASONCODE", "string"};
               columns[24] = new String[]{"INLISTTIME", "DateTime"};
               columns[25] = new String[]{"DEALSTATECODE", "string"};
               columns[26] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[27];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("ASN", 2);
               hash.Add("CARDTRADENO", 3);
               hash.Add("TRADETYPECODE", 4);
               hash.Add("CARDTYPECODE", 5);
               hash.Add("TRADEDATE", 6);
               hash.Add("TRADETIME", 7);
               hash.Add("TRADEMONEY", 8);
               hash.Add("PREMONEY", 9);
               hash.Add("SUPPLYLOCNO", 10);
               hash.Add("SAMNO", 11);
               hash.Add("POSNO", 12);
               hash.Add("STAFFNO", 13);
               hash.Add("TAC", 14);
               hash.Add("TRADEID", 15);
               hash.Add("TACSTATE", 16);
               hash.Add("BATCHNO", 17);
               hash.Add("BALUNITNO", 18);
               hash.Add("CALLINGNO", 19);
               hash.Add("CORPNO", 20);
               hash.Add("DEPARTNO", 21);
               hash.Add("DEALTIME", 22);
               hash.Add("ERRORREASONCODE", 23);
               hash.Add("INLISTTIME", 24);
               hash.Add("DEALSTATECODE", 25);
               hash.Add("RSRVCHAR", 26);
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

          // ICӦ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // IC�������к� 
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ��Ƭ���ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
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

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // ����ǰ���
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // ��ֵ����
          public string SUPPLYLOCNO
          {
              get { return  Getstring("SUPPLYLOCNO"); }
              set { Setstring("SUPPLYLOCNO",value); }
          }

          // SAM���
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

          // ����Ա��
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // TAC��֤��
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // ���н�����ˮ
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // TAC����֤���
          public string TACSTATE
          {
              get { return  Getstring("TACSTATE"); }
              set { Setstring("TACSTATE",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
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

          // ���嵥ʱ��
          public DateTime INLISTTIME
          {
              get { return  GetDateTime("INLISTTIME"); }
              set { SetDateTime("INLISTTIME",value); }
          }

          // �˹�����״̬����
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


