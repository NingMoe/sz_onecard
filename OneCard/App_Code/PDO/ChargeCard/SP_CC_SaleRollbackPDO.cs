using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // 充值卡售卡返销
     public class SP_CC_SaleRollbackPDO : PDOBase
     {
          public SP_CC_SaleRollbackPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_SaleRollback",6);

               AddField("@batchNo", "String", "16", "input");

               InitEnd();
          }

          // 批次号
          public String batchNo
          {
              get { return  GetString("batchNo"); }
              set { SetString("batchNo",value); }
          }

     }
}


