using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ�����ļ������ʱ��
     public class TI_SUPPLY_OLLOAD_C1TDO : DDOBase
     {
          public TI_SUPPLY_OLLOAD_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TI_SUPPLY_OLLOAD_C1";

               columns = new String[15][];
               columns[0] = new String[]{"ASN", "string"};
               columns[1] = new String[]{"CARDTRADENO", "string"};
               columns[2] = new String[]{"TRADETYPECODE", "string"};
               columns[3] = new String[]{"SUPPLYLOCNO", "string"};
               columns[4] = new String[]{"SAMNO", "string"};
               columns[5] = new String[]{"STAFFNO", "string"};
               columns[6] = new String[]{"PREMONEY", "Int32"};
               columns[7] = new String[]{"TRADEMONEY", "Int32"};
               columns[8] = new String[]{"TRADEDATE", "string"};
               columns[9] = new String[]{"TRADETIME", "string"};
               columns[10] = new String[]{"RESULT", "string"};
               columns[11] = new String[]{"POSNO", "string"};
               columns[12] = new String[]{"TAC", "string"};
               columns[13] = new String[]{"FILENAME", "string"};
               columns[14] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
               };


               array = new String[15];
               hash.Add("ASN", 0);
               hash.Add("CARDTRADENO", 1);
               hash.Add("TRADETYPECODE", 2);
               hash.Add("SUPPLYLOCNO", 3);
               hash.Add("SAMNO", 4);
               hash.Add("STAFFNO", 5);
               hash.Add("PREMONEY", 6);
               hash.Add("TRADEMONEY", 7);
               hash.Add("TRADEDATE", 8);
               hash.Add("TRADETIME", 9);
               hash.Add("RESULT", 10);
               hash.Add("POSNO", 11);
               hash.Add("TAC", 12);
               hash.Add("FILENAME", 13);
               hash.Add("RSRVCHAR", 14);
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

          // ����Ա��
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ����ǰ���
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

          // �������
          public string RESULT
          {
              get { return  Getstring("RESULT"); }
              set { Setstring("RESULT",value); }
          }

          // POS���
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // TAC��֤��
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // �����ļ���
          public string FILENAME
          {
              get { return  Getstring("FILENAME"); }
              set { Setstring("FILENAME",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


