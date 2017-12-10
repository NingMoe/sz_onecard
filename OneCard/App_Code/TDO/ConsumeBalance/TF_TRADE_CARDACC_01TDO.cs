using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // ���˻����Ѻ����嵥��
     public class TF_TRADE_CARDACC_01TDO : DDOBase
     {
          public TF_TRADE_CARDACC_01TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADE_CARDACC_01";

               columns = new String[12][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"REALCARDNO", "string"};
               columns[3] = new String[]{"TOTALCONSUMETIMES", "Int32"};
               columns[4] = new String[]{"TOTALCONSUMEMONEY", "Int32"};
               columns[5] = new String[]{"DEALTIME", "DateTime"};
               columns[6] = new String[]{"LASTCONSUMETIME", "DateTime"};
               columns[7] = new String[]{"CARDREALMONEY", "Int32"};
               columns[8] = new String[]{"OFFLINECARDTRADENO", "string"};
               columns[9] = new String[]{"BATCHNO", "string"};
               columns[10] = new String[]{"INLISTTIME", "DateTime"};
               columns[11] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[12];
               hash.Add("ID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("REALCARDNO", 2);
               hash.Add("TOTALCONSUMETIMES", 3);
               hash.Add("TOTALCONSUMEMONEY", 4);
               hash.Add("DEALTIME", 5);
               hash.Add("LASTCONSUMETIME", 6);
               hash.Add("CARDREALMONEY", 7);
               hash.Add("OFFLINECARDTRADENO", 8);
               hash.Add("BATCHNO", 9);
               hash.Add("INLISTTIME", 10);
               hash.Add("REMARK", 11);
          }

          // �嵥��ˮ��
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
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

          // ���嵥ʱ��
          public DateTime INLISTTIME
          {
              get { return  GetDateTime("INLISTTIME"); }
              set { SetDateTime("INLISTTIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


