using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // 特殊调帐录入
     public class SP_SD_SpeAdjustAccInputPDO : PDOBase
     {
          public SP_SD_SpeAdjustAccInputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SpeAdjustAccInput",12);

               AddField("@ID", "string", "26", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardUser", "String", "50", "input");
               AddField("@userPhone", "String", "40", "input");
               AddField("@refundMoney", "Int32", "", "input");
               AddField("@adjAccReson", "string", "1", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@ReBrokerage", "Int32", "", "input");

               InitEnd();
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC卡号
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // 持卡人用户名
          public String cardUser
          {
              get { return  GetString("cardUser"); }
              set { SetString("cardUser",value); }
          }

          // 持卡人电话
          public String userPhone
          {
              get { return  GetString("userPhone"); }
              set { SetString("userPhone",value); }
          }

          // 退款金额
          public Int32 refundMoney
          {
              get { return  GetInt32("refundMoney"); }
              set { SetInt32("refundMoney",value); }
          }

          // 调帐原因
          public string adjAccReson
          {
              get { return  Getstring("adjAccReson"); }
              set { Setstring("adjAccReson",value); }
          }

          // 交易说明
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // 应退还商户佣金
          public Int32 ReBrokerage
          {
              get { return GetInt32("ReBrokerage"); }
              set { SetInt32("ReBrokerage", value); }
          }

     }
}


