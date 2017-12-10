using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 财务凭证类别编码表
     public class TD_F_SERIALNOTYPETDO : DDOBase
     {
          public TD_F_SERIALNOTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_F_SERIALNOTYPE";

               columns = new String[2][];
               columns[0] = new String[]{"SERIALNOTYPE_NO", "string"};
               columns[1] = new String[]{"OPERATIONTYPE", "string"};

               columnKeys = new String[]{
                   "SERIALNOTYPE_NO",
               };


               array = new String[2];
               hash.Add("SERIALNOTYPE_NO", 0);
               hash.Add("OPERATIONTYPE", 1);
          }

          // 凭证类型编码
          public string SERIALNOTYPE_NO
          {
              get { return  Getstring("SERIALNOTYPE_NO"); }
              set { Setstring("SERIALNOTYPE_NO",value); }
          }

          // 操作类型名称
          public string OPERATIONTYPE
          {
              get { return  Getstring("OPERATIONTYPE"); }
              set { Setstring("OPERATIONTYPE",value); }
          }

     }
}


