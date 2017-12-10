using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ���ʻ���
     public class TD_XFC_INITCARDTDO : DDOBase
     {
          public TD_XFC_INITCARDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_XFC_INITCARD";

               columns = new String[25][];
               columns[0] = new String[]{"XFCARDNO", "string"};
               columns[1] = new String[]{"PASSWD", "string"};
               columns[2] = new String[]{"YEAR", "string"};
               columns[3] = new String[]{"BATCHNO", "string"};
               columns[4] = new String[]{"VALUECODE", "string"};
               columns[5] = new String[]{"CORPCODE", "string"};
               columns[6] = new String[]{"CARDSTATECODE", "string"};
               columns[7] = new String[]{"PRODUCETIME", "DateTime"};
               columns[8] = new String[]{"PRODUCESTAFFNO", "string"};
               columns[9] = new String[]{"ENDDATE", "DateTime"};
               columns[10] = new String[]{"PRINTTIME", "DateTime"};
               columns[11] = new String[]{"PRINTSTAFFNO", "string"};
               columns[12] = new String[]{"INTIME", "DateTime"};
               columns[13] = new String[]{"INSTAFFNO", "string"};
               columns[14] = new String[]{"ACTIVETIME", "DateTime"};
               columns[15] = new String[]{"ACTIVESTAFFNO", "string"};
               columns[16] = new String[]{"SALETIME", "DateTime"};
               columns[17] = new String[]{"SALESTAFFNO", "string"};
               columns[18] = new String[]{"MERCHANTCODE", "string"};
               columns[19] = new String[]{"CANCELTIME", "DateTime"};
               columns[20] = new String[]{"CANCELSTAFFNO", "string"};
               columns[21] = new String[]{"RSRV1", "String"};
               columns[22] = new String[]{"RSRV2", "Int32"};
               columns[23] = new String[]{"RSRV3", "DateTime"};
               columns[24] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "XFCARDNO",
               };


               array = new String[25];
               hash.Add("XFCARDNO", 0);
               hash.Add("PASSWD", 1);
               hash.Add("YEAR", 2);
               hash.Add("BATCHNO", 3);
               hash.Add("VALUECODE", 4);
               hash.Add("CORPCODE", 5);
               hash.Add("CARDSTATECODE", 6);
               hash.Add("PRODUCETIME", 7);
               hash.Add("PRODUCESTAFFNO", 8);
               hash.Add("ENDDATE", 9);
               hash.Add("PRINTTIME", 10);
               hash.Add("PRINTSTAFFNO", 11);
               hash.Add("INTIME", 12);
               hash.Add("INSTAFFNO", 13);
               hash.Add("ACTIVETIME", 14);
               hash.Add("ACTIVESTAFFNO", 15);
               hash.Add("SALETIME", 16);
               hash.Add("SALESTAFFNO", 17);
               hash.Add("MERCHANTCODE", 18);
               hash.Add("CANCELTIME", 19);
               hash.Add("CANCELSTAFFNO", 20);
               hash.Add("RSRV1", 21);
               hash.Add("RSRV2", 22);
               hash.Add("RSRV3", 23);
               hash.Add("REMARK", 24);
          }

          // ��ֵ����
          public string XFCARDNO
          {
              get { return  Getstring("XFCARDNO"); }
              set { Setstring("XFCARDNO",value); }
          }

          // ����
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // �������
          public string YEAR
          {
              get { return  Getstring("YEAR"); }
              set { Setstring("YEAR",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // ������
          public string VALUECODE
          {
              get { return  Getstring("VALUECODE"); }
              set { Setstring("VALUECODE",value); }
          }

          // ������λ����
          public string CORPCODE
          {
              get { return  Getstring("CORPCODE"); }
              set { Setstring("CORPCODE",value); }
          }

          // ��״̬
          public string CARDSTATECODE
          {
              get { return  Getstring("CARDSTATECODE"); }
              set { Setstring("CARDSTATECODE",value); }
          }

          // ����ʱ��
          public DateTime PRODUCETIME
          {
              get { return  GetDateTime("PRODUCETIME"); }
              set { SetDateTime("PRODUCETIME",value); }
          }

          // ����Ա��
          public string PRODUCESTAFFNO
          {
              get { return  Getstring("PRODUCESTAFFNO"); }
              set { Setstring("PRODUCESTAFFNO",value); }
          }

          // ��������
          public DateTime ENDDATE
          {
              get { return  GetDateTime("ENDDATE"); }
              set { SetDateTime("ENDDATE",value); }
          }

          // ӡˢʱ��
          public DateTime PRINTTIME
          {
              get { return  GetDateTime("PRINTTIME"); }
              set { SetDateTime("PRINTTIME",value); }
          }

          // ӡˢԱ��
          public string PRINTSTAFFNO
          {
              get { return  Getstring("PRINTSTAFFNO"); }
              set { Setstring("PRINTSTAFFNO",value); }
          }

          // ���ʱ��
          public DateTime INTIME
          {
              get { return  GetDateTime("INTIME"); }
              set { SetDateTime("INTIME",value); }
          }

          // ���Ա��
          public string INSTAFFNO
          {
              get { return  Getstring("INSTAFFNO"); }
              set { Setstring("INSTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime ACTIVETIME
          {
              get { return  GetDateTime("ACTIVETIME"); }
              set { SetDateTime("ACTIVETIME",value); }
          }

          // ����Ա��
          public string ACTIVESTAFFNO
          {
              get { return  Getstring("ACTIVESTAFFNO"); }
              set { Setstring("ACTIVESTAFFNO",value); }
          }

          // �ۿ�ʱ��
          public DateTime SALETIME
          {
              get { return  GetDateTime("SALETIME"); }
              set { SetDateTime("SALETIME",value); }
          }

          // �ۿ�Ա��
          public string SALESTAFFNO
          {
              get { return  Getstring("SALESTAFFNO"); }
              set { Setstring("SALESTAFFNO",value); }
          }

          // �����������
          public string MERCHANTCODE
          {
              get { return  Getstring("MERCHANTCODE"); }
              set { Setstring("MERCHANTCODE",value); }
          }

          // ȡ����־
          public DateTime CANCELTIME
          {
              get { return  GetDateTime("CANCELTIME"); }
              set { SetDateTime("CANCELTIME",value); }
          }

          // ȡ��Ա��
          public string CANCELSTAFFNO
          {
              get { return  Getstring("CANCELSTAFFNO"); }
              set { Setstring("CANCELSTAFFNO",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public Int32 RSRV2
          {
              get { return  GetInt32("RSRV2"); }
              set { SetInt32("RSRV2",value); }
          }

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


