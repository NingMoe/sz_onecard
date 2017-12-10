using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 商户转帐清算凭证明细表
     public class TF_TRADELQ_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TRADELQ_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADELQ_SERIALNO_DETAIL";

               columns = new String[4][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"BALUNIT", "String"};
               columns[2] = new String[]{"FINDATE", "string"};
               columns[3] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[4];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("BALUNIT", 1);
               hash.Add("FINDATE", 2);
               hash.Add("TRANSFEE", 3);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 商户名称
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // 转账日期
          public string FINDATE
          {
              get { return  Getstring("FINDATE"); }
              set { Setstring("FINDATE",value); }
          }

          // 转账金额
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

     }
}


