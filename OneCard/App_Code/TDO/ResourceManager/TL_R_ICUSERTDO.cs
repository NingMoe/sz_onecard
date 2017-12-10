using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 用户卡库存表
     public class TL_R_ICUSERTDO : DDOBase
     {
          public TL_R_ICUSERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_R_ICUSER";

               columns = new String[29][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"RESSTATECODE", "string"};
               columns[2] = new String[]{"ASN", "string"};
               columns[3] = new String[]{"COSTYPECODE", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"CARDPRICE", "Int32"};
               columns[6] = new String[]{"MANUTYPECODE", "string"};
               columns[7] = new String[]{"CARDSURFACECODE", "string"};
               columns[8] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[9] = new String[]{"VALIDBEGINDATE", "string"};
               columns[10] = new String[]{"VALIDENDDATE", "string"};
               columns[11] = new String[]{"APPTYPECODE", "string"};
               columns[12] = new String[]{"APPVERNO", "string"};
               columns[13] = new String[]{"PRESUPPLYMONEY", "Int32"};
               columns[14] = new String[]{"SERVICECYCLE", "string"};
               columns[15] = new String[]{"EVESERVICEPRICE", "Int32"};
               columns[16] = new String[]{"INSTIME", "DateTime"};
               columns[17] = new String[]{"OUTTIME", "DateTime"};
               columns[18] = new String[]{"ALLOCTIME", "DateTime"};
               columns[19] = new String[]{"SELLTIME", "DateTime"};
               columns[20] = new String[]{"DESTROYTIME", "DateTime"};
               columns[21] = new String[]{"RECLAIMTIME", "DateTime"};
               columns[22] = new String[]{"FREEZEDATE", "DateTime"};
               columns[23] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[24] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[25] = new String[]{"UPDATESTAFFNO", "string"};
               columns[26] = new String[]{"UPDATETIME", "DateTime"};
               columns[27] = new String[]{"RSRV1", "String"};
               columns[28] = new String[] { "SALETYPE", "String" };

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[29];
               hash.Add("CARDNO", 0);
               hash.Add("RESSTATECODE", 1);
               hash.Add("ASN", 2);
               hash.Add("COSTYPECODE", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("CARDPRICE", 5);
               hash.Add("MANUTYPECODE", 6);
               hash.Add("CARDSURFACECODE", 7);
               hash.Add("CARDCHIPTYPECODE", 8);
               hash.Add("VALIDBEGINDATE", 9);
               hash.Add("VALIDENDDATE", 10);
               hash.Add("APPTYPECODE", 11);
               hash.Add("APPVERNO", 12);
               hash.Add("PRESUPPLYMONEY", 13);
               hash.Add("SERVICECYCLE", 14);
               hash.Add("EVESERVICEPRICE", 15);
               hash.Add("INSTIME", 16);
               hash.Add("OUTTIME", 17);
               hash.Add("ALLOCTIME", 18);
               hash.Add("SELLTIME", 19);
               hash.Add("DESTROYTIME", 20);
               hash.Add("RECLAIMTIME", 21);
               hash.Add("FREEZEDATE", 22);
               hash.Add("ASSIGNEDSTAFFNO", 23);
               hash.Add("ASSIGNEDDEPARTID", 24);
               hash.Add("UPDATESTAFFNO", 25);
               hash.Add("UPDATETIME", 26);
               hash.Add("RSRV1", 27);
               hash.Add("SALETYPE", 28);
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 卡片库存状态
          public string RESSTATECODE
          {
              get { return  Getstring("RESSTATECODE"); }
              set { Setstring("RESSTATECODE",value); }
          }

          // 卡序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // COS类型
          public string COSTYPECODE
          {
              get { return  Getstring("COSTYPECODE"); }
              set { Setstring("COSTYPECODE",value); }
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

          // 卡面编码
          public string CARDSURFACECODE
          {
              get { return  Getstring("CARDSURFACECODE"); }
              set { Setstring("CARDSURFACECODE",value); }
          }

          // 卡芯片编码
          public string CARDCHIPTYPECODE
          {
              get { return  Getstring("CARDCHIPTYPECODE"); }
              set { Setstring("CARDCHIPTYPECODE",value); }
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

          // 应用类型
          public string APPTYPECODE
          {
              get { return  Getstring("APPTYPECODE"); }
              set { Setstring("APPTYPECODE",value); }
          }

          // 应用版本
          public string APPVERNO
          {
              get { return  Getstring("APPVERNO"); }
              set { Setstring("APPVERNO",value); }
          }

          // 预充金额
          public Int32 PRESUPPLYMONEY
          {
              get { return  GetInt32("PRESUPPLYMONEY"); }
              set { SetInt32("PRESUPPLYMONEY",value); }
          }

          // 服务周期
          public string SERVICECYCLE
          {
              get { return  Getstring("SERVICECYCLE"); }
              set { Setstring("SERVICECYCLE",value); }
          }

          // 每期服务费用
          public Int32 EVESERVICEPRICE
          {
              get { return  GetInt32("EVESERVICEPRICE"); }
              set { SetInt32("EVESERVICEPRICE",value); }
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

          // 分配时间
          public DateTime ALLOCTIME
          {
              get { return  GetDateTime("ALLOCTIME"); }
              set { SetDateTime("ALLOCTIME",value); }
          }

          // 销售时间
          public DateTime SELLTIME
          {
              get { return  GetDateTime("SELLTIME"); }
              set { SetDateTime("SELLTIME",value); }
          }

          // 作废时间
          public DateTime DESTROYTIME
          {
              get { return  GetDateTime("DESTROYTIME"); }
              set { SetDateTime("DESTROYTIME",value); }
          }

          // 回收时间
          public DateTime RECLAIMTIME
          {
              get { return  GetDateTime("RECLAIMTIME"); }
              set { SetDateTime("RECLAIMTIME",value); }
          }

          // 冻结截至日期
          public DateTime FREEZEDATE
          {
              get { return  GetDateTime("FREEZEDATE"); }
              set { SetDateTime("FREEZEDATE",value); }
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

          // 售卡方式1
          public String SALETYPE
          {
              get { return GetString("SALETYPE"); }
              set { SetString("SALETYPE", value); }
          }

     }
}


