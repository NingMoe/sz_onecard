using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 读取卡内记录
     public class SP_PB_ReadRecordPDO : PDOBase
     {
          public SP_PB_ReadRecordPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ReadRecord",8);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@SESSIONID", "String", "32", "input");
               AddField("@CARDMONEY", "Int32", "", "input");

               InitEnd();
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 会话ID
          public String SESSIONID
          {
              get { return  GetString("SESSIONID"); }
              set { SetString("SESSIONID",value); }
          }

          // 卡内余额
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

     }
}


