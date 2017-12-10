using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 商户转帐凭证明细表
     public class TF_TRADEOC_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TRADEOC_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADEOC_SERIALNO_DETAIL";

               columns = new String[5][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"BANK", "String"};
               columns[2] = new String[]{"FINANCENO", "string"};
               columns[3] = new String[]{"BALUNIT", "String"};
               columns[4] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("BANK", 1);
               hash.Add("FINANCENO", 2);
               hash.Add("BALUNIT", 3);
               hash.Add("TRANSFEE", 4);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 转出行
          public String BANK
          {
              get { return  GetString("BANK"); }
              set { SetString("BANK",value); }
          }

          // 商户代码
          public string FINANCENO
          {
              get { return  Getstring("FINANCENO"); }
              set { Setstring("FINANCENO",value); }
          }

          // 商户名称
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // 转账金额
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

     }
}


