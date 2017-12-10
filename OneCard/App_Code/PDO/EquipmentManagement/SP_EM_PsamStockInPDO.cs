using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // PSAM入库
     public class SP_EM_PsamStockInPDO : PDOBase
     {
          public SP_EM_PsamStockInPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_EM_PsamStockIn",17);

               AddField("@prefix", "string", "2", "input");
               AddField("@firstNo", "Decimal", "", "input");
               AddField("@amount", "Int32", "", "input");
               AddField("@length", "Int32", "", "input");
               AddField("@cardKind", "string", "2", "input");
               AddField("@cosType", "string", "2", "input");
               AddField("@appVersion", "string", "2", "input");
               AddField("@cardType", "string", "2", "input");
               AddField("@cardPrice", "Int32", "", "input");
               AddField("@cardManu", "string", "2", "input");
               AddField("@validBeginDate", "string", "8", "input");
               AddField("@validEndDate", "string", "8", "input");

               InitEnd();
          }

          // 卡号前缀
          public string prefix
          {
              get { return  Getstring("prefix"); }
              set { Setstring("prefix",value); }
          }

          // 起始卡号
          public Decimal firstNo
          {
              get { return  GetDecimal("firstNo"); }
              set { SetDecimal("firstNo",value); }
          }

          // 卡数量
          public Int32 amount
          {
              get { return  GetInt32("amount"); }
              set { SetInt32("amount",value); }
          }

          // 卡号长度
          public Int32 length
          {
              get { return  GetInt32("length"); }
              set { SetInt32("length",value); }
          }

          // 卡片类别
          public string cardKind
          {
              get { return  Getstring("cardKind"); }
              set { Setstring("cardKind",value); }
          }

          // COS类型
          public string cosType
          {
              get { return  Getstring("cosType"); }
              set { Setstring("cosType",value); }
          }

          // 应用版本
          public string appVersion
          {
              get { return  Getstring("appVersion"); }
              set { Setstring("appVersion",value); }
          }

          // 卡类型
          public string cardType
          {
              get { return  Getstring("cardType"); }
              set { Setstring("cardType",value); }
          }

          // 单价
          public Int32 cardPrice
          {
              get { return  GetInt32("cardPrice"); }
              set { SetInt32("cardPrice",value); }
          }

          // 卡片厂商
          public string cardManu
          {
              get { return  Getstring("cardManu"); }
              set { Setstring("cardManu",value); }
          }

          // 起始有效期
          public string validBeginDate
          {
              get { return  Getstring("validBeginDate"); }
              set { Setstring("validBeginDate",value); }
          }

          // 终止有效期
          public string validEndDate
          {
              get { return  Getstring("validEndDate"); }
              set { Setstring("validEndDate",value); }
          }

     }
}


