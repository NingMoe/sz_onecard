using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ����
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
          // ��Ʊ����
          public string volno
          {
              get { return Getstring("volno"); }
              set { Setstring("volno", value); }
          }
          // ��ʼ����
          public string invoiceNo
          {
              get { return Getstring("invoiceNo"); }
              set { Setstring("invoiceNo", value); }
          }

          // ����ԭ��
          public string reason
          {
              get { return Getstring("reason"); }
              set { Setstring("reason", value); }
          }

          // �Ƿ����
          public string isCw
          {
              get { return Getstring("isCw"); }
              set { Setstring("isCw", value); }
          }

     }
}


