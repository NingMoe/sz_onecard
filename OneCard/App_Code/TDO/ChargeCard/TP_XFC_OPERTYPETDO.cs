using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // 充值卡操作类型参数表
     public class TP_XFC_OPERTYPETDO : DDOBase
     {
          public TP_XFC_OPERTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_OPERTYPE";

               columns = new String[5][];
               columns[0] = new String[]{"OPERTYPECODE", "string"};
               columns[1] = new String[]{"OPERTYPE", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "OPERTYPECODE",
               };


               array = new String[5];
               hash.Add("OPERTYPECODE", 0);
               hash.Add("OPERTYPE", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // 操作类型编码
          public string OPERTYPECODE
          {
              get { return  Getstring("OPERTYPECODE"); }
              set { Setstring("OPERTYPECODE",value); }
          }

          // 操作类型
          public String OPERTYPE
          {
              get { return  GetString("OPERTYPE"); }
              set { SetString("OPERTYPE",value); }
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


