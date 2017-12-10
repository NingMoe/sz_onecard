using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ��������ֵ��־��
     public class TL_XFC_TRADELOGTDO : DDOBase
     {
          public TL_XFC_TRADELOGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_XFC_TRADELOG";

               columns = new String[10][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"XFCARDNO", "string"};
               columns[2] = new String[]{"PASSWD", "string"};
               columns[3] = new String[]{"CARDFEE", "Int32"};
               columns[4] = new String[]{"CARDNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"UPDATESTAFFNO", "string"};
               columns[7] = new String[]{"REMARK", "String"};
               columns[8] = new String[]{"TERMNO", "String"};
               columns[9] = new String[]{"DEPARTNO", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[10];
               hash.Add("TRADEID", 0);
               hash.Add("XFCARDNO", 1);
               hash.Add("PASSWD", 2);
               hash.Add("CARDFEE", 3);
               hash.Add("CARDNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("REMARK", 7);
               hash.Add("TERMNO", 8);
               hash.Add("DEPARTNO", 9);
          }

          // �������
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
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
          public Int32 CARDFEE
          {
              get { return  GetInt32("CARDFEE"); }
              set { SetInt32("CARDFEE",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��ֵʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // ��ֵԱ��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // �ն˺�
          public String TERMNO
          {
              get { return  GetString("TERMNO"); }
              set { SetString("TERMNO",value); }
          }

          // ���ź�
          public String DEPARTNO
          {
              get { return  GetString("DEPARTNO"); }
              set { SetString("DEPARTNO",value); }
          }

     }
}


