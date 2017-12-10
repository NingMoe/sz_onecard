using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // �澯��
     public class TP_ALARMTDO : DDOBase
     {
          public TP_ALARMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_ALARM";

               columns = new String[13][];
               columns[0] = new String[]{"ALARMNO", "Decimal"};
               columns[1] = new String[]{"ALARMTYPECODE", "string"};
               columns[2] = new String[]{"PROGNO", "string"};
               columns[3] = new String[]{"CHNLNO", "String"};
               columns[4] = new String[]{"SOURCE", "String"};
               columns[5] = new String[]{"ALARMLEVEL", "Int32"};
               columns[6] = new String[]{"ALARMDESC", "String"};
               columns[7] = new String[]{"OCCURTIME", "DateTime"};
               columns[8] = new String[]{"DEALSTATECODE", "string"};
               columns[9] = new String[]{"STAFFNO", "string"};
               columns[10] = new String[]{"OPERATETIME", "DateTime"};
               columns[11] = new String[]{"DEALDESC", "String"};
               columns[12] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ALARMNO",
               };


               array = new String[13];
               hash.Add("ALARMNO", 0);
               hash.Add("ALARMTYPECODE", 1);
               hash.Add("PROGNO", 2);
               hash.Add("CHNLNO", 3);
               hash.Add("SOURCE", 4);
               hash.Add("ALARMLEVEL", 5);
               hash.Add("ALARMDESC", 6);
               hash.Add("OCCURTIME", 7);
               hash.Add("DEALSTATECODE", 8);
               hash.Add("STAFFNO", 9);
               hash.Add("OPERATETIME", 10);
               hash.Add("DEALDESC", 11);
               hash.Add("REMARK", 12);
          }

          // �澯���
          public Decimal ALARMNO
          {
              get { return  GetDecimal("ALARMNO"); }
              set { SetDecimal("ALARMNO",value); }
          }

          // �澯���ͱ���
          public string ALARMTYPECODE
          {
              get { return  Getstring("ALARMTYPECODE"); }
              set { Setstring("ALARMTYPECODE",value); }
          }

          // ������
          public string PROGNO
          {
              get { return  Getstring("PROGNO"); }
              set { Setstring("PROGNO",value); }
          }

          // ͨ�����
          public String CHNLNO
          {
              get { return  GetString("CHNLNO"); }
              set { SetString("CHNLNO",value); }
          }

          // �澯Դ
          public String SOURCE
          {
              get { return  GetString("SOURCE"); }
              set { SetString("SOURCE",value); }
          }

          // �澯����
          public Int32 ALARMLEVEL
          {
              get { return  GetInt32("ALARMLEVEL"); }
              set { SetInt32("ALARMLEVEL",value); }
          }

          // �澯����
          public String ALARMDESC
          {
              get { return  GetString("ALARMDESC"); }
              set { SetString("ALARMDESC",value); }
          }

          // ����ʱ��
          public DateTime OCCURTIME
          {
              get { return  GetDateTime("OCCURTIME"); }
              set { SetDateTime("OCCURTIME",value); }
          }

          // ����״̬����
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
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

          // ����������
          public String DEALDESC
          {
              get { return  GetString("DEALDESC"); }
              set { SetString("DEALDESC",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


