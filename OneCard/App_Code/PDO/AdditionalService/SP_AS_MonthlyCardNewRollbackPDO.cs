using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // 月票卡售卡补卡返销
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

          // 卡内余额
          public Int32 cardMoney
          {
              get { return  GetInt32("cardMoney"); }
              set { SetInt32("cardMoney",value); }
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


