using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // ��Ʊ��Ŀ���Ʊ����
     public class TD_M_INVOICEPROJTDO : DDOBase
     {
          public TD_M_INVOICEPROJTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INVOICEPROJ";

               columns = new String[4][];
               columns[0] = new String[]{"INVOICEPROJNO", "string"};
               columns[1] = new String[]{"INVOICEPROJNAME", "String"};
               columns[2] = new String[]{"OPERATESTAFFNO", "string"};
               columns[3] = new String[]{"OPERATETIME", "DateTime"};

               columnKeys = new String[]{
                   "INVOICEPROJNO",
               };


               array = new String[4];
               hash.Add("INVOICEPROJNO", 0);
               hash.Add("INVOICEPROJNAME", 1);
               hash.Add("OPERATESTAFFNO", 2);
               hash.Add("OPERATETIME", 3);
          }

          // ��Ʊ��Ŀ����
          public string INVOICEPROJNO
          {
              get { return  Getstring("INVOICEPROJNO"); }
              set { Setstring("INVOICEPROJNO",value); }
          }

          // ��Ʊ��Ŀ����
          public String INVOICEPROJNAME
          {
              get { return  GetString("INVOICEPROJNAME"); }
              set { SetString("INVOICEPROJNAME",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

     }
}


