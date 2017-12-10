using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ��Ʊ
     public class SP_IT_Billing_HDPDO : PDOBase
     {
          public SP_IT_Billing_HDPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_Billing_HD",22);
               AddField("@ID", "String", "18", "input");
               AddField("@volno", "String", "12", "input");
               AddField("@isFree", "String", "1", "input");
               AddField("@payer", "String", "200", "input");
               AddField("@billNo", "string", "8", "input");
               AddField("@taxNo", "String", "100", "input");
               AddField("@drawer", "String", "50", "input");
               AddField("@date", "DateTime", "", "input");
               AddField("@amount", "Decimal", "", "input");
               AddField("@note", "String", "200", "input");
               AddField("@proj1", "String", "50", "input");
               AddField("@fee1", "Int32", "", "input");
               AddField("@proj2", "String", "50", "input");
               AddField("@fee2", "Int32", "", "input");
               AddField("@proj3", "String", "50", "input");
               AddField("@fee3", "Int32", "", "input");
               AddField("@proj4", "String", "50", "input");
               AddField("@fee4", "Int32", "", "input");
               AddField("@proj5", "String", "50", "input");
               AddField("@fee5", "Int32", "", "input");

               InitEnd();
          }
          // ��¼��ˮ��

          public string ID
          {
              get { return Getstring("ID"); }
              set { Setstring("ID", value); }
          }
          // ��¼��ˮ��

          public string volno
          {
              get { return Getstring("volno"); }
              set { Setstring("volno", value); }
          }
          // ��¼��ˮ��

          public string isFree
          {
              get { return Getstring("isFree"); }
              set { Setstring("isFree", value); }
          }

          // ���
          public String payer
          {
              get { return  GetString("payer"); }
              set { SetString("payer",value); }
          }

          // ��Ʊ��
          public string billNo
          {
              get { return  Getstring("billNo"); }
              set { Setstring("billNo",value); }
          }

          // ��˰��ʶ���
          public String taxNo
          {
              get { return  GetString("taxNo"); }
              set { SetString("taxNo",value); }
          }

          // ��Ʊ��
          public String drawer
          {
              get { return  GetString("drawer"); }
              set { SetString("drawer",value); }
          }

          // ��Ʊʱ��
          public DateTime date
          {
              get { return  GetDateTime("date"); }
              set { SetDateTime("date",value); }
          }

          // �ܽ��
          public Decimal amount
          {
              get { return  GetDecimal("amount"); }
              set { SetDecimal("amount",value); }
          }

          // ��ע
          public String note
          {
              get { return  GetString("note"); }
              set { SetString("note",value); }
          }

          // ��Ŀ1
          public String proj1
          {
              get { return  GetString("proj1"); }
              set { SetString("proj1",value); }
          }

          // ���1
          public Int32 fee1
          {
              get { return  GetInt32("fee1"); }
              set { SetInt32("fee1",value); }
          }

          // ��Ŀ2
          public String proj2
          {
              get { return  GetString("proj2"); }
              set { SetString("proj2",value); }
          }

          // ���2
          public Int32 fee2
          {
              get { return  GetInt32("fee2"); }
              set { SetInt32("fee2",value); }
          }

          // ��Ŀ3
          public String proj3
          {
              get { return  GetString("proj3"); }
              set { SetString("proj3",value); }
          }

          // ���3
          public Int32 fee3
          {
              get { return  GetInt32("fee3"); }
              set { SetInt32("fee3",value); }
          }

          // ��Ŀ4
          public String proj4
          {
              get { return  GetString("proj4"); }
              set { SetString("proj4",value); }
          }

          // ���4
          public Int32 fee4
          {
              get { return  GetInt32("fee4"); }
              set { SetInt32("fee4",value); }
          }

          // ��Ŀ5
          public String proj5
          {
              get { return  GetString("proj5"); }
              set { SetString("proj5",value); }
          }

          // ���5
          public Int32 fee5
          {
              get { return  GetInt32("fee5"); }
              set { SetInt32("fee5",value); }
          }

     }
}


