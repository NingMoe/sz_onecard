using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 卡片信息修改
     public class SP_TS_ChangeCardInfoPDO : PDOBase
     {
          public SP_TS_ChangeCardInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_TS_ChangeCardInfo",10);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CARDNO", "String", "16", "input");
               AddField("@CARNO", "string", "8", "input");
               AddField("@strState", "string", "2", "input");
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

          // 车号
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // 司机卡初始状态
          public string strState
          {
              get { return  Getstring("strState"); }
              set { Setstring("strState",value); }
          }

          // 操作员卡号
          public String operCardNo
          {
              get { return  GetString("operCardNo"); }
              set { SetString("operCardNo",value); }
          }

     }
}


