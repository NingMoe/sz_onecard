using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // 卡入库
     public class SP_UC_StockInPDO : PDOBase
     {
          public SP_UC_StockInPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_StockIn",16);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@cosType", "string", "2", "input");
               AddField("@unitPrice", "Int32", "", "input");
               AddField("@faceType", "string", "4", "input");
               AddField("@cardType", "string", "2", "input");
               AddField("@chipType", "string", "2", "input");
               AddField("@producer", "string", "2", "input");
               AddField("@appVersion", "string", "2", "input");
               AddField("@effDate", "string", "8", "input");
               AddField("@expDate", "string", "8", "input");

               InitEnd();
          }

          // 开始卡号
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // 结束卡号
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // COS类型
          public string cosType
          {
              get { return  Getstring("cosType"); }
              set { Setstring("cosType",value); }
          }

          // 卡片单价
          public Int32 unitPrice
          {
              get { return  GetInt32("unitPrice"); }
              set { SetInt32("unitPrice",value); }
          }

          // 卡面编码
          public string faceType
          {
              get { return  Getstring("faceType"); }
              set { Setstring("faceType",value); }
          }

          // 卡片类型
          public string cardType
          {
              get { return  Getstring("cardType"); }
              set { Setstring("cardType",value); }
          }

          // 卡芯片编码
          public string chipType
          {
              get { return  Getstring("chipType"); }
              set { Setstring("chipType",value); }
          }

          // 卡片厂商
          public string producer
          {
              get { return  Getstring("producer"); }
              set { Setstring("producer",value); }
          }

          // 应用版本
          public string appVersion
          {
              get { return  Getstring("appVersion"); }
              set { Setstring("appVersion",value); }
          }

          // 起始有效期
          public string effDate
          {
              get { return  Getstring("effDate"); }
              set { Setstring("effDate",value); }
          }

          // 终止有效期
          public string expDate
          {
              get { return  Getstring("expDate"); }
              set { Setstring("expDate",value); }
          }

     }
}


