using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 增加银行编码
     public class SP_PS_BankInfoPDO : PDOBase
     {
          public SP_PS_BankInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_BankInfo",9);

               AddField("@BankCode", "string", "4", "input");
               AddField("@Bank", "String", "200", "input");
               AddField("@BankAddr", "String", "50", "input");
               AddField("@BankPhone", "String", "20", "input");

               InitEnd();
          }

          // 银行编码
          public string BankCode
          {
              get { return  Getstring("BankCode"); }
              set { Setstring("BankCode",value); }
          }

          // 银行名称
          public String Bank
          {
              get { return  GetString("Bank"); }
              set { SetString("Bank",value); }
          }

          // 银行地址
          public String BankAddr
          {
              get { return  GetString("BankAddr"); }
              set { SetString("BankAddr",value); }
          }

          // 联系方式
          public String BankPhone
          {
              get { return  GetString("BankPhone"); }
              set { SetString("BankPhone",value); }
          }

     }
}


