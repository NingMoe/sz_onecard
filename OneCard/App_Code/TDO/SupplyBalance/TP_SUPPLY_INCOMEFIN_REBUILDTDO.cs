using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ��ʵʱ��ֵ����ת���ʵ��س������
     public class TP_SUPPLY_INCOMEFIN_REBUILDTDO : DDOBase
     {
          public TP_SUPPLY_INCOMEFIN_REBUILDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_SUPPLY_INCOMEFIN_REBUILD";

               columns = new String[41][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"FEETYPECODE", "string"};
               columns[6] = new String[]{"FINTYPECODE", "string"};
               columns[7] = new String[]{"COMFEETAKECODE", "string"};
               columns[8] = new String[]{"COMSCHEMENO", "string"};
               columns[9] = new String[]{"FINBANKCODE", "string"};
               columns[10] = new String[]{"TRANSFEE", "Int32"};
               columns[11] = new String[]{"TOTALCOMFEE", "Int32"};
               columns[12] = new String[]{"RIGHTFINFEE", "Int32"};
               columns[13] = new String[]{"RIGHTFINTIMES", "Int32"};
               columns[14] = new String[]{"RENEWFINFEE", "Int32"};
               columns[15] = new String[]{"RENEWFINTIMES", "Int32"};
               columns[16] = new String[]{"FINFEE", "Int32"};
               columns[17] = new String[]{"FINTIMES", "Int32"};
               columns[18] = new String[]{"SUBCOMFEE", "Int32"};
               columns[19] = new String[]{"FINFEEA", "Int32"};
               columns[20] = new String[]{"TIMESA", "Int32"};
               columns[21] = new String[]{"COMFEEA", "Int32"};
               columns[22] = new String[]{"FINFEEB", "Int32"};
               columns[23] = new String[]{"TIMESB", "Int32"};
               columns[24] = new String[]{"COMFEEB", "Int32"};
               columns[25] = new String[]{"FINFEEC", "Int32"};
               columns[26] = new String[]{"TIMESC", "Int32"};
               columns[27] = new String[]{"COMFEEC", "Int32"};
               columns[28] = new String[]{"FINFEED", "Int32"};
               columns[29] = new String[]{"TIMESD", "Int32"};
               columns[30] = new String[]{"COMFEED", "Int32"};
               columns[31] = new String[]{"FINFEEE", "Int32"};
               columns[32] = new String[]{"TIMESE", "Int32"};
               columns[33] = new String[]{"COMFEEE", "Int32"};
               columns[34] = new String[]{"BEGINTIME", "DateTime"};
               columns[35] = new String[]{"ENDTIME", "DateTime"};
               columns[36] = new String[]{"FINTIME", "DateTime"};
               columns[37] = new String[]{"DEALSTATECODE", "string"};
               columns[38] = new String[]{"REBUILDSTATECODE", "string"};
               columns[39] = new String[]{"RSRVCHAR", "string"};
               columns[40] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[41];
               hash.Add("ID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("FEETYPECODE", 5);
               hash.Add("FINTYPECODE", 6);
               hash.Add("COMFEETAKECODE", 7);
               hash.Add("COMSCHEMENO", 8);
               hash.Add("FINBANKCODE", 9);
               hash.Add("TRANSFEE", 10);
               hash.Add("TOTALCOMFEE", 11);
               hash.Add("RIGHTFINFEE", 12);
               hash.Add("RIGHTFINTIMES", 13);
               hash.Add("RENEWFINFEE", 14);
               hash.Add("RENEWFINTIMES", 15);
               hash.Add("FINFEE", 16);
               hash.Add("FINTIMES", 17);
               hash.Add("SUBCOMFEE", 18);
               hash.Add("FINFEEA", 19);
               hash.Add("TIMESA", 20);
               hash.Add("COMFEEA", 21);
               hash.Add("FINFEEB", 22);
               hash.Add("TIMESB", 23);
               hash.Add("COMFEEB", 24);
               hash.Add("FINFEEC", 25);
               hash.Add("TIMESC", 26);
               hash.Add("COMFEEC", 27);
               hash.Add("FINFEED", 28);
               hash.Add("TIMESD", 29);
               hash.Add("COMFEED", 30);
               hash.Add("FINFEEE", 31);
               hash.Add("TIMESE", 32);
               hash.Add("COMFEEE", 33);
               hash.Add("BEGINTIME", 34);
               hash.Add("ENDTIME", 35);
               hash.Add("FINTIME", 36);
               hash.Add("DEALSTATECODE", 37);
               hash.Add("REBUILDSTATECODE", 38);
               hash.Add("RSRVCHAR", 39);
               hash.Add("REMARK", 40);
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

          // ��������
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // ת������
          public string FINTYPECODE
          {
              get { return  Getstring("FINTYPECODE"); }
              set { Setstring("FINTYPECODE",value); }
          }

          // Ӷ��ۼ���ʽ����
          public string COMFEETAKECODE
          {
              get { return  Getstring("COMFEETAKECODE"); }
              set { Setstring("COMFEETAKECODE",value); }
          }

          // Ӷ�𷽰�����
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // ת�������д���
          public string FINBANKCODE
          {
              get { return  Getstring("FINBANKCODE"); }
              set { Setstring("FINBANKCODE",value); }
          }

          // ת�˽��
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

          // Ӷ���ܶ�
          public Int32 TOTALCOMFEE
          {
              get { return  GetInt32("TOTALCOMFEE"); }
              set { SetInt32("TOTALCOMFEE",value); }
          }

          // ������¼������
          public Int32 RIGHTFINFEE
          {
              get { return  GetInt32("RIGHTFINFEE"); }
              set { SetInt32("RIGHTFINFEE",value); }
          }

          // ������¼�������
          public Int32 RIGHTFINTIMES
          {
              get { return  GetInt32("RIGHTFINTIMES"); }
              set { SetInt32("RIGHTFINTIMES",value); }
          }

          // �ָ���¼������
          public Int32 RENEWFINFEE
          {
              get { return  GetInt32("RENEWFINFEE"); }
              set { SetInt32("RENEWFINFEE",value); }
          }

          // �ָ���¼�������
          public Int32 RENEWFINTIMES
          {
              get { return  GetInt32("RENEWFINTIMES"); }
              set { SetInt32("RENEWFINTIMES",value); }
          }

          // �����ܽ��
          public Int32 FINFEE
          {
              get { return  GetInt32("FINFEE"); }
              set { SetInt32("FINFEE",value); }
          }

          // �����ܱ���
          public Int32 FINTIMES
          {
              get { return  GetInt32("FINTIMES"); }
              set { SetInt32("FINTIMES",value); }
          }

          // ȫ��Ӷ��
          public Int32 SUBCOMFEE
          {
              get { return  GetInt32("SUBCOMFEE"); }
              set { SetInt32("SUBCOMFEE",value); }
          }

          // ������A
          public Int32 FINFEEA
          {
              get { return  GetInt32("FINFEEA"); }
              set { SetInt32("FINFEEA",value); }
          }

          // �������A
          public Int32 TIMESA
          {
              get { return  GetInt32("TIMESA"); }
              set { SetInt32("TIMESA",value); }
          }

          // Ӷ��A
          public Int32 COMFEEA
          {
              get { return  GetInt32("COMFEEA"); }
              set { SetInt32("COMFEEA",value); }
          }

          // ������B
          public Int32 FINFEEB
          {
              get { return  GetInt32("FINFEEB"); }
              set { SetInt32("FINFEEB",value); }
          }

          // �������B
          public Int32 TIMESB
          {
              get { return  GetInt32("TIMESB"); }
              set { SetInt32("TIMESB",value); }
          }

          // Ӷ��B
          public Int32 COMFEEB
          {
              get { return  GetInt32("COMFEEB"); }
              set { SetInt32("COMFEEB",value); }
          }

          // ������C
          public Int32 FINFEEC
          {
              get { return  GetInt32("FINFEEC"); }
              set { SetInt32("FINFEEC",value); }
          }

          // �������C
          public Int32 TIMESC
          {
              get { return  GetInt32("TIMESC"); }
              set { SetInt32("TIMESC",value); }
          }

          // Ӷ��C
          public Int32 COMFEEC
          {
              get { return  GetInt32("COMFEEC"); }
              set { SetInt32("COMFEEC",value); }
          }

          // ������D
          public Int32 FINFEED
          {
              get { return  GetInt32("FINFEED"); }
              set { SetInt32("FINFEED",value); }
          }

          // �������D
          public Int32 TIMESD
          {
              get { return  GetInt32("TIMESD"); }
              set { SetInt32("TIMESD",value); }
          }

          // Ӷ��D
          public Int32 COMFEED
          {
              get { return  GetInt32("COMFEED"); }
              set { SetInt32("COMFEED",value); }
          }

          // ������E
          public Int32 FINFEEE
          {
              get { return  GetInt32("FINFEEE"); }
              set { SetInt32("FINFEEE",value); }
          }

          // �������E
          public Int32 TIMESE
          {
              get { return  GetInt32("TIMESE"); }
              set { SetInt32("TIMESE",value); }
          }

          // Ӷ��E
          public Int32 COMFEEE
          {
              get { return  GetInt32("COMFEEE"); }
              set { SetInt32("COMFEEE",value); }
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

          // ת���ʵ�ʱ��
          public DateTime FINTIME
          {
              get { return  GetDateTime("FINTIME"); }
              set { SetDateTime("FINTIME",value); }
          }

          // ����״̬��
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // �س�״̬����
          public string REBUILDSTATECODE
          {
              get { return  Getstring("REBUILDSTATECODE"); }
              set { Setstring("REBUILDSTATECODE",value); }
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


