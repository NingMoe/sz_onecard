using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 退卡返销
     public class SP_PB_ReturnCardRollbackPDO : PDOBase
     {
          public SP_PB_ReturnCardRollbackPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ReturnCardRollback",20);

               AddField("@ID", "string", "18", "input");
               AddField("@CANCELTRADEID", "string", "16", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@REASONCODE", "string", "2", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@REFUNDMONEY", "Int32", "", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@REFUNDDEPOSIT", "Int32", "", "input");
               AddField("@TRADEPROCFEE", "Int32", "", "input");
               AddField("@OTHERFEE", "Int32", "", "input");
               AddField("@CARDSTATE", "string", "2", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 回退业务流水号
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 退卡类型编码
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // 交易类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 联机交易序号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 已退充值
          public Int32 REFUNDMONEY
          {
              get { return  GetInt32("REFUNDMONEY"); }
              set { SetInt32("REFUNDMONEY",value); }
          }

          // 卡内金额
          public Int32 CARDMONEY
          {
              get { return GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY", value); }
          }

          // 已退押金
          public Int32 REFUNDDEPOSIT
          {
              get { return  GetInt32("REFUNDDEPOSIT"); }
              set { SetInt32("REFUNDDEPOSIT",value); }
          }

          // 手续费
          public Int32 TRADEPROCFEE
          {
              get { return  GetInt32("TRADEPROCFEE"); }
              set { SetInt32("TRADEPROCFEE",value); }
          }

          // 其他费用
          public Int32 OTHERFEE
          {
              get { return  GetInt32("OTHERFEE"); }
              set { SetInt32("OTHERFEE",value); }
          }

          // 卡状态
          public string CARDSTATE
          {
              get { return  Getstring("CARDSTATE"); }
              set { Setstring("CARDSTATE",value); }
          }

          // 服务费收取标志
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // 终端号
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // 操作员卡号
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // 交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


