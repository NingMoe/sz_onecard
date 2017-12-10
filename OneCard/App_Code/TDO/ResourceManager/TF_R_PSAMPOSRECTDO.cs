using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS机SAM卡对应关系表
     public class TF_R_PSAMPOSRECTDO : DDOBase
     {
          public TF_R_PSAMPOSRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_R_PSAMPOSREC";

               columns = new String[18][];
               columns[0] = new String[]{"SAMNO", "string"};
               columns[1] = new String[]{"POSNO", "string"};
               columns[2] = new String[]{"BALUNITNO", "string"};
               columns[3] = new String[]{"USETYPECODE", "string"};
               columns[4] = new String[]{"CALLINGNO", "string"};
               columns[5] = new String[]{"CORPNO", "string"};
               columns[6] = new String[]{"DEPARTNO", "string"};
               columns[7] = new String[]{"SERMANAGERCODE", "string"};
               columns[8] = new String[]{"TAKETIME", "DateTime"};
               columns[9] = new String[]{"POSDEPOSIT", "Int32"};
               columns[10] = new String[]{"DEPREBEGINTIME", "DateTime"};
               columns[11] = new String[]{"DEPREMONTHS", "Int32"};
               columns[12] = new String[]{"SAMDEPOSIT", "Int32"};
               columns[13] = new String[]{"VALIDBEGINDATE", "string"};
               columns[14] = new String[]{"VALIDENDDATE", "string"};
               columns[15] = new String[]{"UPDATESTAFFNO", "string"};
               columns[16] = new String[]{"UPDATETIME", "DateTime"};
               columns[17] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "SAMNO",
               };


               array = new String[18];
               hash.Add("SAMNO", 0);
               hash.Add("POSNO", 1);
               hash.Add("BALUNITNO", 2);
               hash.Add("USETYPECODE", 3);
               hash.Add("CALLINGNO", 4);
               hash.Add("CORPNO", 5);
               hash.Add("DEPARTNO", 6);
               hash.Add("SERMANAGERCODE", 7);
               hash.Add("TAKETIME", 8);
               hash.Add("POSDEPOSIT", 9);
               hash.Add("DEPREBEGINTIME", 10);
               hash.Add("DEPREMONTHS", 11);
               hash.Add("SAMDEPOSIT", 12);
               hash.Add("VALIDBEGINDATE", 13);
               hash.Add("VALIDENDDATE", 14);
               hash.Add("UPDATESTAFFNO", 15);
               hash.Add("UPDATETIME", 16);
               hash.Add("REMARK", 17);
          }

          // SAM编号
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // POS编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // POS来源
          public string USETYPECODE
          {
              get { return  Getstring("USETYPECODE"); }
              set { Setstring("USETYPECODE",value); }
          }

          // 行业编码
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // 单位编码
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // 部门编码
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // 商户经理编码
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // 领用日期
          public DateTime TAKETIME
          {
              get { return  GetDateTime("TAKETIME"); }
              set { SetDateTime("TAKETIME",value); }
          }

          // POS押金
          public Int32 POSDEPOSIT
          {
              get { return  GetInt32("POSDEPOSIT"); }
              set { SetInt32("POSDEPOSIT",value); }
          }

          // 开始折旧时间
          public DateTime DEPREBEGINTIME
          {
              get { return  GetDateTime("DEPREBEGINTIME"); }
              set { SetDateTime("DEPREBEGINTIME",value); }
          }

          // 折旧时限
          public Int32 DEPREMONTHS
          {
              get { return  GetInt32("DEPREMONTHS"); }
              set { SetInt32("DEPREMONTHS",value); }
          }

          // SAM押金
          public Int32 SAMDEPOSIT
          {
              get { return  GetInt32("SAMDEPOSIT"); }
              set { SetInt32("SAMDEPOSIT",value); }
          }

          // 起始有效期
          public string VALIDBEGINDATE
          {
              get { return  Getstring("VALIDBEGINDATE"); }
              set { Setstring("VALIDBEGINDATE",value); }
          }

          // 终止有效期
          public string VALIDENDDATE
          {
              get { return  Getstring("VALIDENDDATE"); }
              set { Setstring("VALIDENDDATE",value); }
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


