using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC卡月票计次账户备份表
     public class TB_F_CARDCOUNTACCTDO : DDOBase
     {
          public TB_F_CARDCOUNTACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TB_F_CARDCOUNTACC";

               columns = new String[20][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REUSEDATE", "DateTime"};
               columns[2] = new String[]{"APPTYPE", "string"};
               columns[3] = new String[]{"ASSIGNEDAREA", "string"};
               columns[4] = new String[]{"APPTIME", "DateTime"};
               columns[5] = new String[]{"APPSTAFFNO", "string"};
               columns[6] = new String[]{"LASTAUDIT", "string"};
               columns[7] = new String[]{"LASTAUDITTIME", "DateTime"};
               columns[8] = new String[]{"LASTAUDITSTAFFNO", "string"};
               columns[9] = new String[]{"USETAG", "string"};
               columns[10] = new String[]{"ENDTIME", "string"};
               columns[11] = new String[]{"TOTALTIMES", "Int32"};
               columns[12] = new String[]{"SPARETIMES", "Int32"};
               columns[13] = new String[]{"TOTALCOUNT", "Int32"};
               columns[14] = new String[]{"UPDATESTAFFNO", "string"};
               columns[15] = new String[]{"UPDATETIME", "DateTime"};
               columns[16] = new String[]{"RSRV1", "String"};
               columns[17] = new String[]{"RSRV2", "String"};
               columns[18] = new String[]{"RSRV3", "DateTime"};
               columns[19] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "REUSEDATE",
               };


               array = new String[20];
               hash.Add("CARDNO", 0);
               hash.Add("REUSEDATE", 1);
               hash.Add("APPTYPE", 2);
               hash.Add("ASSIGNEDAREA", 3);
               hash.Add("APPTIME", 4);
               hash.Add("APPSTAFFNO", 5);
               hash.Add("LASTAUDIT", 6);
               hash.Add("LASTAUDITTIME", 7);
               hash.Add("LASTAUDITSTAFFNO", 8);
               hash.Add("USETAG", 9);
               hash.Add("ENDTIME", 10);
               hash.Add("TOTALTIMES", 11);
               hash.Add("SPARETIMES", 12);
               hash.Add("TOTALCOUNT", 13);
               hash.Add("UPDATESTAFFNO", 14);
               hash.Add("UPDATETIME", 15);
               hash.Add("RSRV1", 16);
               hash.Add("RSRV2", 17);
               hash.Add("RSRV3", 18);
               hash.Add("REMARK", 19);
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

          // 月票类型
          public string APPTYPE
          {
              get { return  Getstring("APPTYPE"); }
              set { Setstring("APPTYPE",value); }
          }

          // 所属区域
          public string ASSIGNEDAREA
          {
              get { return  Getstring("ASSIGNEDAREA"); }
              set { Setstring("ASSIGNEDAREA",value); }
          }

          // 开月票时间
          public DateTime APPTIME
          {
              get { return  GetDateTime("APPTIME"); }
              set { SetDateTime("APPTIME",value); }
          }

          // 开月票员工
          public string APPSTAFFNO
          {
              get { return  Getstring("APPSTAFFNO"); }
              set { Setstring("APPSTAFFNO",value); }
          }

          // 年检标志
          public string LASTAUDIT
          {
              get { return  Getstring("LASTAUDIT"); }
              set { Setstring("LASTAUDIT",value); }
          }

          // 年检时间
          public DateTime LASTAUDITTIME
          {
              get { return  GetDateTime("LASTAUDITTIME"); }
              set { SetDateTime("LASTAUDITTIME",value); }
          }

          // 年检员工
          public string LASTAUDITSTAFFNO
          {
              get { return  Getstring("LASTAUDITSTAFFNO"); }
              set { Setstring("LASTAUDITSTAFFNO",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 截至日期
          public string ENDTIME
          {
              get { return  Getstring("ENDTIME"); }
              set { Setstring("ENDTIME",value); }
          }

          // 总可用次数
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // 剩余可用次数
          public Int32 SPARETIMES
          {
              get { return  GetInt32("SPARETIMES"); }
              set { SetInt32("SPARETIMES",value); }
          }

          // 累计次数
          public Int32 TOTALCOUNT
          {
              get { return  GetInt32("TOTALCOUNT"); }
              set { SetInt32("TOTALCOUNT",value); }
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
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // 备用2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // 备用3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


