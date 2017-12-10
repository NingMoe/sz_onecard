using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ��Ʊ���ۿ���������
     public class SP_AS_MonthlyCardNewRollbackPDO : PDOBase
     {
          public SP_AS_MonthlyCardNewRollbackPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_MonthlyCardNewRollback",12);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@cardMoney", "Int32", "", "input");
               AddField("@cancelTradeId", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@currCardNo", "string", "16", "input");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // �����������
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // �������
          public Int32 cardMoney
          {
              get { return  GetInt32("cardMoney"); }
              set { SetInt32("cardMoney",value); }
          }

          // ����ҵ�����
          public string cancelTradeId
          {
              get { return  Getstring("cancelTradeId"); }
              set { Setstring("cancelTradeId",value); }
          }

          // �ն˱���
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // ����Ա��
          public string currCardNo
          {
              get { return  Getstring("currCardNo"); }
              set { Setstring("currCardNo",value); }
          }

     }
}


