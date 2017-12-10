using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 财务操作类型编码表
     public class TD_F_OPERATIONTYPETDO : DDOBase
     {
          public TD_F_OPERATIONTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_F_OPERATIONTYPE";

               columns = new String[2][];
               columns[0] = new String[]{"OPERATIONTYPE_NO", "string"};
               columns[1] = new String[]{"OPERATIONTYPE", "string"};

               columnKeys = new String[]{
                   "OPERATIONTYPE_NO",
               };


               array = new String[2];
               hash.Add("OPERATIONTYPE_NO", 0);
               hash.Add("OPERATIONTYPE", 1);
          }

          // 操作类型编码
          public string OPERATIONTYPE_NO
          {
              get { return  Getstring("OPERATIONTYPE_NO"); }
              set { Setstring("OPERATIONTYPE_NO",value); }
          }

          // 操作类型名称
          public string OPERATIONTYPE
          {
              get { return  Getstring("OPERATIONTYPE"); }
              set { Setstring("OPERATIONTYPE",value); }
          }

     }
}


