using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // ³äÖµ¿¨¼¤»î»ò¹Ø±Õ
     public class SP_CC_ActivatePDO : PDOBase
     {
          public SP_CC_ActivatePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_Activate",9);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@stateCode", "string", "1", "input");
               AddField("@remark", "String", "50", "input");

               InitEnd();
          }

          // ¿ªÊ¼¿¨ºÅ
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // ½áÊø¿¨ºÅ
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // ×´Ì¬±àÂë
          public string stateCode
          {
              get { return  Getstring("stateCode"); }
              set { Setstring("stateCode",value); }
          }

          // ±¸×¢
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

     }
}


