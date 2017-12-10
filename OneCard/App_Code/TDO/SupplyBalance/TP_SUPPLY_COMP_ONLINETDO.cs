using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ʵʱ��ֵ�ȶԱ�
     public class TP_SUPPLY_COMP_ONLINETDO : DDOBase
     {
          public TP_SUPPLY_COMP_ONLINETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_SUPPLY_COMP_ONLINE";

               columns = new String[20][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"ASN", "string"};
               columns[2] = new String[]{"CARDTRADENO", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"TRADEID", "string"};
               columns[6] = new String[]{"BANKCARDNO", "string"};
               columns[7] = new String[]{"TRADEDATE", "string"};
               columns[8] = new String[]{"TRADETIME", "string"};
               columns[9] = new String[]{"TRADEMONEY", "Int32"};
               columns[10] = new String[]{"PREMONEY", "Int32"};
               columns[11] = new String[]{"SUPPLYLOCNO", "string"};
               columns[12] = new String[]{"SAMNO", "string"};
               columns[13] = new String[]{"STAFFNO", "string"};
               columns[14] = new String[]{"STATECODE", "string"};
               columns[15] = new String[]{"OPERATETIME", "DateTime"};
               columns[16] = new String[]{"DEALSTATECODE", "string"};
               columns[17] = new String[]{"COMPMONEY", "Int32"};
               columns[18] = new String[]{"BALUNITNO", "string"};
               columns[19] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[20];
               hash.Add("ID", 0);
               hash.Add("ASN", 1);
               hash.Add("CARDTRADENO", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("TRADEID", 5);
               hash.Add("BANKCARDNO", 6);
               hash.Add("TRADEDATE", 7);
               hash.Add("TRADETIME", 8);
               hash.Add("TRADEMONEY", 9);
               hash.Add("PREMONEY", 10);
               hash.Add("SUPPLYLOCNO", 11);
               hash.Add("SAMNO", 12);
               hash.Add("STAFFNO", 13);
               hash.Add("STATECODE", 14);
               hash.Add("OPERATETIME", 15);
               hash.Add("DEALSTATECODE", 16);
               hash.Add("COMPMONEY", 17);
               hash.Add("BALUNITNO", 18);
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

          // ������ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ���п���
          public string BANKCARDNO
          {
              get { return  Getstring("BANKCARDNO"); }
              set { Setstring("BANKCARDNO",value); }
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

          // ����Ա���
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ״̬����
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ����״̬��
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // �ȶԽ��׽��
          public Int32 COMPMONEY
          {
              get { return  GetInt32("COMPMONEY"); }
              set { SetInt32("COMPMONEY",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


