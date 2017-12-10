using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 结算单元信息修改
     public class SP_PS_TransferChangeModifyPDO : PDOBase
     {
          public SP_PS_TransferChangeModifyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_TransferChangeModify",35);

               AddField("@balUnitNo", "string", "8", "input");
               AddField("@balUnit", "String", "100", "input");
               AddField("@balUnitTypeCode", "string", "2", "input");
               AddField("@sourceTypeCode", "string", "2", "input");
               AddField("@callingNo", "string", "2", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@departNo", "string", "4", "input");
               AddField("@bankCode", "string", "4", "input");
               AddField("@bankAccno", "String", "20", "input");
               AddField("@serManagerCode", "string", "6", "input");
               AddField("@balLevel", "string", "1", "input");
               AddField("@balCycleTypeCode", "string", "2", "input");
               AddField("@balInterval", "Int32", "", "input");
               AddField("@finCycleTypeCode", "string", "2", "input");
               AddField("@finInterval", "Int32", "", "input");
               AddField("@finTypeCode", "string", "1", "input");
               AddField("@comFeeTakeCode", "string", "1", "input");
               AddField("@finBankCode", "string", "4", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@unitPhone", "String", "20", "input");
               AddField("@unitAdd", "String", "50", "input");
               AddField("@unitEmail", "String", "200", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               AddField("@aprvState", "string", "1", "input");
               AddField("@seqNo", "string", "16", "input");

               AddField("@comSchemeNo", "string", "8", "input");
               AddField("@beginTime", "string", "20", "input");
               AddField("@endTime", "string", "20", "input");

               AddField("@keyInfoChanged", "string", "1", "input");

               //add by jiangbb 2012-05-18 新增收款人账户类型
               AddField("@purposeType", "string", "1", "input");
               AddField("@bankChannel", "string", "1", "input");

               AddField("@RegionCode", "string", "1", "input");
               AddField("@DeliveryModeCode", "string", "1", "input");
               AddField("@AppCallingCode", "string", "1", "input");
               InitEnd();
          }
          
          //收款人账户类型
          public string purposeType
          {
              get { return Getstring("purposeType"); }
              set { Setstring("purposeType", value); }
          }

         //银行渠道代码
          public string bankChannel
          {
              get { return Getstring("bankChannel"); }
              set { Setstring("bankChannel", value); }
          }

          // 关键信息是否被修改
          public string keyInfoChanged
          {
              get { return  Getstring("keyInfoChanged"); }
              set { Setstring("keyInfoChanged",value); }
          }
          
          // 结算单元编码
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // 结算单元名称
          public String balUnit
          {
              get { return  GetString("balUnit"); }
              set { SetString("balUnit",value); }
          }

          // 单元类型编码
          public string balUnitTypeCode
          {
              get { return  Getstring("balUnitTypeCode"); }
              set { Setstring("balUnitTypeCode",value); }
          }

          // 来源识别类型编码
          public string sourceTypeCode
          {
              get { return  Getstring("sourceTypeCode"); }
              set { Setstring("sourceTypeCode",value); }
          }

          // 行业编码
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // 单位编码
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // 部门编码
          public string departNo
          {
              get { return  Getstring("departNo"); }
              set { Setstring("departNo",value); }
          }

          // 开户银行编码
          public string bankCode
          {
              get { return  Getstring("bankCode"); }
              set { Setstring("bankCode",value); }
          }

          // 银行帐号
          public String bankAccno
          {
              get { return  GetString("bankAccno"); }
              set { SetString("bankAccno",value); }
          }

          // 商户经理编码
          public string serManagerCode
          {
              get { return  Getstring("serManagerCode"); }
              set { Setstring("serManagerCode",value); }
          }

          // 结算级别编码
          public string balLevel
          {
              get { return  Getstring("balLevel"); }
              set { Setstring("balLevel",value); }
          }

          // 结算周期类型编码
          public string balCycleTypeCode
          {
              get { return  Getstring("balCycleTypeCode"); }
              set { Setstring("balCycleTypeCode",value); }
          }

          // 结算周期跨度
          public Int32 balInterval
          {
              get { return  GetInt32("balInterval"); }
              set { SetInt32("balInterval",value); }
          }

          // 划账周期类型编码
          public string finCycleTypeCode
          {
              get { return  Getstring("finCycleTypeCode"); }
              set { Setstring("finCycleTypeCode",value); }
          }

          // 划账周期跨度
          public Int32 finInterval
          {
              get { return  GetInt32("finInterval"); }
              set { SetInt32("finInterval",value); }
          }

          // 转账类型
          public string finTypeCode
          {
              get { return  Getstring("finTypeCode"); }
              set { Setstring("finTypeCode",value); }
          }

          // 佣金扣减方式编码
          public string comFeeTakeCode
          {
              get { return  Getstring("comFeeTakeCode"); }
              set { Setstring("comFeeTakeCode",value); }
          }

          // 转出银行编码
          public string finBankCode
          {
              get { return  Getstring("finBankCode"); }
              set { Setstring("finBankCode",value); }
          }

          // 联系人
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // 联系电话
          public String unitPhone
          {
              get { return  GetString("unitPhone"); }
              set { SetString("unitPhone",value); }
          }

          // 联系地址
          public String unitAdd
          {
              get { return  GetString("unitAdd"); }
              set { SetString("unitAdd",value); }
          }

          // 电子邮件
          public String unitEmail
          {
              get { return GetString("unitEmail"); }
              set { SetString("unitEmail", value); }
          }

          // 备注
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // 有效标志
          public string useTag
          {
              get { return  Getstring("useTag"); }
              set { Setstring("useTag",value); }
          }

         public string aprvState
         {
             get { return Getstring("aprvState"); }
             set { Setstring("aprvState", value); }
         }
         public string seqNo
         {
             get { return Getstring("seqNo"); }
             set { Setstring("seqNo", value); }
         }

          // 佣金方案编码
          public string comSchemeNo
          {
              get { return Getstring("comSchemeNo"); }
              set { Setstring("comSchemeNo", value); }
          }

          // 佣金方案起始年月
          public string beginTime
          {
              get { return Getstring("beginTime"); }
              set { Setstring("beginTime", value); }
          }

          // 佣金方案终止年月
          public string endTime
          {
              get { return Getstring("endTime"); }
              set { Setstring("endTime", value); }
          }

          // 地区编码
          public string RegionCode
          {
              get { return Getstring("RegionCode"); }
              set { Setstring("RegionCode", value); }
          }

          // POS投放模式
          public string DeliveryModeCode
          {
              get { return Getstring("DeliveryModeCode"); }
              set { Setstring("DeliveryModeCode", value); }
          }

          // 应用行业
          public string AppCallingCode
          {
              get { return Getstring("AppCallingCode"); }
              set { Setstring("AppCallingCode", value); }
          }

     }
}


