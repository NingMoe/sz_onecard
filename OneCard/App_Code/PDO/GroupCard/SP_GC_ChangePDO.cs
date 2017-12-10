using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 企服卡换卡
     public class SP_GC_ChangePDO : PDOBase
     {
          public SP_GC_ChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_Change",18);

               AddField("@oldCardNo", "String", "16", "input");
               AddField("@newCardNo", "String", "16", "input");

               AddField("@replaceInfo", "String", "1", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");

               //UPDATE BY JINAGBB 2012-04-19 字段加密长度修改
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

               InitEnd();
          }

          // 老卡号
         public String oldCardNo
          {
              get { return GetString("oldCardNo"); }
              set { SetString("oldCardNo", value); }
          }

         public String replaceInfo
          {
              get { return GetString("replaceInfo"); }
              set { SetString("replaceInfo", value); }
          }

          // 新卡号
          public String newCardNo
          {
              get { return  GetString("newCardNo"); }
              set { SetString("newCardNo",value); }
          }
          // 姓名
          public String custName
          {
              get { return GetString("custName"); }
              set { SetString("custName", value); }
          }

          // 性别
          public String custSex
          {
              get { return GetString("custSex"); }
              set { SetString("custSex", value); }
          }

          // 出生日期
          public String custBirth
          {
              get { return GetString("custBirth"); }
              set { SetString("custBirth", value); }
          }

          // 证件类型编码
          public String paperType
          {
              get { return GetString("paperType"); }
              set { SetString("paperType", value); }
          }

          // 证件号码
          public String paperNo
          {
              get { return GetString("paperNo"); }
              set { SetString("paperNo", value); }
          }

          // 联系地址
          public String custAddr
          {
              get { return GetString("custAddr"); }
              set { SetString("custAddr", value); }
          }

          // 邮政编码
          public String custPost
          {
              get { return GetString("custPost"); }
              set { SetString("custPost", value); }
          }

          // 联系电话
          public String custPhone
          {
              get { return GetString("custPhone"); }
              set { SetString("custPhone", value); }
          }

          // 电子邮件
          public String custEmail
          {
              get { return GetString("custEmail"); }
              set { SetString("custEmail", value); }
          }

          // 备注
          public String remark
          {
              get { return GetString("remark"); }
              set { SetString("remark", value); }
          }

     }
}


