using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // 充值异常信息回收
     public class SP_SD_SupplyErrRecPDO : PDOBase
     {
          public SP_SD_SupplyErrRecPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SupplyErrRec",8);

               AddField("@renewRemark", "String", "150", "input");
               AddField("@billMonth", "string", "2", "input");
               AddField("@sessionID", "String", "32", "input");

               InitEnd();
          }

          // 回收说明
          public String renewRemark
          {
              get { return  GetString("renewRemark"); }
              set { SetString("renewRemark",value); }
          }

          // 回收清单月份
          public string billMonth
          {
              get { return  Getstring("billMonth"); }
              set { Setstring("billMonth",value); }
          }

          // 会话ID
          public String sessionID
          {
              get { return  GetString("sessionID"); }
              set { SetString("sessionID",value); }
          }

     }
}


