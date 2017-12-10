using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 操作员退款凭证明细表
     public class TF_REFUND_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_REFUND_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_REFUND_SERIALNO_DETAIL";

               columns = new String[5][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"REFUNDDATE", "string"};
               columns[2] = new String[]{"STAFFNAME", "String"};
               columns[3] = new String[]{"FEETYPENAME", "String"};
               columns[4] = new String[]{"SERVICEFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("REFUNDDATE", 1);
               hash.Add("STAFFNAME", 2);
               hash.Add("FEETYPENAME", 3);
               hash.Add("SERVICEFEE", 4);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 退款日期
          public string REFUNDDATE
          {
              get { return  Getstring("REFUNDDATE"); }
              set { Setstring("REFUNDDATE",value); }
          }

          // 操作员
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // 退款费用类型
          public String FEETYPENAME
          {
              get { return  GetString("FEETYPENAME"); }
              set { SetString("FEETYPENAME",value); }
          }

          // 退款金额
          public Int32 SERVICEFEE
          {
              get { return  GetInt32("SERVICEFEE"); }
              set { SetInt32("SERVICEFEE",value); }
          }

     }
}


