using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���㵥Ԫ��Ϣ����ͨ��
     public class SP_PS_TransferApprovalPassPDO : PDOBase
     {
          public SP_PS_TransferApprovalPassPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_TransferApprovalPass",9);

               AddField("@tradeId", "string", "16", "input");
               AddField("@tradeTypeCode", "string", "2", "input");
               AddField("@balUnitNo", "string", "8", "input");
               AddField("@channelNo", "string", "4", "input");

               InitEnd();
          }

          // ҵ����ˮ��
          public string tradeId
          {
              get { return  Getstring("tradeId"); }
              set { Setstring("tradeId",value); }
          }

          // ҵ�����ͱ���
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
          }

          // ���㵥Ԫ����
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // ͨ������
          public string channelNo
          {
              get { return  Getstring("channelNo"); }
              set { Setstring("channelNo",value); }
          }

     }
}


