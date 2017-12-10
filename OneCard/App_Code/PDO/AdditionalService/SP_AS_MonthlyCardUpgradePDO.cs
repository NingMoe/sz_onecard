using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // 月票卡升级
     public class SP_AS_MonthlyCardUpgradePDO : PDOBase
     {
          public SP_AS_MonthlyCardUpgradePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_MonthlyCardUpgrade",25);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@deposit", "Int32", "", "input");
               AddField("@cardCost", "Int32", "", "input");
               AddField("@otherFee", "Int32", "", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@assignedArea", "string", "2", "input");
               AddField("@appType", "string", "2", "input");

               //UPDATE BY JINAGBB 2012-04-19 字段加密长度修改
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");

               AddField("@hidMonthlyYearCheck", "String", "50", "input");
               AddField("@hidMonthlyUpgrade", "String", "50", "input");
               AddField("@hidMonthlyFlag", "String", "50", "input");

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

          // 退押金
          public Int32 deposit
          {
              get { return  GetInt32("deposit"); }
              set { SetInt32("deposit",value); }
          }

          // 联机交易序号
          public Int32 cardCost
          {
              get { return  GetInt32("cardCost"); }
              set { SetInt32("cardCost",value); }
          }

          // 应用序列号
          public Int32 otherFee
          {
              get { return  GetInt32("otherFee"); }
              set { SetInt32("otherFee",value); }
          }

          // 卡片资料变更内容
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // asn
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // 操作员卡
          public string operCardNo
          {
              get { return  Getstring("operCardNo"); }
              set { Setstring("operCardNo",value); }
          }

          // 终端编码
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

          // 所属行政区域
          public string assignedArea
          {
              get { return  Getstring("assignedArea"); }
              set { Setstring("assignedArea",value); }
          }

          public string appType
          {
              get { return Getstring("appType"); }
              set { Setstring("appType", value); }
          }
        public string hidMonthlyFlag
        {
            get { return Getstring("hidMonthlyFlag"); }
            set { Setstring("hidMonthlyFlag", value); }
        }
        public string hidMonthlyUpgrade
        {
            get { return Getstring("hidMonthlyUpgrade"); }
            set { Setstring("hidMonthlyUpgrade", value); }
        }
        public string hidMonthlyYearCheck
        {
            get { return Getstring("hidMonthlyYearCheck"); }
            set { Setstring("hidMonthlyYearCheck", value); }
        }
    }
}


