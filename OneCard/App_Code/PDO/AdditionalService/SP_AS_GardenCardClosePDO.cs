using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ԰���꿨�ر�
     public class SP_AS_GardenCardClosePDO : PDOBase
     {
          public SP_AS_GardenCardClosePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_GardenCardClose",13);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@tradeFee", "Int32", "", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@endDateNum", "string", "12", "input");

               InitEnd();
          }

          // ����
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // Ӧ�����к�
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // ����Ա����
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // �ն˱���
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // ���׷���
          public Int32 tradeFee
          {
              get { return  GetInt32("tradeFee"); }
              set { SetInt32("tradeFee",value); }
          }

          // ����Ա����
          public string operCardNo
          {
              get { return  Getstring("operCardNo"); }
              set { Setstring("operCardNo",value); }
          }

          // �ն˱���
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // ��Ƭ���ϱ������
          public string endDateNum
          {
              get { return  Getstring("endDateNum"); }
              set { Setstring("endDateNum",value); }
          }

     }
}


