using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CountBalance
{
     // ԰���꿨�쳣�嵥��
     public class TF_PARK_ERROR_01TDO : DDOBase
     {
          public TF_PARK_ERROR_01TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_PARK_ERROR_01";

               columns = new String[12][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"POSNO", "string"};
               columns[3] = new String[]{"SAMNO", "string"};
               columns[4] = new String[]{"TRADEDATE", "string"};
               columns[5] = new String[]{"TRADETIME", "string"};
               columns[6] = new String[]{"SPARETIMES", "Int32"};
               columns[7] = new String[]{"ENDDATE", "string"};
               columns[8] = new String[]{"BATCHNO", "string"};
               columns[9] = new String[]{"BALUNITNO", "string"};
               columns[10] = new String[]{"DEALTIME", "DateTime"};
               columns[11] = new String[]{"ERRORREASONCODE", "string"};

               columnKeys = new String[]{
               };


               array = new String[12];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("POSNO", 2);
               hash.Add("SAMNO", 3);
               hash.Add("TRADEDATE", 4);
               hash.Add("TRADETIME", 5);
               hash.Add("SPARETIMES", 6);
               hash.Add("ENDDATE", 7);
               hash.Add("BATCHNO", 8);
               hash.Add("BALUNITNO", 9);
               hash.Add("DEALTIME", 10);
               hash.Add("ERRORREASONCODE", 11);
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // POS���
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // PSAM���
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
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

          // ʣ�����
          public Int32 SPARETIMES
          {
              get { return  GetInt32("SPARETIMES"); }
              set { SetInt32("SPARETIMES",value); }
          }

          // ��������
          public string ENDDATE
          {
              get { return  Getstring("ENDDATE"); }
              set { Setstring("ENDDATE",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ����ʱ��
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // �쳣ԭ�����
          public string ERRORREASONCODE
          {
              get { return  Getstring("ERRORREASONCODE"); }
              set { Setstring("ERRORREASONCODE",value); }
          }

     }
}


