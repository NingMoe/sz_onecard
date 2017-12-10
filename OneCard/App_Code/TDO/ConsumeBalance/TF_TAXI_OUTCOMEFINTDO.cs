using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ConsumeBalance
{
     // 出租消费支出转账帐单表
     public class TF_TAXI_OUTCOMEFINTDO : DDOBase
     {
          public TF_TAXI_OUTCOMEFINTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TAXI_OUTCOMEFIN";

               columns = new String[25][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[6] = new String[]{"FEETYPECODE", "string"};
               columns[7] = new String[]{"FINTYPECODE", "string"};
               columns[8] = new String[]{"COMFEETAKECODE", "string"};
               columns[9] = new String[]{"COMSCHEMENO", "string"};
               columns[10] = new String[]{"FINBANKCODE", "string"};
               columns[11] = new String[]{"TRANSFEE", "Int32"};
               columns[12] = new String[]{"COMFEE", "Int32"};
               columns[13] = new String[]{"RIGHTFINFEE", "Int32"};
               columns[14] = new String[]{"RIGHTFINTIMES", "Int32"};
               columns[15] = new String[]{"RENEWFINFEE", "Int32"};
               columns[16] = new String[]{"RENEWFINTIMES", "Int32"};
               columns[17] = new String[]{"FINFEE", "Int32"};
               columns[18] = new String[]{"FINTIMES", "Int32"};
               columns[19] = new String[]{"BEGINTIME", "DateTime"};
               columns[20] = new String[]{"ENDTIME", "DateTime"};
               columns[21] = new String[]{"FINTIME", "DateTime"};
               columns[22] = new String[]{"DEALSTATECODE", "string"};
               columns[23] = new String[]{"RSRVCHAR", "string"};
               columns[24] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[25];
               hash.Add("ID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("CALLINGSTAFFNO", 5);
               hash.Add("FEETYPECODE", 6);
               hash.Add("FINTYPECODE", 7);
               hash.Add("COMFEETAKECODE", 8);
               hash.Add("COMSCHEMENO", 9);
               hash.Add("FINBANKCODE", 10);
               hash.Add("TRANSFEE", 11);
               hash.Add("COMFEE", 12);
               hash.Add("RIGHTFINFEE", 13);
               hash.Add("RIGHTFINTIMES", 14);
               hash.Add("RENEWFINFEE", 15);
               hash.Add("RENEWFINTIMES", 16);
               hash.Add("FINFEE", 17);
               hash.Add("FINTIMES", 18);
               hash.Add("BEGINTIME", 19);
               hash.Add("ENDTIME", 20);
               hash.Add("FINTIME", 21);
               hash.Add("DEALSTATECODE", 22);
               hash.Add("RSRVCHAR", 23);
               hash.Add("REMARK", 24);
          }

          // 结算流水号
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
          }

          // 结算单元编号
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
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

          // 费用类型
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // 转账类型
          public string FINTYPECODE
          {
              get { return  Getstring("FINTYPECODE"); }
              set { Setstring("FINTYPECODE",value); }
          }

          // 佣金扣减方式编码
          public string COMFEETAKECODE
          {
              get { return  Getstring("COMFEETAKECODE"); }
              set { Setstring("COMFEETAKECODE",value); }
          }

          // 佣金方案编码
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // 转出行银行代码
          public string FINBANKCODE
          {
              get { return  Getstring("FINBANKCODE"); }
              set { Setstring("FINBANKCODE",value); }
          }

          // 转账金额
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

          // 佣金总额
          public Int32 COMFEE
          {
              get { return  GetInt32("COMFEE"); }
              set { SetInt32("COMFEE",value); }
          }

          // 正常记录结算金额
          public Int32 RIGHTFINFEE
          {
              get { return  GetInt32("RIGHTFINFEE"); }
              set { SetInt32("RIGHTFINFEE",value); }
          }

          // 正常记录结算笔数
          public Int32 RIGHTFINTIMES
          {
              get { return  GetInt32("RIGHTFINTIMES"); }
              set { SetInt32("RIGHTFINTIMES",value); }
          }

          // 恢复记录结算金额
          public Int32 RENEWFINFEE
          {
              get { return  GetInt32("RENEWFINFEE"); }
              set { SetInt32("RENEWFINFEE",value); }
          }

          // 恢复记录结算笔数
          public Int32 RENEWFINTIMES
          {
              get { return  GetInt32("RENEWFINTIMES"); }
              set { SetInt32("RENEWFINTIMES",value); }
          }

          // 结算总金额
          public Int32 FINFEE
          {
              get { return  GetInt32("FINFEE"); }
              set { SetInt32("FINFEE",value); }
          }

          // 结算总笔数
          public Int32 FINTIMES
          {
              get { return  GetInt32("FINTIMES"); }
              set { SetInt32("FINTIMES",value); }
          }

          // 起始时间
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // 结束时间
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // 转账帐单时间
          public DateTime FINTIME
          {
              get { return  GetDateTime("FINTIME"); }
              set { SetDateTime("FINTIME",value); }
          }

          // 处理状态码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // 保留标志
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


