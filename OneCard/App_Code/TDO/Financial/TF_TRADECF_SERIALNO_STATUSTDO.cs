using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 商户佣金凭证审核状态表
     public class TF_TRADECF_SERIALNO_STATUSTDO : DDOBase
     {
          public TF_TRADECF_SERIALNO_STATUSTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADECF_SERIALNO_STATUS";

               columns = new String[2][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"DEALSTATECODE", "string"};

               columnKeys = new String[]{
                   "FIANCE_SERIALNO",
               };


               array = new String[2];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("DEALSTATECODE", 1);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 处理状态码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

     }
}


