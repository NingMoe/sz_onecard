using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // �����꿨��д��
     public class SP_AS_RelaxCardAppendPDO : PDOBase
     {
          public SP_AS_RelaxCardAppendPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_RelaxCardAppend",10);

               AddField("@cardNo", "string", "16", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@endDateNum", "string", "12", "input");
               AddField("@packageTypeCode", "string", "2", "input");

               InitEnd();
          }

          // �ײ�����
          public string packageTypeCode
          {
              get { return Getstring("packageTypeCode"); }
              set { Setstring("packageTypeCode", value); }
          }

          // ����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // Ӧ�����к�
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
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


