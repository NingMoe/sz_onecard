using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // 查询
     public class SP_CC_Query_ChargeCardPDO : PDOBase
     {
          public SP_CC_Query_ChargeCardPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_Query_ChargeCard",7);

               AddField("@funcCode", "String", "16", "input");
               AddField("@var1", "String", "32", "input");
               AddField("@var2", "String", "16", "input");
               AddField("@var3", "String", "16", "input");
               AddField("@var4", "String", "16", "input");
               AddField("@cursor", "Cursor", "", "output");

          }

          // 功能编码
          public String funcCode
          {
              get { return  GetString("funcCode"); }
              set { SetString("funcCode",value); }
          }

          // 参数1
          public String var1
          {
              get { return  GetString("var1"); }
              set { SetString("var1",value); }
          }

          // 参数2
          public String var2
          {
              get { return  GetString("var2"); }
              set { SetString("var2",value); }
          }

          // 参数3
          public String var3
          {
              get { return  GetString("var3"); }
              set { SetString("var3",value); }
          }

          // 参数4
          public String var4
          {
              get { return  GetString("var4"); }
              set { SetString("var4",value); }
          }

     }
}


