using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // 充值卡直销
     public class SP_CC_DirectSalePDO : PDOBase
     {
          public SP_CC_DirectSalePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_DirectSale",12);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@custName", "String", "20", "input");
               AddField("@payMode", "string", "1", "input");
               AddField("@accRecv", "string", "1", "input");
               AddField("@recvDate", "string", "8", "input");
               AddField("@remark", "String", "50", "input");

               InitEnd();
          }

          // 开始卡号
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // 结束卡号
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // 客户姓名
          public String custName
          {
              get { return  GetString("custName"); }
              set { SetString("custName",value); }
          }

          // 付款方式
          public string payMode
          {
              get { return  Getstring("payMode"); }
              set { Setstring("payMode",value); }
          }

          // 到帐标记
          public string accRecv
          {
              get { return  Getstring("accRecv"); }
              set { Setstring("accRecv",value); }
          }

          // 到帐日期
          public string recvDate
          {
              get { return  Getstring("recvDate"); }
              set { Setstring("recvDate",value); }
          }

          // 备注
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

     }
}


