using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // 作废
     public class SP_IT_VoidPDO : PDOBase
     {
          public SP_IT_VoidPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_Void",8);
                AddField("@volno", "string", "12", "input");
                AddField("@invoiceNo", "string", "8", "input");
                AddField("@reason", "string", "20", "input");
                AddField("@isCw", "string", "1", "input");
               InitEnd();
          }
          // 发票代码
          public string volno
          {
              get { return Getstring("volno"); }
              set { Setstring("volno", value); }
          }
          // 起始卡号
          public string invoiceNo
          {
              get { return Getstring("invoiceNo"); }
              set { Setstring("invoiceNo", value); }
          }

          // 作废原因
          public string reason
          {
              get { return Getstring("reason"); }
              set { Setstring("reason", value); }
          }

          // 是否财务
          public string isCw
          {
              get { return Getstring("isCw"); }
              set { Setstring("isCw", value); }
          }

     }
}


