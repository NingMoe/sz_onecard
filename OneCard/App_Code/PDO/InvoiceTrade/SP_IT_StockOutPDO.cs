using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ����
     public class SP_IT_StockOutPDO : PDOBase
     {
          public SP_IT_StockOutPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_StockOut",9);
                AddField("@volumeno", "string", "12", "input");
               AddField("@beginNo", "string", "8", "input");
               AddField("@endNo", "string", "8", "input");
               AddField("@allotDept", "string", "4", "input");
               AddField("@allotStaff", "string", "6", "input");

               InitEnd();
          }
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

          // ���ò���
          public string allotDept
          {
              get { return  Getstring("allotDept"); }
              set { Setstring("allotDept",value); }
          }

          // ������
          public string allotStaff
          {
              get { return  Getstring("allotStaff"); }
              set { Setstring("allotStaff",value); }
          }

     }
}


