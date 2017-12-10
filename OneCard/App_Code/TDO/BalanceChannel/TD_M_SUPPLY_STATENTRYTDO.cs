using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 充值统计项定义表
     public class TD_M_SUPPLY_STATENTRYTDO : DDOBase
     {
          public TD_M_SUPPLY_STATENTRYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SUPPLY_STATENTRY";

               columns = new String[8][];
               columns[0] = new String[]{"ENTRYNO", "string"};
               columns[1] = new String[]{"ENTRYNAME", "String"};
               columns[2] = new String[]{"STATCOLUMN", "string"};
               columns[3] = new String[]{"BALUNITNO", "string"};
               columns[4] = new String[]{"WHERECLAUSE", "String"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ENTRYNO",
               };


               array = new String[8];
               hash.Add("ENTRYNO", 0);
               hash.Add("ENTRYNAME", 1);
               hash.Add("STATCOLUMN", 2);
               hash.Add("BALUNITNO", 3);
               hash.Add("WHERECLAUSE", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // 统计项编号
          public string ENTRYNO
          {
              get { return  Getstring("ENTRYNO"); }
              set { Setstring("ENTRYNO",value); }
          }

          // 统计项名称
          public String ENTRYNAME
          {
              get { return  GetString("ENTRYNAME"); }
              set { SetString("ENTRYNAME",value); }
          }

          // 统计字段
          public string STATCOLUMN
          {
              get { return  Getstring("STATCOLUMN"); }
              set { Setstring("STATCOLUMN",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 查询条件
          public String WHERECLAUSE
          {
              get { return  GetString("WHERECLAUSE"); }
              set { SetString("WHERECLAUSE",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


