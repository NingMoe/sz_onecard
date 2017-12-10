using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // 司机信息变更
     public class SP_Bus_ChangeInfoPDO : PDOBase
     {
          public SP_Bus_ChangeInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_Bus_ChangeInfo",19);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CARDNO", "String", "16", "input");
               AddField("@CARNO", "string", "8", "input");
               AddField("@STAFFNAME", "String", "20", "input");
               AddField("@STAFFSEX", "string", "1", "input");
               AddField("@STAFFPHONE", "String", "20", "input");
               AddField("@STAFFMOBILE", "String", "15", "input");
               AddField("@STAFFPAPERTYPECODE", "string", "2", "input");
               AddField("@STAFFPAPERNO", "String", "20", "input");
               AddField("@STAFFPOST", "String", "6", "input");
               AddField("@STAFFADDR", "String", "50", "input");
               AddField("@STAFFEMAIL", "String", "30", "input");
               AddField("@POSID", "string", "8", "input");
               AddField("@DIMISSIONTAG", "string", "1", "input");

               InitEnd();
          }

          // 行业员工编码
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 员工卡号
          public String CARDNO
          {
              get { return  GetString("CARDNO"); }
              set { SetString("CARDNO",value); }
          }

          // 车号
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // 员工姓名
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // 员工性别
          public string STAFFSEX
          {
              get { return  Getstring("STAFFSEX"); }
              set { Setstring("STAFFSEX",value); }
          }

          // 员工联系电话
          public String STAFFPHONE
          {
              get { return  GetString("STAFFPHONE"); }
              set { SetString("STAFFPHONE",value); }
          }

          // 员工移动电话
          public String STAFFMOBILE
          {
              get { return  GetString("STAFFMOBILE"); }
              set { SetString("STAFFMOBILE",value); }
          }

          // 员工证件类型
          public string STAFFPAPERTYPECODE
          {
              get { return  Getstring("STAFFPAPERTYPECODE"); }
              set { Setstring("STAFFPAPERTYPECODE",value); }
          }

          // 员工证件号码
          public String STAFFPAPERNO
          {
              get { return  GetString("STAFFPAPERNO"); }
              set { SetString("STAFFPAPERNO",value); }
          }

          // 邮编地址
          public String STAFFPOST
          {
              get { return  GetString("STAFFPOST"); }
              set { SetString("STAFFPOST",value); }
          }

          // 员工联系地址
          public String STAFFADDR
          {
              get { return  GetString("STAFFADDR"); }
              set { SetString("STAFFADDR",value); }
          }

          // EMAIL地址
          public String STAFFEMAIL
          {
              get { return  GetString("STAFFEMAIL"); }
              set { SetString("STAFFEMAIL",value); }
          }

          // POSID
          public string POSID
          {
              get { return  Getstring("POSID"); }
              set { Setstring("POSID",value); }
          }

          // 离职标志
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
          }

     }
}


