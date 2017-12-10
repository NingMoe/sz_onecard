using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 司机信息录入
     public class SP_Bus_InputPDO : PDOBase
     {
          public SP_Bus_InputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_Bus_Input",12);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CALLINGNO", "string", "2", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DEPARTNO", "string", "4", "input");
               AddField("@BANKCODE", "string", "4", "input");
               AddField("@BANKACCNO", "String", "20", "input");
               AddField("@SERMANAGERCODE", "string", "6", "input");

               InitEnd();
          }

          // 司机工号
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 单位编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 开户银行编码
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // 银行帐号
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // 商户经理编码
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

     }
}


