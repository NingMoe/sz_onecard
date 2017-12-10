using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // �������̨�ʱ�
     public class TF_B_SPEADJUSTACCTDO : DDOBase
     {
          public TF_B_SPEADJUSTACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_SPEADJUSTACC";

               columns = new String[24][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"ID", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"CARDTRADENO", "string"};
               columns[5] = new String[]{"TRADEDATE", "string"};
               columns[6] = new String[]{"TRADETIME", "string"};
               columns[7] = new String[]{"PREMONEY", "Int32"};
               columns[8] = new String[]{"TRADEMONEY", "Int32"};
               columns[9] = new String[]{"REFUNDMENT", "Int32"};
               columns[10] = new String[]{"CUSTPHONE", "String"};
               columns[11] = new String[]{"CUSTNAME", "String"};
               columns[12] = new String[]{"CALLINGNO", "string"};
               columns[13] = new String[]{"CORPNO", "string"};
               columns[14] = new String[]{"DEPARTNO", "string"};
               columns[15] = new String[]{"BALUNITNO", "string"};
               columns[16] = new String[]{"REASONCODE", "string"};
               columns[17] = new String[]{"REMARK", "String"};
               columns[18] = new String[]{"STATECODE", "string"};
               columns[19] = new String[]{"STAFFNO", "string"};
               columns[20] = new String[]{"OPERATETIME", "DateTime"};
               columns[21] = new String[]{"CHECKSTAFFNO", "string"};
               columns[22] = new String[]{"CHECKTIME", "DateTime"};
               columns[23] = new String[]{"RSRVCHAR", "string"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[24];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("ID", 2);
               hash.Add("CARDNO", 3);
               hash.Add("CARDTRADENO", 4);
               hash.Add("TRADEDATE", 5);
               hash.Add("TRADETIME", 6);
               hash.Add("PREMONEY", 7);
               hash.Add("TRADEMONEY", 8);
               hash.Add("REFUNDMENT", 9);
               hash.Add("CUSTPHONE", 10);
               hash.Add("CUSTNAME", 11);
               hash.Add("CALLINGNO", 12);
               hash.Add("CORPNO", 13);
               hash.Add("DEPARTNO", 14);
               hash.Add("BALUNITNO", 15);
               hash.Add("REASONCODE", 16);
               hash.Add("REMARK", 17);
               hash.Add("STATECODE", 18);
               hash.Add("STAFFNO", 19);
               hash.Add("OPERATETIME", 20);
               hash.Add("CHECKSTAFFNO", 21);
               hash.Add("CHECKTIME", 22);
               hash.Add("RSRVCHAR", 23);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
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

          // ���������к�
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
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

          // �˿���
          public Int32 REFUNDMENT
          {
              get { return  GetInt32("REFUNDMENT"); }
              set { SetInt32("REFUNDMENT",value); }
          }

          // �ֿ��˵绰
          public String CUSTPHONE
          {
              get { return  GetString("CUSTPHONE"); }
              set { SetString("CUSTPHONE",value); }
          }

          // �ֿ�������
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
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

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ����ԭ�����
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // �������˵��
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ���״̬
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
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

          // ���Ա��
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // ���ʱ��
          public DateTime CHECKTIME
          {
              get { return  GetDateTime("CHECKTIME"); }
              set { SetDateTime("CHECKTIME",value); }
          }

          // ������־
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

     }
}


