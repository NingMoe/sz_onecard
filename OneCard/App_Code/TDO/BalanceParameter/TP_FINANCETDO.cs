using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 转账工作表
     public class TP_FINANCETDO : DDOBase
     {
          public TP_FINANCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_FINANCE";

               columns = new String[11][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"CHNLTYPE", "string"};
               columns[2] = new String[]{"BALUNITNO", "string"};
               columns[3] = new String[]{"COMSCHEMENO", "string"};
               columns[4] = new String[]{"FINTIMES", "Int32"};
               columns[5] = new String[]{"BEGINTIME", "DateTime"};
               columns[6] = new String[]{"ENDTIME", "DateTime"};
               columns[7] = new String[]{"COMFEETAKECODE", "string"};
               columns[8] = new String[]{"FINTYPECODE", "string"};
               columns[9] = new String[]{"DEALSTATECODE", "string"};
               columns[10] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[11];
               hash.Add("ID", 0);
               hash.Add("CHNLTYPE", 1);
               hash.Add("BALUNITNO", 2);
               hash.Add("COMSCHEMENO", 3);
               hash.Add("FINTIMES", 4);
               hash.Add("BEGINTIME", 5);
               hash.Add("ENDTIME", 6);
               hash.Add("COMFEETAKECODE", 7);
               hash.Add("FINTYPECODE", 8);
               hash.Add("DEALSTATECODE", 9);
               hash.Add("REMARK", 10);
          }

          // 编号
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
          }

          // 通道类型
          public string CHNLTYPE
          {
              get { return  Getstring("CHNLTYPE"); }
              set { Setstring("CHNLTYPE",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 佣金方案编码
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // 帐单生成笔数
          public Int32 FINTIMES
          {
              get { return  GetInt32("FINTIMES"); }
              set { SetInt32("FINTIMES",value); }
          }

          // 周期开始时间
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // 周期结束时间
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // 佣金扣减方式编码
          public string COMFEETAKECODE
          {
              get { return  Getstring("COMFEETAKECODE"); }
              set { Setstring("COMFEETAKECODE",value); }
          }

          // 转账类型
          public string FINTYPECODE
          {
              get { return  Getstring("FINTYPECODE"); }
              set { Setstring("FINTYPECODE",value); }
          }

          // 处理状态编码
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


