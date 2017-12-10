using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 卡片的启用或者销毁
     public class SP_TS_CardStartOrDestoryPDO : PDOBase
     {
          public SP_TS_CardStartOrDestoryPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_TS_CardStartOrDestory",9);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CARDNO", "String", "16", "input");
               AddField("@strUseState", "string", "2", "input");
               AddField("@operCardNo", "String", "16", "input");

               InitEnd();
          }

          // 行业员工编码
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 员工卡号
          public String CARDNO
          {
              get { return  GetString("CARDNO"); }
              set { SetString("CARDNO",value); }
          }

          // 司机卡销毁或启用状态
          public string strUseState
          {
              get { return  Getstring("strUseState"); }
              set { Setstring("strUseState",value); }
          }

          // 操作员卡号
          public String operCardNo
          {
              get { return  GetString("operCardNo"); }
              set { SetString("operCardNo",value); }
          }

     }
}


