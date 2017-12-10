using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // 月票卡售卡
     public class SP_AS_MonthlyCardNewPDO : PDOBase
     {
          public SP_AS_MonthlyCardNewPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_MonthlyCardNew",31);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@deposit", "Int32", "", "input");
               AddField("@cardCost", "Int32", "", "input");
               AddField("@otherFee", "Int32", "", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@cardMoney", "Int32", "", "input");
               AddField("@sellChannelCode", "string", "2", "input");
               AddField("@serTakeTag", "string", "1", "input");
               AddField("@tradeTypeCode", "string", "2", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@custRecTypeCode", "string", "1", "input");
               AddField("@appType", "string", "2", "input");
               AddField("@assignedArea", "string", "2", "input");
               AddField("@currCardNo", "string", "16", "input");

               //UPDATE BY JINAGBB 2012-04-19 字段加密长度修改
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

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

          // 卡押金
          public Int32 deposit
          {
              get { return  GetInt32("deposit"); }
              set { SetInt32("deposit",value); }
          }

          // 卡费
          public Int32 cardCost
          {
              get { return  GetInt32("cardCost"); }
              set { SetInt32("cardCost",value); }
          }

          // 其他费用
          public Int32 otherFee
          {
              get { return  GetInt32("otherFee"); }
              set { SetInt32("otherFee",value); }
          }

          // 联机交易序号
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // 应用序列号
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // 卡内余额
          public Int32 cardMoney
          {
              get { return  GetInt32("cardMoney"); }
              set { SetInt32("cardMoney",value); }
          }

          // 售卡渠道编码
          public string sellChannelCode
          {
              get { return  Getstring("sellChannelCode"); }
              set { Setstring("sellChannelCode",value); }
          }

          // 服务费收取标志
          public string serTakeTag
          {
              get { return  Getstring("serTakeTag"); }
              set { Setstring("serTakeTag",value); }
          }

          // 交易类型编码
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
          }

          // 卡片资料变更内容
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // 姓名
          public String custName
          {
              get { return  GetString("custName"); }
              set { SetString("custName",value); }
          }

          // 性别
          public String custSex
          {
              get { return  GetString("custSex"); }
              set { SetString("custSex",value); }
          }

          // 出生日期
          public String custBirth
          {
              get { return  GetString("custBirth"); }
              set { SetString("custBirth",value); }
          }

          // 证件类型编码
          public String paperType
          {
              get { return  GetString("paperType"); }
              set { SetString("paperType",value); }
          }

          // 证件号码
          public String paperNo
          {
              get { return  GetString("paperNo"); }
              set { SetString("paperNo",value); }
          }

          // 联系地址
          public String custAddr
          {
              get { return  GetString("custAddr"); }
              set { SetString("custAddr",value); }
          }

          // 邮政编码
          public String custPost
          {
              get { return  GetString("custPost"); }
              set { SetString("custPost",value); }
          }

          // 联系电话
          public String custPhone
          {
              get { return  GetString("custPhone"); }
              set { SetString("custPhone",value); }
          }

          // 电子邮件
          public String custEmail
          {
              get { return  GetString("custEmail"); }
              set { SetString("custEmail",value); }
          }

          // 备注
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // 持卡人资料类型
          public string custRecTypeCode
          {
              get { return  Getstring("custRecTypeCode"); }
              set { Setstring("custRecTypeCode",value); }
          }

          // 月票类型
          public string appType
          {
              get { return  Getstring("appType"); }
              set { Setstring("appType",value); }
          }

          // 所属行政区域
          public string assignedArea
          {
              get { return  Getstring("assignedArea"); }
              set { Setstring("assignedArea",value); }
          }

          // 操作员卡
          public string currCardNo
          {
              get { return  Getstring("currCardNo"); }
              set { Setstring("currCardNo",value); }
          }

     }
}


