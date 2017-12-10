using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // ���
     public class SP_IT_ReversePDO : PDOBase
     {
          public SP_IT_ReversePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_Reverse",11);
                AddField("@oldVolumn", "string", "12", "input");
               AddField("@oldNo", "string", "8", "input");
               AddField("@newNo", "string", "8", "input");
               AddField("@newVolumn", "string", "12", "input");
               AddField("@drawer", "String", "50", "input");
               AddField("@date", "DateTime", "", "input");

               InitEnd();
          }

          // �·�Ʊ����
          public string oldVolumn
          {
              get { return Getstring("oldVolumn"); }
              set { Setstring("oldVolumn", value); }
          }
          // ��巢Ʊ��
          public string oldNo
          {
              get { return  Getstring("oldNo"); }
              set { Setstring("oldNo",value); }
          }

          // �·�Ʊ��
          public string newNo
          {
              get { return  Getstring("newNo"); }
              set { Setstring("newNo",value); }
          }
          // �·�Ʊ����
          public string newVolumn
          {
              get { return Getstring("newVolumn"); }
              set { Setstring("newVolumn", value); }
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

     }
}


