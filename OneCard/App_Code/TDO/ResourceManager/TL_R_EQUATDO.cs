using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 设备资源库存表
     public class TL_R_EQUATDO : DDOBase
     {
          public TL_R_EQUATDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_R_EQUA";

               columns = new String[28][];
               columns[0] = new String[]{"POSNO", "string"};
               columns[1] = new String[]{"EQUSOURCE", "string"};
               columns[2] = new String[]{"EQUSORT", "string"};
               columns[3] = new String[]{"POSMODECODE", "string"};
               columns[4] = new String[]{"TOUCHTYPECODE", "string"};
               columns[5] = new String[]{"LAYTYPECODE", "string"};
               columns[6] = new String[]{"COMMTYPECODE", "string"};
               columns[7] = new String[]{"EQUPRICE", "Int32"};
               columns[8] = new String[]{"POSMANUCODE", "string"};
               columns[9] = new String[]{"POSHARDWARENUM", "String"};
               columns[10] = new String[]{"RESSTATECODE", "string"};
               columns[11] = new String[]{"CALLINGNO", "string"};
               columns[12] = new String[]{"CORPNO", "string"};
               columns[13] = new String[]{"DEPARTNO", "string"};
               columns[14] = new String[]{"STORAGECARDNO", "string"};
               columns[15] = new String[]{"SIMCARDNO", "string"};
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
               columns[27] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "POSNO",
               };


               array = new String[28];
               hash.Add("POSNO", 0);
               hash.Add("EQUSOURCE", 1);
               hash.Add("EQUSORT", 2);
               hash.Add("POSMODECODE", 3);
               hash.Add("TOUCHTYPECODE", 4);
               hash.Add("LAYTYPECODE", 5);
               hash.Add("COMMTYPECODE", 6);
               hash.Add("EQUPRICE", 7);
               hash.Add("POSMANUCODE", 8);
               hash.Add("POSHARDWARENUM", 9);
               hash.Add("RESSTATECODE", 10);
               hash.Add("CALLINGNO", 11);
               hash.Add("CORPNO", 12);
               hash.Add("DEPARTNO", 13);
               hash.Add("STORAGECARDNO", 14);
               hash.Add("SIMCARDNO", 15);
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
               hash.Add("RSRV1", 27);
          }

          // 设备编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // 设备来源
          public string EQUSOURCE
          {
              get { return  Getstring("EQUSOURCE"); }
              set { Setstring("EQUSOURCE",value); }
          }

          // 设备分类编码
          public string EQUSORT
          {
              get { return  Getstring("EQUSORT"); }
              set { Setstring("EQUSORT",value); }
          }

          // 设备型号编码
          public string POSMODECODE
          {
              get { return  Getstring("POSMODECODE"); }
              set { Setstring("POSMODECODE",value); }
          }

          // POS接触类型编码
          public string TOUCHTYPECODE
          {
              get { return  Getstring("TOUCHTYPECODE"); }
              set { Setstring("TOUCHTYPECODE",value); }
          }

          // POS放置类型编码
          public string LAYTYPECODE
          {
              get { return  Getstring("LAYTYPECODE"); }
              set { Setstring("LAYTYPECODE",value); }
          }

          // POS通信类型编码
          public string COMMTYPECODE
          {
              get { return  Getstring("COMMTYPECODE"); }
              set { Setstring("COMMTYPECODE",value); }
          }

          // 设备价格
          public Int32 EQUPRICE
          {
              get { return  GetInt32("EQUPRICE"); }
              set { SetInt32("EQUPRICE",value); }
          }

          // 设备厂商
          public string POSMANUCODE
          {
              get { return  Getstring("POSMANUCODE"); }
              set { Setstring("POSMANUCODE",value); }
          }

          // 设备硬件序列号
          public String POSHARDWARENUM
          {
              get { return  GetString("POSHARDWARENUM"); }
              set { SetString("POSHARDWARENUM",value); }
          }

          // 设备库存状态
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

          // 存储卡卡号
          public string STORAGECARDNO
          {
              get { return  Getstring("STORAGECARDNO"); }
              set { Setstring("STORAGECARDNO",value); }
          }

          // SIM卡卡号
          public string SIMCARDNO
          {
              get { return  Getstring("SIMCARDNO"); }
              set { Setstring("SIMCARDNO",value); }
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

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

     }
}


