using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // ��ֵ���ۿ�����
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

          // ���κ�
          public String batchNo
          {
              get { return  GetString("batchNo"); }
              set { SetString("batchNo",value); }
          }

     }
}


