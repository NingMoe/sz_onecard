using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 代理充值凭证明细表
     public class TF_SUPPLY_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_SUPPLY_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_SERIALNO_DETAIL";

               columns = new String[4][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"SUPPLYDATE", "string"};
               columns[2] = new String[]{"SUPPLYNO", "String"};
               columns[3] = new String[]{"SUPPLYFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[4];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("SUPPLYDATE", 1);
               hash.Add("SUPPLYNO", 2);
               hash.Add("SUPPLYFEE", 3);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 充值日期
          public string SUPPLYDATE
          {
              get { return  Getstring("SUPPLYDATE"); }
              set { Setstring("SUPPLYDATE",value); }
          }

          // 代理充值点
          public String SUPPLYNO
          {
              get { return  GetString("SUPPLYNO"); }
              set { SetString("SUPPLYNO",value); }
          }

          // 充值金额
          public Int32 SUPPLYFEE
          {
              get { return  GetInt32("SUPPLYFEE"); }
              set { SetInt32("SUPPLYFEE",value); }
          }

     }
}


