using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // 充值卡售卡
     public class SP_CC_StockOutPDO : PDOBase
     {
          public SP_CC_StockOutPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_CC_StockOut", 8);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@assignDepartNo", "String", "4", "input");
            

               InitEnd();
          }

          // 开始卡号
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // 结束卡号
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // 备注
          public String assignDepartNo
          {
              get { return GetString("assignDepartNo"); }
              set { SetString("assignDepartNo", value); }
          }

     }
}


