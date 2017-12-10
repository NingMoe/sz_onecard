using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // 苏州园林年卡账户表
     public class TB_F_CARDPARKACC_SZTDO : DDOBase
     {
          public TB_F_CARDPARKACC_SZTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TB_F_CARDPARKACC_SZ";

               columns = new String[16][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REUSEDATE", "DateTime"};
               columns[2] = new String[]{"CURRENTOPENYEAR", "string"};
               columns[3] = new String[]{"CARDTIMES", "Int32"};
               columns[4] = new String[]{"ENDDATE", "string"};
               columns[5] = new String[]{"CURRENTPAYTIME", "DateTime"};
               columns[6] = new String[]{"CURRENTPAYFEE", "Int32"};
               columns[7] = new String[]{"TOTALTIMES", "Int32"};
               columns[8] = new String[]{"SPARETIMES", "Int32"};
               columns[9] = new String[]{"USETAG", "string"};
               columns[10] = new String[]{"UPDATESTAFFNO", "string"};
               columns[11] = new String[]{"UPDATETIME", "DateTime"};
               columns[12] = new String[]{"RERVINT", "Int32"};
               columns[13] = new String[]{"RERVCHAR", "String"};
               columns[14] = new String[]{"RERVSTRING", "DateTime"};
               columns[15] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[16];
               hash.Add("CARDNO", 0);
               hash.Add("REUSEDATE", 1);
               hash.Add("CURRENTOPENYEAR", 2);
               hash.Add("CARDTIMES", 3);
               hash.Add("ENDDATE", 4);
               hash.Add("CURRENTPAYTIME", 5);
               hash.Add("CURRENTPAYFEE", 6);
               hash.Add("TOTALTIMES", 7);
               hash.Add("SPARETIMES", 8);
               hash.Add("USETAG", 9);
               hash.Add("UPDATESTAFFNO", 10);
               hash.Add("UPDATETIME", 11);
               hash.Add("RERVINT", 12);
               hash.Add("RERVCHAR", 13);
               hash.Add("RERVSTRING", 14);
               hash.Add("REMARK", 15);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 回收日期
          public DateTime REUSEDATE
          {
              get { return  GetDateTime("REUSEDATE"); }
              set { SetDateTime("REUSEDATE",value); }
          }

          // 当前开通年份
          public string CURRENTOPENYEAR
          {
              get { return  Getstring("CURRENTOPENYEAR"); }
              set { Setstring("CURRENTOPENYEAR",value); }
          }

          // 开卡次数
          public Int32 CARDTIMES
          {
              get { return  GetInt32("CARDTIMES"); }
              set { SetInt32("CARDTIMES",value); }
          }

          // 当年截至日期
          public string ENDDATE
          {
              get { return  Getstring("ENDDATE"); }
              set { Setstring("ENDDATE",value); }
          }

          // 当年缴费时间
          public DateTime CURRENTPAYTIME
          {
              get { return  GetDateTime("CURRENTPAYTIME"); }
              set { SetDateTime("CURRENTPAYTIME",value); }
          }

          // 当年缴费金额
          public Int32 CURRENTPAYFEE
          {
              get { return  GetInt32("CURRENTPAYFEE"); }
              set { SetInt32("CURRENTPAYFEE",value); }
          }

          // 当年总可用次数
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // 当年剩余可用次数
          public Int32 SPARETIMES
          {
              get { return  GetInt32("SPARETIMES"); }
              set { SetInt32("SPARETIMES",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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

          // 备用1
          public Int32 RERVINT
          {
              get { return  GetInt32("RERVINT"); }
              set { SetInt32("RERVINT",value); }
          }

          // 备用2
          public String RERVCHAR
          {
              get { return  GetString("RERVCHAR"); }
              set { SetString("RERVCHAR",value); }
          }

          // 备用3
          public DateTime RERVSTRING
          {
              get { return  GetDateTime("RERVSTRING"); }
              set { SetDateTime("RERVSTRING",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


