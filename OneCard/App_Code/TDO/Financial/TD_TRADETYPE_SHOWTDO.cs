using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // 业务类型展示编码表
     public class TD_TRADETYPE_SHOWTDO : DDOBase
     {
          public TD_TRADETYPE_SHOWTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_TRADETYPE_SHOW";

               columns = new String[4][];
               columns[0] = new String[]{"SHOWNO", "string"};
               columns[1] = new String[]{"SHOWNAME", "String"};
               columns[2] = new String[]{"TRADETYPENO", "string"};
               columns[3] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "SHOWNO",
                   "TRADETYPENO",
               };


               array = new String[4];
               hash.Add("SHOWNO", 0);
               hash.Add("SHOWNAME", 1);
               hash.Add("TRADETYPENO", 2);
               hash.Add("REMARK", 3);
          }

          // 展示编码
          public string SHOWNO
          {
              get { return  Getstring("SHOWNO"); }
              set { Setstring("SHOWNO",value); }
          }

          // 展示名称
          public String SHOWNAME
          {
              get { return  GetString("SHOWNAME"); }
              set { SetString("SHOWNAME",value); }
          }

          // 业务编号
          public string TRADETYPENO
          {
              get { return  Getstring("TRADETYPENO"); }
              set { Setstring("TRADETYPENO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


