using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 可充金额向电子钱包充值台帐表
     public class TF_GROUP_SELFSUPPLYTDO : DDOBase
     {
          public TF_GROUP_SELFSUPPLYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_GROUP_SELFSUPPLY";

               columns = new String[15][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"ASN", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"CARDTRADENO", "string"};
               columns[6] = new String[]{"TRADEMONEY", "Int32"};
               columns[7] = new String[]{"PREMONEY", "Int32"};
               columns[8] = new String[]{"DBPREMONEY", "Int32"};
               columns[9] = new String[]{"TERMNO", "string"};
               columns[10] = new String[]{"OPERATESTAFFNO", "string"};
               columns[11] = new String[]{"OPERATEDEPARTID", "string"};
               columns[12] = new String[]{"TRADETIME", "DateTime"};
               columns[13] = new String[]{"RSRV1", "String"};
               columns[14] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[15];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("ASN", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("CARDTRADENO", 5);
               hash.Add("TRADEMONEY", 6);
               hash.Add("PREMONEY", 7);
               hash.Add("DBPREMONEY", 8);
               hash.Add("TERMNO", 9);
               hash.Add("OPERATESTAFFNO", 10);
               hash.Add("OPERATEDEPARTID", 11);
               hash.Add("TRADETIME", 12);
               hash.Add("RSRV1", 13);
               hash.Add("RSRV2", 14);
          }

          // 业务流水号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 记录流水号
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

          // 卡序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 卡类型
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 联机交易序号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 交易金额
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // 充值前卡内余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // 数据库前余额
          public Int32 DBPREMONEY
          {
              get { return  GetInt32("DBPREMONEY"); }
              set { SetInt32("DBPREMONEY",value); }
          }

          // 终端机编号
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
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

          // 交易时间
          public DateTime TRADETIME
          {
              get { return  GetDateTime("TRADETIME"); }
              set { SetDateTime("TRADETIME",value); }
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

     }
}


