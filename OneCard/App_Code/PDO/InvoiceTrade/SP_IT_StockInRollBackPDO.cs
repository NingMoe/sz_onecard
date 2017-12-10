using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ���
     public class SP_IT_StockInRollBackPDO : PDOBase
     {
         public SP_IT_StockInRollBackPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_IT_StockInRollBack", 7);
               AddField("@volumeno", "string", "12", "input");
               AddField("@beginNo", "string", "8", "input");
               AddField("@endNo", "string", "8", "input");

               InitEnd();
          }

          // ��Ʊ����
          public string volumeno
          {
              get { return Getstring("volumeno"); }
              set { Setstring("volumeno", value); }
          }
          // ��ʼ����
          public string beginNo
          {
              get { return  Getstring("beginNo"); }
              set { Setstring("beginNo",value); }
          }

          // ��ֹ����
          public string endNo
          {
              get { return  Getstring("endNo"); }
              set { Setstring("endNo",value); }
          }

     }
}


