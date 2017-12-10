using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ����Ǯ����ֵ��ˮ��
     public class TF_SUPPLY_REALTIMETDO : DDOBase
     {
          public TF_SUPPLY_REALTIMETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_REALTIME";

               columns = new String[18][];
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
               columns[13] = new String[]{"TAC", "string"};
               columns[14] = new String[]{"OPERATESTAFFNO", "string"};
               columns[15] = new String[]{"OPERATETIME", "DateTime"};
               columns[16] = new String[]{"MOVESTATE", "string"};
               columns[17] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[18];
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
               hash.Add("TAC", 13);
               hash.Add("OPERATESTAFFNO", 14);
               hash.Add("OPERATETIME", 15);
               hash.Add("MOVESTATE", 16);
               hash.Add("RSRVCHAR", 17);
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

          // ҵ�����ͱ���
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

          // ��ֵǰ�������
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

          // TAC��֤��
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ��Ǩ״̬
          public string MOVESTATE
          {
              get { return  Getstring("MOVESTATE"); }
              set { Setstring("MOVESTATE",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


