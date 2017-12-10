using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // 发票项目名称编码表
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

          // 发票项目编码
          public string INVOICEPROJNO
          {
              get { return  Getstring("INVOICEPROJNO"); }
              set { Setstring("INVOICEPROJNO",value); }
          }

          // 发票项目名称
          public String INVOICEPROJNAME
          {
              get { return  GetString("INVOICEPROJNAME"); }
              set { SetString("INVOICEPROJNAME",value); }
          }

          // 操作员工编码
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

     }
}


