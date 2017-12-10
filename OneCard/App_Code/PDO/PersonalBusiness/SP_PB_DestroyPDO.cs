using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 销户
     public class SP_PB_DestroyPDO : PDOBase
     {
          public SP_PB_DestroyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Destroy",12);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@RDFUNDMONEY", "Int32", "", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 卡类型编码
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 帐户余额
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // 退充值
          public Int32 RDFUNDMONEY
          {
              get { return  GetInt32("RDFUNDMONEY"); }
              set { SetInt32("RDFUNDMONEY",value); }
          }

          // 返回交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


