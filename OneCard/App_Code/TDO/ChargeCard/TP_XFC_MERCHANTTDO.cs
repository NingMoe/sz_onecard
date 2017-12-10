using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // 充值卡代销点参数表
     public class TP_XFC_MERCHANTTDO : DDOBase
     {
          public TP_XFC_MERCHANTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_MERCHANT";

               columns = new String[5][];
               columns[0] = new String[]{"MERCHANTCODE", "string"};
               columns[1] = new String[]{"MERCHANT", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "MERCHANTCODE",
               };


               array = new String[5];
               hash.Add("MERCHANTCODE", 0);
               hash.Add("MERCHANT", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // 代销点代码
          public string MERCHANTCODE
          {
              get { return  Getstring("MERCHANTCODE"); }
              set { Setstring("MERCHANTCODE",value); }
          }

          // 代销点
          public String MERCHANT
          {
              get { return  GetString("MERCHANT"); }
              set { SetString("MERCHANT",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


