using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // ���˻���ʵʱ��ֵ�����嵥��
     public class TF_SUPPLY_CARDACC_01TDO : DDOBase
     {
          public TF_SUPPLY_CARDACC_01TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_CARDACC_01";

               columns = new String[12][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"REALCARDNO", "string"};
               columns[3] = new String[]{"TOTALSUPPLYTIMES", "Int32"};
               columns[4] = new String[]{"TOTALSUPPLYMONEY", "Int32"};
               columns[5] = new String[]{"DEALTIME", "DateTime"};
               columns[6] = new String[]{"LASTSUPPLYTIME", "DateTime"};
               columns[7] = new String[]{"CARDREALMONEY", "Int32"};
               columns[8] = new String[]{"ONLINECARDTRADENO", "string"};
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
               hash.Add("TOTALSUPPLYTIMES", 3);
               hash.Add("TOTALSUPPLYMONEY", 4);
               hash.Add("DEALTIME", 5);
               hash.Add("LASTSUPPLYTIME", 6);
               hash.Add("CARDREALMONEY", 7);
               hash.Add("ONLINECARDTRADENO", 8);
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

          // ��ֵ����
          public Int32 TOTALSUPPLYTIMES
          {
              get { return  GetInt32("TOTALSUPPLYTIMES"); }
              set { SetInt32("TOTALSUPPLYTIMES",value); }
          }

          // ��ֵ���
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // ����ʱ��
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // �����ֵʱ��
          public DateTime LASTSUPPLYTIME
          {
              get { return  GetDateTime("LASTSUPPLYTIME"); }
              set { SetDateTime("LASTSUPPLYTIME",value); }
          }

          // �����ʵ�����
          public Int32 CARDREALMONEY
          {
              get { return  GetInt32("CARDREALMONEY"); }
              set { SetInt32("CARDREALMONEY",value); }
          }

          // ����ѻ��������
          public string ONLINECARDTRADENO
          {
              get { return  Getstring("ONLINECARDTRADENO"); }
              set { Setstring("ONLINECARDTRADENO",value); }
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


