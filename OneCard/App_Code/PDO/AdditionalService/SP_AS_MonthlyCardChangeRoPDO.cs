using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // 月票卡售卡换卡返销
     public class SP_AS_MonthlyCardChangeRoPDO : PDOBase
     {
          public SP_AS_MonthlyCardChangeRoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_MonthlyCardChangeRo",11);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@cancelTradeId", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@currCardNo", "string", "16", "input");

               InitEnd();
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 卡号
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // 联机交易序号
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // 返销业务编码
          public string cancelTradeId
          {
              get { return  Getstring("cancelTradeId"); }
              set { Setstring("cancelTradeId",value); }
          }

          // 终端编码
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // 操作员卡
          public string currCardNo
          {
              get { return  Getstring("currCardNo"); }
              set { Setstring("currCardNo",value); }
          }

     }
}


