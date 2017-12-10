using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 出租车日报凭证明细表
     public class TF_TAXIOC_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TAXIOC_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TAXIOC_SERIALNO_DETAIL";

               columns = new String[5][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"FINTIME", "string"};
               columns[2] = new String[]{"BANKACCNO", "String"};
               columns[3] = new String[]{"TAXINAME", "String"};
               columns[4] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("FINTIME", 1);
               hash.Add("BANKACCNO", 2);
               hash.Add("TAXINAME", 3);
               hash.Add("TRANSFEE", 4);
          }

          // 财务凭证号
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // 转账时间
          public string FINTIME
          {
              get { return  Getstring("FINTIME"); }
              set { Setstring("FINTIME",value); }
          }

          // 银行帐号
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // 司机姓名
          public String TAXINAME
          {
              get { return  GetString("TAXINAME"); }
              set { SetString("TAXINAME",value); }
          }

          // 转账金额
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

     }
}


