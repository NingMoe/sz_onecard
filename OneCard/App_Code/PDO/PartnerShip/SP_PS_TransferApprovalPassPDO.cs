using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 结算单元信息审批通过
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

          // 业务流水号
          public string tradeId
          {
              get { return  Getstring("tradeId"); }
              set { Setstring("tradeId",value); }
          }

          // 业务类型编码
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
          }

          // 结算单元编码
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // 通道编码
          public string channelNo
          {
              get { return  Getstring("channelNo"); }
              set { Setstring("channelNo",value); }
          }

     }
}


