using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 退款
     public class SP_PB_RefundPDO : PDOBase
     {
          public SP_PB_RefundPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Refund",15);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@BACKMONEY", "Int32", "", "input");
               AddField("@BANKCODE", "string", "4", "input");
               AddField("@BANKACCNO", "String", "30", "input");
               AddField("@CUSTNAME", "String", "50", "input");
               AddField("@BACKSLOPE", "Decimal", "10,8", "input");
               AddField("@FACTMONEY", "Int32", "", "input");
               AddField("@TRADEID", "string", "16", "output");

               //add by jiangbb 2012-05-18 新增收款人账户类型
               AddField("@purposeType", "string", "1", "input");
               
               InitEnd();
          }

          //收款人账户类型
          public string purposeType
          {
              get { return Getstring("purposeType"); }
              set { Setstring("purposeType", value); }
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

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 退款金额
          public Int32 BACKMONEY
          {
              get { return  GetInt32("BACKMONEY"); }
              set { SetInt32("BACKMONEY",value); }
          }

          // 银行编码
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // 银行帐号
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // 姓名
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // 返还比例
          public Decimal BACKSLOPE
          {
              get { return  GetDecimal("BACKSLOPE"); }
              set { SetDecimal("BACKSLOPE",value); }
          }

          // 实际退款金额
          public Int32 FACTMONEY
          {
              get { return  GetInt32("FACTMONEY"); }
              set { SetInt32("FACTMONEY",value); }
          }

          // 返回交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


