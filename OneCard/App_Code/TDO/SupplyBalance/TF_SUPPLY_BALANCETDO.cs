using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ�����ʵ���
     public class TF_SUPPLY_BALANCETDO : DDOBase
     {
          public TF_SUPPLY_BALANCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_BALANCE";

               columns = new String[27][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"FEETYPECODE", "string"};
               columns[6] = new String[]{"BILLTYPECODE", "string"};
               columns[7] = new String[]{"ERRORREASONCODE", "string"};
               columns[8] = new String[]{"TOTALBALFEE", "Int32"};
               columns[9] = new String[]{"TOTALTIMES", "Int32"};
               columns[10] = new String[]{"SINCOMADDFEE", "Int32"};
               columns[11] = new String[]{"BALFEEA", "Int32"};
               columns[12] = new String[]{"TIMESA", "Int32"};
               columns[13] = new String[]{"BALFEEB", "Int32"};
               columns[14] = new String[]{"TIMESB", "Int32"};
               columns[15] = new String[]{"BALFEEC", "Int32"};
               columns[16] = new String[]{"TIMESC", "Int32"};
               columns[17] = new String[]{"BALFEED", "Int32"};
               columns[18] = new String[]{"TIMESD", "Int32"};
               columns[19] = new String[]{"BALFEEE", "Int32"};
               columns[20] = new String[]{"TIMESE", "Int32"};
               columns[21] = new String[]{"BEGINTIME", "DateTime"};
               columns[22] = new String[]{"ENDTIME", "DateTime"};
               columns[23] = new String[]{"BALANCETIME", "DateTime"};
               columns[24] = new String[]{"DEALSTATECODE", "string"};
               columns[25] = new String[]{"RSRVCHAR", "string"};
               columns[26] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[27];
               hash.Add("ID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("FEETYPECODE", 5);
               hash.Add("BILLTYPECODE", 6);
               hash.Add("ERRORREASONCODE", 7);
               hash.Add("TOTALBALFEE", 8);
               hash.Add("TOTALTIMES", 9);
               hash.Add("SINCOMADDFEE", 10);
               hash.Add("BALFEEA", 11);
               hash.Add("TIMESA", 12);
               hash.Add("BALFEEB", 13);
               hash.Add("TIMESB", 14);
               hash.Add("BALFEEC", 15);
               hash.Add("TIMESC", 16);
               hash.Add("BALFEED", 17);
               hash.Add("TIMESD", 18);
               hash.Add("BALFEEE", 19);
               hash.Add("TIMESE", 20);
               hash.Add("BEGINTIME", 21);
               hash.Add("ENDTIME", 22);
               hash.Add("BALANCETIME", 23);
               hash.Add("DEALSTATECODE", 24);
               hash.Add("RSRVCHAR", 25);
               hash.Add("REMARK", 26);
          }

          // ������ˮ��
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
          }

          // ���㵥Ԫ���
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

          // �������ͱ���
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // �˵����ͱ���
          public string BILLTYPECODE
          {
              get { return  Getstring("BILLTYPECODE"); }
              set { Setstring("BILLTYPECODE",value); }
          }

          // �쳣ԭ�����
          public string ERRORREASONCODE
          {
              get { return  Getstring("ERRORREASONCODE"); }
              set { Setstring("ERRORREASONCODE",value); }
          }

          // �����ܽ��
          public Int32 TOTALBALFEE
          {
              get { return  GetInt32("TOTALBALFEE"); }
              set { SetInt32("TOTALBALFEE",value); }
          }

          // �����ܱ���
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // �����ۼ�Ӷ��
          public Int32 SINCOMADDFEE
          {
              get { return  GetInt32("SINCOMADDFEE"); }
              set { SetInt32("SINCOMADDFEE",value); }
          }

          // ������A
          public Int32 BALFEEA
          {
              get { return  GetInt32("BALFEEA"); }
              set { SetInt32("BALFEEA",value); }
          }

          // �������A
          public Int32 TIMESA
          {
              get { return  GetInt32("TIMESA"); }
              set { SetInt32("TIMESA",value); }
          }

          // ������B
          public Int32 BALFEEB
          {
              get { return  GetInt32("BALFEEB"); }
              set { SetInt32("BALFEEB",value); }
          }

          // �������B
          public Int32 TIMESB
          {
              get { return  GetInt32("TIMESB"); }
              set { SetInt32("TIMESB",value); }
          }

          // ������C
          public Int32 BALFEEC
          {
              get { return  GetInt32("BALFEEC"); }
              set { SetInt32("BALFEEC",value); }
          }

          // �������C
          public Int32 TIMESC
          {
              get { return  GetInt32("TIMESC"); }
              set { SetInt32("TIMESC",value); }
          }

          // ������D
          public Int32 BALFEED
          {
              get { return  GetInt32("BALFEED"); }
              set { SetInt32("BALFEED",value); }
          }

          // �������D
          public Int32 TIMESD
          {
              get { return  GetInt32("TIMESD"); }
              set { SetInt32("TIMESD",value); }
          }

          // ������E
          public Int32 BALFEEE
          {
              get { return  GetInt32("BALFEEE"); }
              set { SetInt32("BALFEEE",value); }
          }

          // �������E
          public Int32 TIMESE
          {
              get { return  GetInt32("TIMESE"); }
              set { SetInt32("TIMESE",value); }
          }

          // ��ʼʱ��
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // ����ʱ��
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // �����ʵ�ʱ��
          public DateTime BALANCETIME
          {
              get { return  GetDateTime("BALANCETIME"); }
              set { SetDateTime("BALANCETIME",value); }
          }

          // ����״̬����
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


