using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 用户卡库存操作台账表
     public class TF_R_ICUSERTRADETDO : DDOBase
     {
          public TF_R_ICUSERTRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_R_ICUSERTRADE";

               columns = new String[18][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"OPETYPECODE", "string"};
               columns[2] = new String[]{"BEGINCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"CARDNUM", "Int32"};
               columns[5] = new String[]{"COSTYPECODE", "string"};
               columns[6] = new String[]{"CARDTYPECODE", "string"};
               columns[7] = new String[]{"MANUTYPECODE", "string"};
               columns[8] = new String[]{"CARDSURFACECODE", "string"};
               columns[9] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[10] = new String[]{"CARDPRICE", "Int32"};
               columns[11] = new String[]{"CARDAMOUNTPRICE", "Int32"};
               columns[12] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[13] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[14] = new String[]{"OPERATESTAFFNO", "string"};
               columns[15] = new String[]{"OPERATEDEPARTID", "string"};
               columns[16] = new String[]{"OPERATETIME", "DateTime"};
               columns[17] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[18];
               hash.Add("TRADEID", 0);
               hash.Add("OPETYPECODE", 1);
               hash.Add("BEGINCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("CARDNUM", 4);
               hash.Add("COSTYPECODE", 5);
               hash.Add("CARDTYPECODE", 6);
               hash.Add("MANUTYPECODE", 7);
               hash.Add("CARDSURFACECODE", 8);
               hash.Add("CARDCHIPTYPECODE", 9);
               hash.Add("CARDPRICE", 10);
               hash.Add("CARDAMOUNTPRICE", 11);
               hash.Add("ASSIGNEDSTAFFNO", 12);
               hash.Add("ASSIGNEDDEPARTID", 13);
               hash.Add("OPERATESTAFFNO", 14);
               hash.Add("OPERATEDEPARTID", 15);
               hash.Add("OPERATETIME", 16);
               hash.Add("RSRV1", 17);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 操作类型编码
          public string OPETYPECODE
          {
              get { return  Getstring("OPETYPECODE"); }
              set { Setstring("OPETYPECODE",value); }
          }

          // 起始卡号
          public string BEGINCARDNO
          {
              get { return  Getstring("BEGINCARDNO"); }
              set { Setstring("BEGINCARDNO",value); }
          }

          // 终止卡号
          public string ENDCARDNO
          {
              get { return  Getstring("ENDCARDNO"); }
              set { Setstring("ENDCARDNO",value); }
          }

          // 卡数量
          public Int32 CARDNUM
          {
              get { return  GetInt32("CARDNUM"); }
              set { SetInt32("CARDNUM",value); }
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

          // 卡片单价
          public Int32 CARDPRICE
          {
              get { return  GetInt32("CARDPRICE"); }
              set { SetInt32("CARDPRICE",value); }
          }

          // 卡片总金额
          public Int32 CARDAMOUNTPRICE
          {
              get { return  GetInt32("CARDAMOUNTPRICE"); }
              set { SetInt32("CARDAMOUNTPRICE",value); }
          }

          // 所属员工编码
          public string ASSIGNEDSTAFFNO
          {
              get { return  Getstring("ASSIGNEDSTAFFNO"); }
              set { Setstring("ASSIGNEDSTAFFNO",value); }
          }

          // 所属员工部门
          public string ASSIGNEDDEPARTID
          {
              get { return  Getstring("ASSIGNEDDEPARTID"); }
              set { Setstring("ASSIGNEDDEPARTID",value); }
          }

          // 操作员工编码
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // 部门编码
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
          }

          // 操作时间
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // 备用1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

     }
}


