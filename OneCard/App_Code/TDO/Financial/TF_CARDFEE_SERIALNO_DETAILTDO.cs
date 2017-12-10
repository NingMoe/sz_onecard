using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 卡费凭证明细表
     public class TF_CARDFEE_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_CARDFEE_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARDFEE_SERIALNO_DETAIL";

               columns = new String[4][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"FEETYPE", "String"};
               columns[2] = new String[]{"TIMES", "Int32"};
               columns[3] = new String[]{"FEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[4];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("FEETYPE", 1);
               hash.Add("TIMES", 2);
               hash.Add("FEE", 3);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 费用类型
          public String FEETYPE
          {
              get { return  GetString("FEETYPE"); }
              set { SetString("FEETYPE",value); }
          }

          // 笔数
          public Int32 TIMES
          {
              get { return  GetInt32("TIMES"); }
              set { SetInt32("TIMES",value); }
          }

          // 金额
          public Int32 FEE
          {
              get { return  GetInt32("FEE"); }
              set { SetInt32("FEE",value); }
          }

     }
}


