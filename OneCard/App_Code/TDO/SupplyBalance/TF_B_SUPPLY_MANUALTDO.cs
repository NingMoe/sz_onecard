using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ�˹�����̨�ʱ�
     public class TF_B_SUPPLY_MANUALTDO : DDOBase
     {
          public TF_B_SUPPLY_MANUALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_SUPPLY_MANUAL";

               columns = new String[34][];
               columns[0] = new String[]{"BUSINESSID", "string"};
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
               columns[18] = new String[]{"SUPPLYCOMFEE", "Int32"};
               columns[19] = new String[]{"BALUNITNO", "string"};
               columns[20] = new String[]{"CALLINGNO", "string"};
               columns[21] = new String[]{"CORPNO", "string"};
               columns[22] = new String[]{"DEPARTNO", "string"};
               columns[23] = new String[]{"DEALTIME", "DateTime"};
               columns[24] = new String[]{"ERRORREASONCODE", "string"};
               columns[25] = new String[]{"COMPTTIME", "DateTime"};
               columns[26] = new String[]{"COMPMONEY", "Int32"};
               columns[27] = new String[]{"COMPSTATE", "string"};
               columns[28] = new String[]{"RENEWMONEY", "Int32"};
               columns[29] = new String[]{"RENEWTIME", "DateTime"};
               columns[30] = new String[]{"RENEWSTAFFNO", "string"};
               columns[31] = new String[]{"RENEWTYPECODE", "string"};
               columns[32] = new String[]{"RENEWREMARK", "String"};
               columns[33] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "BUSINESSID",
               };


               array = new String[34];
               hash.Add("BUSINESSID", 0);
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
               hash.Add("SUPPLYCOMFEE", 18);
               hash.Add("BALUNITNO", 19);
               hash.Add("CALLINGNO", 20);
               hash.Add("CORPNO", 21);
               hash.Add("DEPARTNO", 22);
               hash.Add("DEALTIME", 23);
               hash.Add("ERRORREASONCODE", 24);
               hash.Add("COMPTTIME", 25);
               hash.Add("COMPMONEY", 26);
               hash.Add("COMPSTATE", 27);
               hash.Add("RENEWMONEY", 28);
               hash.Add("RENEWTIME", 29);
               hash.Add("RENEWSTAFFNO", 30);
               hash.Add("RENEWTYPECODE", 31);
               hash.Add("RENEWREMARK", 32);
               hash.Add("RSRVCHAR", 33);
          }

          // ҵ����ˮ��
          public string BUSINESSID
          {
              get { return  Getstring("BUSINESSID"); }
              set { Setstring("BUSINESSID",value); }
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

          // ����Ӷ��
          public Int32 SUPPLYCOMFEE
          {
              get { return  GetInt32("SUPPLYCOMFEE"); }
              set { SetInt32("SUPPLYCOMFEE",value); }
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

          // �ȶ�ʱ��
          public DateTime COMPTTIME
          {
              get { return  GetDateTime("COMPTTIME"); }
              set { SetDateTime("COMPTTIME",value); }
          }

          // �ȶԽ��׽��
          public Int32 COMPMONEY
          {
              get { return  GetInt32("COMPMONEY"); }
              set { SetInt32("COMPMONEY",value); }
          }

          // �ȶԽ��
          public string COMPSTATE
          {
              get { return  Getstring("COMPSTATE"); }
              set { Setstring("COMPSTATE",value); }
          }

          // ���ս��
          public Int32 RENEWMONEY
          {
              get { return  GetInt32("RENEWMONEY"); }
              set { SetInt32("RENEWMONEY",value); }
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

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


