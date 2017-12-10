using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // 资源库存操作台账表
     public class TF_R_STOCKRESOURCESTRADETDO : DDOBase
     {
          public TF_R_STOCKRESOURCESTRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_R_STOCKRESOURCESTRADE";

               columns = new String[32][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"OPETYPECODE", "string"};
               columns[2] = new String[]{"RESTYPECODE", "string"};
               columns[3] = new String[]{"BEGINCARDNO", "string"};
               columns[4] = new String[]{"ENDCARDNO", "string"};
               columns[5] = new String[]{"CARDNUM", "Int32"};
               columns[6] = new String[]{"POSNO", "string"};
               columns[7] = new String[]{"SAMNO", "string"};
               columns[8] = new String[]{"OLDPOSNO", "string"};
               columns[9] = new String[]{"OLDSAMNO", "string"};
               columns[10] = new String[]{"STORAGECARDNO", "string"};
               columns[11] = new String[]{"SIMCARDNO", "string"};
               columns[12] = new String[]{"VALIDBEGINDATE", "string"};
               columns[13] = new String[]{"VALIDENDDATE", "string"};
               columns[14] = new String[]{"EQUPRICE", "Int32"};
               columns[15] = new String[]{"CALLINGNO", "string"};
               columns[16] = new String[]{"CORPNO", "string"};
               columns[17] = new String[]{"DEPARTNO", "string"};
               columns[18] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[19] = new String[]{"BALUNITNO", "string"};
               columns[20] = new String[]{"USERTYPECODE", "string"};
               columns[21] = new String[]{"RECEIVERNAME", "String"};
               columns[22] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[23] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[24] = new String[]{"OPERATESTAFFNO", "string"};
               columns[25] = new String[]{"OPERATEDEPARTID", "string"};
               columns[26] = new String[]{"OPERATETIME", "DateTime"};
               columns[27] = new String[]{"CHECKSTAFFNO", "string"};
               columns[28] = new String[]{"CHECKTIME", "DateTime"};
               columns[29] = new String[]{"STATECODE", "string"};
               columns[30] = new String[]{"RECREMARK", "String"};
               columns[31] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[32];
               hash.Add("TRADEID", 0);
               hash.Add("OPETYPECODE", 1);
               hash.Add("RESTYPECODE", 2);
               hash.Add("BEGINCARDNO", 3);
               hash.Add("ENDCARDNO", 4);
               hash.Add("CARDNUM", 5);
               hash.Add("POSNO", 6);
               hash.Add("SAMNO", 7);
               hash.Add("OLDPOSNO", 8);
               hash.Add("OLDSAMNO", 9);
               hash.Add("STORAGECARDNO", 10);
               hash.Add("SIMCARDNO", 11);
               hash.Add("VALIDBEGINDATE", 12);
               hash.Add("VALIDENDDATE", 13);
               hash.Add("EQUPRICE", 14);
               hash.Add("CALLINGNO", 15);
               hash.Add("CORPNO", 16);
               hash.Add("DEPARTNO", 17);
               hash.Add("CALLINGSTAFFNO", 18);
               hash.Add("BALUNITNO", 19);
               hash.Add("USERTYPECODE", 20);
               hash.Add("RECEIVERNAME", 21);
               hash.Add("ASSIGNEDSTAFFNO", 22);
               hash.Add("ASSIGNEDDEPARTID", 23);
               hash.Add("OPERATESTAFFNO", 24);
               hash.Add("OPERATEDEPARTID", 25);
               hash.Add("OPERATETIME", 26);
               hash.Add("CHECKSTAFFNO", 27);
               hash.Add("CHECKTIME", 28);
               hash.Add("STATECODE", 29);
               hash.Add("RECREMARK", 30);
               hash.Add("RSRV1", 31);
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

          // 资源类型编码
          public string RESTYPECODE
          {
              get { return  Getstring("RESTYPECODE"); }
              set { Setstring("RESTYPECODE",value); }
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

          // POS编号
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // SAM编号
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // 原POS编号
          public string OLDPOSNO
          {
              get { return  Getstring("OLDPOSNO"); }
              set { Setstring("OLDPOSNO",value); }
          }

          // 原PSAM卡号
          public string OLDSAMNO
          {
              get { return  Getstring("OLDSAMNO"); }
              set { Setstring("OLDSAMNO",value); }
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

          // 设备价格
          public Int32 EQUPRICE
          {
              get { return  GetInt32("EQUPRICE"); }
              set { SetInt32("EQUPRICE",value); }
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

          // 行业员工编码
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 使用方类型编码
          public string USERTYPECODE
          {
              get { return  Getstring("USERTYPECODE"); }
              set { Setstring("USERTYPECODE",value); }
          }

          // 接收人员
          public String RECEIVERNAME
          {
              get { return  GetString("RECEIVERNAME"); }
              set { SetString("RECEIVERNAME",value); }
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

          // 审核人
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // 审核时间
          public DateTime CHECKTIME
          {
              get { return  GetDateTime("CHECKTIME"); }
              set { SetDateTime("CHECKTIME",value); }
          }

          // 状态编码
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
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


