using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // 开票
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
          // 记录流水号

          public string ID
          {
              get { return Getstring("ID"); }
              set { Setstring("ID", value); }
          }
          // 记录流水号

          public string volno
          {
              get { return Getstring("volno"); }
              set { Setstring("volno", value); }
          }
          // 记录流水号

          public string isFree
          {
              get { return Getstring("isFree"); }
              set { Setstring("isFree", value); }
          }

          // 付款方
          public String payer
          {
              get { return  GetString("payer"); }
              set { SetString("payer",value); }
          }

          // 发票号
          public string billNo
          {
              get { return  Getstring("billNo"); }
              set { Setstring("billNo",value); }
          }

          // 纳税人识别号
          public String taxNo
          {
              get { return  GetString("taxNo"); }
              set { SetString("taxNo",value); }
          }

          // 开票人
          public String drawer
          {
              get { return  GetString("drawer"); }
              set { SetString("drawer",value); }
          }

          // 开票时间
          public DateTime date
          {
              get { return  GetDateTime("date"); }
              set { SetDateTime("date",value); }
          }

          // 总金额
          public Decimal amount
          {
              get { return  GetDecimal("amount"); }
              set { SetDecimal("amount",value); }
          }

          // 附注
          public String note
          {
              get { return  GetString("note"); }
              set { SetString("note",value); }
          }

          // 项目1
          public String proj1
          {
              get { return  GetString("proj1"); }
              set { SetString("proj1",value); }
          }

          // 金额1
          public Int32 fee1
          {
              get { return  GetInt32("fee1"); }
              set { SetInt32("fee1",value); }
          }

          // 项目2
          public String proj2
          {
              get { return  GetString("proj2"); }
              set { SetString("proj2",value); }
          }

          // 金额2
          public Int32 fee2
          {
              get { return  GetInt32("fee2"); }
              set { SetInt32("fee2",value); }
          }

          // 项目3
          public String proj3
          {
              get { return  GetString("proj3"); }
              set { SetString("proj3",value); }
          }

          // 金额3
          public Int32 fee3
          {
              get { return  GetInt32("fee3"); }
              set { SetInt32("fee3",value); }
          }

          // 项目4
          public String proj4
          {
              get { return  GetString("proj4"); }
              set { SetString("proj4",value); }
          }

          // 金额4
          public Int32 fee4
          {
              get { return  GetInt32("fee4"); }
              set { SetInt32("fee4",value); }
          }

          // 项目5
          public String proj5
          {
              get { return  GetString("proj5"); }
              set { SetString("proj5",value); }
          }

          // 金额5
          public Int32 fee5
          {
              get { return  GetInt32("fee5"); }
              set { SetInt32("fee5",value); }
          }

     }
}


