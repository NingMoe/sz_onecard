using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 售充代理点编码规则表
     public class TD_M_SELSUP_LOCRULETDO : DDOBase
     {
          public TD_M_SELSUP_LOCRULETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SELSUP_LOCRULE";

               columns = new String[8][];
               columns[0] = new String[]{"RULENO", "string"};
               columns[1] = new String[]{"RULETYPE", "string"};
               columns[2] = new String[]{"RULEEXP", "String"};
               columns[3] = new String[]{"BALUNITNO", "string"};
               columns[4] = new String[]{"CALLINGNO", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "RULENO",
               };


               array = new String[8];
               hash.Add("RULENO", 0);
               hash.Add("RULETYPE", 1);
               hash.Add("RULEEXP", 2);
               hash.Add("BALUNITNO", 3);
               hash.Add("CALLINGNO", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // 规则编号
          public string RULENO
          {
              get { return  Getstring("RULENO"); }
              set { Setstring("RULENO",value); }
          }

          // 规则类型
          public string RULETYPE
          {
              get { return  Getstring("RULETYPE"); }
              set { Setstring("RULETYPE",value); }
          }

          // 规则表达式
          public String RULEEXP
          {
              get { return  GetString("RULEEXP"); }
              set { SetString("RULEEXP",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
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


