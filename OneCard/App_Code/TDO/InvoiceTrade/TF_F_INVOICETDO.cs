using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // 发票资料表
     public class TF_F_INVOICETDO : DDOBase
     {
          public TF_F_INVOICETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_INVOICE";

               columns = new String[27][];
               columns[0] = new String[]{"INVOICENO", "string"};
               columns[1] = new String[]{"VOLUMENO", "string"};
               columns[2] = new String[]{"ID", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"PROJ1", "String"};
               columns[5] = new String[]{"FEE1", "Int32"};
               columns[6] = new String[]{"PROJ2", "String"};
               columns[7] = new String[]{"FEE2", "Int32"};
               columns[8] = new String[]{"PROJ3", "String"};
               columns[9] = new String[]{"FEE3", "Int32"};
               columns[10] = new String[]{"PROJ4", "String"};
               columns[11] = new String[]{"FEE4", "Int32"};
               columns[12] = new String[]{"PROJ5", "String"};
               columns[13] = new String[]{"FEE5", "Int32"};
               columns[14] = new String[]{"TRADEFEE", "Int32"};
               columns[15] = new String[]{"PAYMAN", "String"};
               columns[16] = new String[]{"TRADESTAFF", "String"};
               columns[17] = new String[]{"TRADETIME", "DateTime"};
               columns[18] = new String[]{"TAXNO", "String"};
               columns[19] = new String[]{"OLDINVOICENO", "string"};
               columns[20] = new String[]{"OPERATESTAFFNO", "string"};
               columns[21] = new String[]{"OPERATEDEPARTID", "string"};
               columns[22] = new String[]{"OPERATETIME", "DateTime"};
               columns[23] = new String[]{"REMARK", "String"};
               columns[24] = new String[]{"RSRV1", "Int32"};
               columns[25] = new String[]{"RSRV2", "String"};
               columns[26] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "INVOICENO",
               };


               array = new String[27];
               hash.Add("INVOICENO", 0);
               hash.Add("VOLUMENO", 1);
               hash.Add("ID", 2);
               hash.Add("CARDNO", 3);
               hash.Add("PROJ1", 4);
               hash.Add("FEE1", 5);
               hash.Add("PROJ2", 6);
               hash.Add("FEE2", 7);
               hash.Add("PROJ3", 8);
               hash.Add("FEE3", 9);
               hash.Add("PROJ4", 10);
               hash.Add("FEE4", 11);
               hash.Add("PROJ5", 12);
               hash.Add("FEE5", 13);
               hash.Add("TRADEFEE", 14);
               hash.Add("PAYMAN", 15);
               hash.Add("TRADESTAFF", 16);
               hash.Add("TRADETIME", 17);
               hash.Add("TAXNO", 18);
               hash.Add("OLDINVOICENO", 19);
               hash.Add("OPERATESTAFFNO", 20);
               hash.Add("OPERATEDEPARTID", 21);
               hash.Add("OPERATETIME", 22);
               hash.Add("REMARK", 23);
               hash.Add("RSRV1", 24);
               hash.Add("RSRV2", 25);
               hash.Add("RSRV3", 26);
          }

          // 发票号
          public string INVOICENO
          {
              get { return  Getstring("INVOICENO"); }
              set { Setstring("INVOICENO",value); }
          }

          // 发票卷号
          public string VOLUMENO
          {
              get { return  Getstring("VOLUMENO"); }
              set { Setstring("VOLUMENO",value); }
          }

          // 现金台帐记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 项目一
          public String PROJ1
          {
              get { return  GetString("PROJ1"); }
              set { SetString("PROJ1",value); }
          }

          // 金额一
          public Int32 FEE1
          {
              get { return  GetInt32("FEE1"); }
              set { SetInt32("FEE1",value); }
          }

          // 项目二
          public String PROJ2
          {
              get { return  GetString("PROJ2"); }
              set { SetString("PROJ2",value); }
          }

          // 金额二
          public Int32 FEE2
          {
              get { return  GetInt32("FEE2"); }
              set { SetInt32("FEE2",value); }
          }

          // 项目三
          public String PROJ3
          {
              get { return  GetString("PROJ3"); }
              set { SetString("PROJ3",value); }
          }

          // 金额三
          public Int32 FEE3
          {
              get { return  GetInt32("FEE3"); }
              set { SetInt32("FEE3",value); }
          }

          // 项目四
          public String PROJ4
          {
              get { return  GetString("PROJ4"); }
              set { SetString("PROJ4",value); }
          }

          // 金额四
          public Int32 FEE4
          {
              get { return  GetInt32("FEE4"); }
              set { SetInt32("FEE4",value); }
          }

          // 项目五
          public String PROJ5
          {
              get { return  GetString("PROJ5"); }
              set { SetString("PROJ5",value); }
          }

          // 金额五
          public Int32 FEE5
          {
              get { return  GetInt32("FEE5"); }
              set { SetInt32("FEE5",value); }
          }

          // 发票总金额
          public Int32 TRADEFEE
          {
              get { return  GetInt32("TRADEFEE"); }
              set { SetInt32("TRADEFEE",value); }
          }

          // 付款方
          public String PAYMAN
          {
              get { return  GetString("PAYMAN"); }
              set { SetString("PAYMAN",value); }
          }

          // 开票人
          public String TRADESTAFF
          {
              get { return  GetString("TRADESTAFF"); }
              set { SetString("TRADESTAFF",value); }
          }

          // 开票时间
          public DateTime TRADETIME
          {
              get { return  GetDateTime("TRADETIME"); }
              set { SetDateTime("TRADETIME",value); }
          }

          // 纳税人识别号
          public String TAXNO
          {
              get { return  GetString("TAXNO"); }
              set { SetString("TAXNO",value); }
          }

          // 红冲发票号
          public string OLDINVOICENO
          {
              get { return  Getstring("OLDINVOICENO"); }
              set { Setstring("OLDINVOICENO",value); }
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

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // 备用1
          public Int32 RSRV1
          {
              get { return  GetInt32("RSRV1"); }
              set { SetInt32("RSRV1",value); }
          }

          // 备用2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // 备用3
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


