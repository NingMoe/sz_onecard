using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // 修改卡押金
     public class SP_UC_DepositChangePDO : PDOBase
     {
          public SP_UC_DepositChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_DepositChange",8);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@unitPrice", "Int32", "", "input");

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

          // 卡片单价
          public Int32 unitPrice
          {
              get { return  GetInt32("unitPrice"); }
              set { SetInt32("unitPrice",value); }
          }

     }
}


