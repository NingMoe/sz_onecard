using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ÔÂÆ±¿¨»»¿¨
     public class SP_AS_ZJGMonthlyCardChangePDO : PDOBase
     {
         public SP_AS_ZJGMonthlyCardChangePDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_AS_ZJGMonthlyCardChange", 34);

               AddField("@ID", "string", "18", "input");
               AddField("@custRecTypeCode", "string", "1", "input");
               AddField("@cardCost", "Int32", "", "input");
               AddField("@newCardNo", "string", "16", "input");
               AddField("@oldCardNo", "string", "16", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@checkStaffNo", "string", "6", "input");
               AddField("@checkDeptNo", "string", "4", "input");
               AddField("@changeCode", "string", "2", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@sellChannelCode", "string", "2", "input");
               AddField("@tradeTypeCode", "string", "2", "input");
               AddField("@deposit", "Int32", "", "input");
               AddField("@serStartTime", "DateTime", "", "input");
               AddField("@serviceMoney", "Int32", "", "input");
               AddField("@cardAccMoney", "Int32", "", "input");
               AddField("@newSersTakeTag", "string", "1", "input");
               AddField("@supplyRealMoney", "Int32", "", "input");
               AddField("@totalSupplyMoney", "Int32", "", "input");
               AddField("@oldDeposit", "Int32", "", "input");
               AddField("@sersTakeTag", "string", "1", "input");
               AddField("@preMoney", "Int32", "", "input");
               AddField("@nextMoney", "Int32", "", "input");
               AddField("@currentMoney", "Int32", "", "input");
               AddField("@appType", "string", "2", "input");
               AddField("@assignedArea", "string", "2", "input");
               AddField("@custSex", "string", "1", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@operateCard", "string", "16", "input");

               InitEnd();
          }

          // @ID
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // @custRecTypeCode
          public string custRecTypeCode
          {
              get { return  Getstring("custRecTypeCode"); }
              set { Setstring("custRecTypeCode",value); }
          }

          // @cardCost
          public Int32 cardCost
          {
              get { return  GetInt32("cardCost"); }
              set { SetInt32("cardCost",value); }
          }

          // @newCardNo
          public string newCardNo
          {
              get { return  Getstring("newCardNo"); }
              set { Setstring("newCardNo",value); }
          }

          // @oldCardNo
          public string oldCardNo
          {
              get { return  Getstring("oldCardNo"); }
              set { Setstring("oldCardNo",value); }
          }

          // @cardTradeNo
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // @checkStaffNo
          public string checkStaffNo
          {
              get { return  Getstring("checkStaffNo"); }
              set { Setstring("checkStaffNo",value); }
          }

          // @checkDeptNo
          public string checkDeptNo
          {
              get { return  Getstring("checkDeptNo"); }
              set { Setstring("checkDeptNo",value); }
          }

          // @changeCode
          public string changeCode
          {
              get { return  Getstring("changeCode"); }
              set { Setstring("changeCode",value); }
          }

          // @asn
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // @sellChannelCode
          public string sellChannelCode
          {
              get { return  Getstring("sellChannelCode"); }
              set { Setstring("sellChannelCode",value); }
          }

          // @tradeTypeCode
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
          }

          // @deposit
          public Int32 deposit
          {
              get { return  GetInt32("deposit"); }
              set { SetInt32("deposit",value); }
          }

          // @serStartTime
          public DateTime serStartTime
          {
              get { return  GetDateTime("serStartTime"); }
              set { SetDateTime("serStartTime",value); }
          }

          // @serviceMoney
          public Int32 serviceMoney
          {
              get { return  GetInt32("serviceMoney"); }
              set { SetInt32("serviceMoney",value); }
          }

          // @cardAccMoney
          public Int32 cardAccMoney
          {
              get { return  GetInt32("cardAccMoney"); }
              set { SetInt32("cardAccMoney",value); }
          }

          // @newSersTakeTag
          public string newSersTakeTag
          {
              get { return  Getstring("newSersTakeTag"); }
              set { Setstring("newSersTakeTag",value); }
          }

          // @supplyRealMoney
          public Int32 supplyRealMoney
          {
              get { return  GetInt32("supplyRealMoney"); }
              set { SetInt32("supplyRealMoney",value); }
          }

          // @totalSupplyMoney
          public Int32 totalSupplyMoney
          {
              get { return  GetInt32("totalSupplyMoney"); }
              set { SetInt32("totalSupplyMoney",value); }
          }

          // @oldDeposit
          public Int32 oldDeposit
          {
              get { return  GetInt32("oldDeposit"); }
              set { SetInt32("oldDeposit",value); }
          }

          // @sersTakeTag
          public string sersTakeTag
          {
              get { return  Getstring("sersTakeTag"); }
              set { Setstring("sersTakeTag",value); }
          }

          // @preMoney
          public Int32 preMoney
          {
              get { return  GetInt32("preMoney"); }
              set { SetInt32("preMoney",value); }
          }

          // @nextMoney
          public Int32 nextMoney
          {
              get { return  GetInt32("nextMoney"); }
              set { SetInt32("nextMoney",value); }
          }

          // @currentMoney
          public Int32 currentMoney
          {
              get { return  GetInt32("currentMoney"); }
              set { SetInt32("currentMoney",value); }
          }

          // @appType
          public string appType
          {
              get { return  Getstring("appType"); }
              set { Setstring("appType",value); }
          }

          // @assignedArea
          public string assignedArea
          {
              get { return  Getstring("assignedArea"); }
              set { Setstring("assignedArea",value); }
          }

          // @custSex
          public string custSex
          {
              get { return  Getstring("custSex"); }
              set { Setstring("custSex",value); }
          }

          // @changeCon
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // @operateCard
          public string operateCard
          {
              get { return  Getstring("operateCard"); }
              set { Setstring("operateCard",value); }
          }

     }
}


