using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // 休闲年卡补换卡
     public class SP_AS_RelaxCardChangePDO : PDOBase
     {
          public SP_AS_RelaxCardChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_RelaxCardChange",22);

               AddField("@ID", "string", "18", "input");
               AddField("@oldCardNo", "string", "16", "input");
               AddField("@newCardNo", "string", "16", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@endDateNum", "string", "12", "input");
               AddField("@packageTypeCode", "string", "02", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@passPaperNo", "String", "20", "input");
               AddField("@passCustName", "String", "200", "input");
               AddField("@serviceFor", "String", "1", "input");
               AddField("@cityCode", "String", "4", "input");

               //UPDATE BY JINAGBB 2012-04-19 字段加密长度修改
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

               InitEnd();
          }
          // 明文证件号码
          public string passPaperNo
          {
              get { return Getstring("passPaperNo"); }
              set { Setstring("passPaperNo", value); }
          }
          // 明文姓名
          public string passCustName
          {
              get { return Getstring("passCustName"); }
              set { Setstring("passCustName", value); }
          }
          // 是否同步休闲标识位
          public string serviceFor
          {
              get { return Getstring("serviceFor"); }
              set { Setstring("serviceFor", value); }
          }
          // 城市代码
          public string cityCode
          {
              get { return Getstring("cityCode"); }
              set { Setstring("cityCode", value); }
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 旧卡卡号
          public string oldCardNo
          {
              get { return  Getstring("oldCardNo"); }
              set { Setstring("oldCardNo",value); }
          }

          // 新卡卡号
          public string newCardNo
          {
              get { return  Getstring("newCardNo"); }
              set { Setstring("newCardNo",value); }
          }

          // 应用序列号
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // 操作员卡号
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

          // 卡片资料变更内容
          public string endDateNum
          {
              get { return  Getstring("endDateNum"); }
              set { Setstring("endDateNum",value); }
          }

          // 套餐类型
          public string packageTypeCode
          {
              get { return Getstring("packageTypeCode"); }
              set { Setstring("packageTypeCode", value); }
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

     }
}


