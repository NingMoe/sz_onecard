using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CountBalance
{
     // �����꿨�����ʱ��
     public class TI_XXPARK_LOADTDO : DDOBase
     {
          public TI_XXPARK_LOADTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TI_XXPARK_LOAD";

               columns = new String[9][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"POSNO", "string"};
               columns[3] = new String[]{"SAMNO", "string"};
               columns[4] = new String[]{"TRADEDATE", "string"};
               columns[5] = new String[]{"TRADETIME", "string"};
               columns[6] = new String[]{"SPARETIMES", "Int32"};
               columns[7] = new String[]{"ENDDATE", "string"};
               columns[8] = new String[]{"BATCHNO", "string"};

               columnKeys = new String[]{
               };


               array = new String[9];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("POSNO", 2);
               hash.Add("SAMNO", 3);
               hash.Add("TRADEDATE", 4);
               hash.Add("TRADETIME", 5);
               hash.Add("SPARETIMES", 6);
               hash.Add("ENDDATE", 7);
               hash.Add("BATCHNO", 8);
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

     }
}


