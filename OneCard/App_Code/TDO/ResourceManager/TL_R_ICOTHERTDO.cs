using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 其他卡库存表
     public class TL_R_ICOTHERTDO : DDOBase
     {
          public TL_R_ICOTHERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_R_ICOTHER";

               columns = new String[29][];
               columns[0] = new String[]{"CARDNO", "String"};
               columns[1] = new String[]{"CARDKINDCODE", "string"};
               columns[2] = new String[]{"COSTYPECODE", "string"};
               columns[3] = new String[]{"SAMVERSION", "string"};
               columns[4] = new String[]{"KEYINDEX", "string"};
               columns[5] = new String[]{"CARDTYPECODE", "string"};
               columns[6] = new String[]{"CARDPRICE", "Int32"};
               columns[7] = new String[]{"MANUTYPECODE", "string"};
               columns[8] = new String[]{"PRODUCERID", "String"};
               columns[9] = new String[]{"ACCEPTERID", "String"};
               columns[10] = new String[]{"VALIDBEGINDATE", "string"};
               columns[11] = new String[]{"VALIDENDDATE", "string"};
               columns[12] = new String[]{"RESSTATECODE", "string"};
               columns[13] = new String[]{"CALLINGNO", "string"};
               columns[14] = new String[]{"CORPNO", "string"};
               columns[15] = new String[]{"DEPARTNO", "string"};
               columns[16] = new String[]{"INSTIME", "DateTime"};
               columns[17] = new String[]{"OUTTIME", "DateTime"};
               columns[18] = new String[]{"DEPREBEGINTIME", "DateTime"};
               columns[19] = new String[]{"DEPREMONTHS", "Int32"};
               columns[20] = new String[]{"USETIME", "DateTime"};
               columns[21] = new String[]{"REINTIME", "DateTime"};
               columns[22] = new String[]{"DESTROYTIME", "DateTime"};
               columns[23] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[24] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[25] = new String[]{"UPDATESTAFFNO", "string"};
               columns[26] = new String[]{"UPDATETIME", "DateTime"};
               columns[27] = new String[]{"RECREMARK", "String"};
               columns[28] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[29];
               hash.Add("CARDNO", 0);
               hash.Add("CARDKINDCODE", 1);
               hash.Add("COSTYPECODE", 2);
               hash.Add("SAMVERSION", 3);
               hash.Add("KEYINDEX", 4);
               hash.Add("CARDTYPECODE", 5);
               hash.Add("CARDPRICE", 6);
               hash.Add("MANUTYPECODE", 7);
               hash.Add("PRODUCERID", 8);
               hash.Add("ACCEPTERID", 9);
               hash.Add("VALIDBEGINDATE", 10);
               hash.Add("VALIDENDDATE", 11);
               hash.Add("RESSTATECODE", 12);
               hash.Add("CALLINGNO", 13);
               hash.Add("CORPNO", 14);
               hash.Add("DEPARTNO", 15);
               hash.Add("INSTIME", 16);
               hash.Add("OUTTIME", 17);
               hash.Add("DEPREBEGINTIME", 18);
               hash.Add("DEPREMONTHS", 19);
               hash.Add("USETIME", 20);
               hash.Add("REINTIME", 21);
               hash.Add("DESTROYTIME", 22);
               hash.Add("ASSIGNEDSTAFFNO", 23);
               hash.Add("ASSIGNEDDEPARTID", 24);
               hash.Add("UPDATESTAFFNO", 25);
               hash.Add("UPDATETIME", 26);
               hash.Add("RECREMARK", 27);
               hash.Add("RSRV1", 28);
          }

          // 卡号
          public String CARDNO
          {
              get { return  GetString("CARDNO"); }
              set { SetString("CARDNO",value); }
          }

          // 卡类别编码
          public string CARDKINDCODE
          {
              get { return  Getstring("CARDKINDCODE"); }
              set { Setstring("CARDKINDCODE",value); }
          }

          // COS类型
          public string COSTYPECODE
          {
              get { return  Getstring("COSTYPECODE"); }
              set { Setstring("COSTYPECODE",value); }
          }

          // 应用版本号
          public string SAMVERSION
          {
              get { return  Getstring("SAMVERSION"); }
              set { Setstring("SAMVERSION",value); }
          }

          // 密钥索引号
          public string KEYINDEX
          {
              get { return  Getstring("KEYINDEX"); }
              set { Setstring("KEYINDEX",value); }
          }

          // 卡片类型
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 卡片单价
          public Int32 CARDPRICE
          {
              get { return  GetInt32("CARDPRICE"); }
              set { SetInt32("CARDPRICE",value); }
          }

          // 卡片厂商
          public string MANUTYPECODE
          {
              get { return  Getstring("MANUTYPECODE"); }
              set { Setstring("MANUTYPECODE",value); }
          }

          // 发行者标志
          public String PRODUCERID
          {
              get { return  GetString("PRODUCERID"); }
              set { SetString("PRODUCERID",value); }
          }

          // 接收者标志
          public String ACCEPTERID
          {
              get { return  GetString("ACCEPTERID"); }
              set { SetString("ACCEPTERID",value); }
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

          // 卡片库存状态
          public string RESSTATECODE
          {
              get { return  Getstring("RESSTATECODE"); }
              set { Setstring("RESSTATECODE",value); }
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

          // 入库时间
          public DateTime INSTIME
          {
              get { return  GetDateTime("INSTIME"); }
              set { SetDateTime("INSTIME",value); }
          }

          // 出库时间
          public DateTime OUTTIME
          {
              get { return  GetDateTime("OUTTIME"); }
              set { SetDateTime("OUTTIME",value); }
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

          // 领用时间
          public DateTime USETIME
          {
              get { return  GetDateTime("USETIME"); }
              set { SetDateTime("USETIME",value); }
          }

          // 归还时间
          public DateTime REINTIME
          {
              get { return  GetDateTime("REINTIME"); }
              set { SetDateTime("REINTIME",value); }
          }

          // 作废时间
          public DateTime DESTROYTIME
          {
              get { return  GetDateTime("DESTROYTIME"); }
              set { SetDateTime("DESTROYTIME",value); }
          }

          // 所属员工编码
          public string ASSIGNEDSTAFFNO
          {
              get { return  Getstring("ASSIGNEDSTAFFNO"); }
              set { Setstring("ASSIGNEDSTAFFNO",value); }
          }

          // 所属员工部门编码
          public string ASSIGNEDDEPARTID
          {
              get { return  Getstring("ASSIGNEDDEPARTID"); }
              set { Setstring("ASSIGNEDDEPARTID",value); }
          }

          // 更新员工编码
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
          public String RECREMARK
          {
              get { return  GetString("RECREMARK"); }
              set { SetString("RECREMARK",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

     }
}


