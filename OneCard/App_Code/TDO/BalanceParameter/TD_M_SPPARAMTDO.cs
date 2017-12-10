using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 日结月结存储过程参数配置表
     public class TD_M_SPPARAMTDO : DDOBase
     {
          public TD_M_SPPARAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SPPARAM";

               columns = new String[8][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"NAME", "String"};
               columns[2] = new String[]{"SPID", "string"};
               columns[3] = new String[]{"VALUE", "String"};
               columns[4] = new String[]{"NOINSP", "Int32"};
               columns[5] = new String[]{"DATATYPE", "Int32"};
               columns[6] = new String[]{"USETAG", "string"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[8];
               hash.Add("ID", 0);
               hash.Add("NAME", 1);
               hash.Add("SPID", 2);
               hash.Add("VALUE", 3);
               hash.Add("NOINSP", 4);
               hash.Add("DATATYPE", 5);
               hash.Add("USETAG", 6);
               hash.Add("REMARK", 7);
          }

          // 参数编号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 参数名称
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // 存储过程编号
          public string SPID
          {
              get { return  Getstring("SPID"); }
              set { Setstring("SPID",value); }
          }

          // 参数值
          public String VALUE
          {
              get { return  GetString("VALUE"); }
              set { SetString("VALUE",value); }
          }

          // 参数序号
          public Int32 NOINSP
          {
              get { return  GetInt32("NOINSP"); }
              set { SetInt32("NOINSP",value); }
          }

          // 数据类型
          public Int32 DATATYPE
          {
              get { return  GetInt32("DATATYPE"); }
              set { SetInt32("DATATYPE",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


