using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // ���˻����Ѻ�����ʱ��
     public class TM_TRADE_CARDACC_C1TDO : DDOBase
     {
          public TM_TRADE_CARDACC_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_TRADE_CARDACC_C1";

               columns = new String[10][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REALCARDNO", "string"};
               columns[2] = new String[]{"TOTALCONSUMETIMES", "Int32"};
               columns[3] = new String[]{"TOTALCONSUMEMONEY", "Int32"};
               columns[4] = new String[]{"DEALTIME", "DateTime"};
               columns[5] = new String[]{"LASTCONSUMETIME", "DateTime"};
               columns[6] = new String[]{"CARDREALMONEY", "Int32"};
               columns[7] = new String[]{"OFFLINECARDTRADENO", "string"};
               columns[8] = new String[]{"BATCHNO", "string"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[10];
               hash.Add("CARDNO", 0);
               hash.Add("REALCARDNO", 1);
               hash.Add("TOTALCONSUMETIMES", 2);
               hash.Add("TOTALCONSUMEMONEY", 3);
               hash.Add("DEALTIME", 4);
               hash.Add("LASTCONSUMETIME", 5);
               hash.Add("CARDREALMONEY", 6);
               hash.Add("OFFLINECARDTRADENO", 7);
               hash.Add("BATCHNO", 8);
               hash.Add("REMARK", 9);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ʵ����������
          public string REALCARDNO
          {
              get { return  Getstring("REALCARDNO"); }
              set { Setstring("REALCARDNO",value); }
          }

          // ���ѱ���
          public Int32 TOTALCONSUMETIMES
          {
              get { return  GetInt32("TOTALCONSUMETIMES"); }
              set { SetInt32("TOTALCONSUMETIMES",value); }
          }

          // ���ѽ��
          public Int32 TOTALCONSUMEMONEY
          {
              get { return  GetInt32("TOTALCONSUMEMONEY"); }
              set { SetInt32("TOTALCONSUMEMONEY",value); }
          }

          // ����ʱ��
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // �������ʱ��
          public DateTime LASTCONSUMETIME
          {
              get { return  GetDateTime("LASTCONSUMETIME"); }
              set { SetDateTime("LASTCONSUMETIME",value); }
          }

          // �����ʵ�����
          public Int32 CARDREALMONEY
          {
              get { return  GetInt32("CARDREALMONEY"); }
              set { SetInt32("CARDREALMONEY",value); }
          }

          // ����ѻ��������
          public string OFFLINECARDTRADENO
          {
              get { return  Getstring("OFFLINECARDTRADENO"); }
              set { Setstring("OFFLINECARDTRADENO",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


