using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ�ظ�������ʱ��
     public class TM_SUPPLY_REPEAT_C1TDO : DDOBase
     {
          public TM_SUPPLY_REPEAT_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_SUPPLY_REPEAT_C1";

               columns = new String[20][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"ASN", "string"};
               columns[2] = new String[]{"CARDTRADENO", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"TRADEDATE", "string"};
               columns[6] = new String[]{"TRADETIME", "string"};
               columns[7] = new String[]{"TRADEMONEY", "Int32"};
               columns[8] = new String[]{"PREMONEY", "Int32"};
               columns[9] = new String[]{"SUPPLYLOCNO", "string"};
               columns[10] = new String[]{"SAMNO", "string"};
               columns[11] = new String[]{"POSNO", "string"};
               columns[12] = new String[]{"STAFFNO", "string"};
               columns[13] = new String[]{"TAC", "string"};
               columns[14] = new String[]{"TRADEID", "string"};
               columns[15] = new String[]{"TACSTATE", "string"};
               columns[16] = new String[]{"BATCHNO", "string"};
               columns[17] = new String[]{"DEALTIME", "DateTime"};
               columns[18] = new String[]{"REPEATTYPECODE", "string"};
               columns[19] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[20];
               hash.Add("ID", 0);
               hash.Add("ASN", 1);
               hash.Add("CARDTRADENO", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("TRADEDATE", 5);
               hash.Add("TRADETIME", 6);
               hash.Add("TRADEMONEY", 7);
               hash.Add("PREMONEY", 8);
               hash.Add("SUPPLYLOCNO", 9);
               hash.Add("SAMNO", 10);
               hash.Add("POSNO", 11);
               hash.Add("STAFFNO", 12);
               hash.Add("TAC", 13);
               hash.Add("TRADEID", 14);
               hash.Add("TACSTATE", 15);
               hash.Add("BATCHNO", 16);
               hash.Add("DEALTIME", 17);
               hash.Add("REPEATTYPECODE", 18);
               hash.Add("RSRVCHAR", 19);
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
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


