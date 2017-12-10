using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // 取消批量分配
     public class SP_UC_BatchUnDistributionPDO : PDOBase
     {
          public SP_UC_BatchUnDistributionPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_BatchUnDistribution",7);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");

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

     }
}


