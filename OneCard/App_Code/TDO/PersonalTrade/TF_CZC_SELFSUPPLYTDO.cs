using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // 充值卡向电子钱包充值台帐表
     public class TF_CZC_SELFSUPPLYTDO : DDOBase
     {
          public TF_CZC_SELFSUPPLYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CZC_SELFSUPPLY";

               columns = new String[13][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CZCARDNO", "string"};
               columns[3] = new String[]{"PASSWD", "string"};
               columns[4] = new String[]{"CARDNO", "string"};
               columns[5] = new String[]{"CARDTRADENO", "string"};
               columns[6] = new String[]{"PREMONEY", "Int32"};
               columns[7] = new String[]{"TERMNO", "string"};
               columns[8] = new String[]{"OPERATESTAFFNO", "string"};
               columns[9] = new String[]{"OPERATEDEPARTID", "string"};
               columns[10] = new String[]{"UPDATETIME", "DateTime"};
               columns[11] = new String[]{"RSRV1", "String"};
               columns[12] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[13];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CZCARDNO", 2);
               hash.Add("PASSWD", 3);
               hash.Add("CARDNO", 4);
               hash.Add("CARDTRADENO", 5);
               hash.Add("PREMONEY", 6);
               hash.Add("TERMNO", 7);
               hash.Add("OPERATESTAFFNO", 8);
               hash.Add("OPERATEDEPARTID", 9);
               hash.Add("UPDATETIME", 10);
               hash.Add("RSRV1", 11);
               hash.Add("RSRV2", 12);
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

          // 充值卡号
          public string CZCARDNO
          {
              get { return  Getstring("CZCARDNO"); }
              set { Setstring("CZCARDNO",value); }
          }

          // 密码
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 联机交易序号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 充值前卡内余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
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

          // 充值时间
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

     }
}


