using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // 卡押金转卡费
     public class SP_GC_DepchgFeePDO : PDOBase
     {
          public SP_GC_DepchgFeePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_DepchgFee",9);

               AddField("@BeginCardNo", "string", "16", "input");
               AddField("@EndCardNo", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // 起始卡号
          public string BeginCardNo
          {
              get { return  Getstring("BeginCardNo"); }
              set { Setstring("BeginCardNo",value); }
          }

          // 终止卡号
          public string EndCardNo
          {
              get { return  Getstring("EndCardNo"); }
              set { Setstring("EndCardNo",value); }
          }

          // 业务类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 返回交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


