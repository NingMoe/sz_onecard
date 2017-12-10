using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 结算单元对应佣金规则关系增加
     public class SP_PS_BalUnitComSchemeAddPDO : PDOBase
     {
          public SP_PS_BalUnitComSchemeAddPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_BalUnitComSchemeAdd",9);

               AddField("@balUnitNo", "string", "8", "input");
               AddField("@comSchemeNo", "string", "8", "input");
               AddField("@beginTime", "string", "20", "input");
               AddField("@endTime", "string", "20", "input");

               InitEnd();
          }

          // 结算单元编码
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // 佣金方案编码
          public string comSchemeNo
          {
              get { return  Getstring("comSchemeNo"); }
              set { Setstring("comSchemeNo",value); }
          }

          // 佣金方案起始年月
          public string beginTime
          {
              get { return  Getstring("beginTime"); }
              set { Setstring("beginTime",value); }
          }

          // 佣金方案终止年月
          public string endTime
          {
              get { return  Getstring("endTime"); }
              set { Setstring("endTime",value); }
          }

     }
}


