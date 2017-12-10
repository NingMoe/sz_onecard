using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 换卡
     public class SP_PB_ChangeCardPDO : PDOBase
     {
          public SP_PB_ChangeCardPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ChangeCard",35);

               AddField("@ID", "string", "18", "input");
               AddField("@CUSTRECTYPECODE", "string", "2", "input");
               AddField("@CARDCOST", "Int32", "", "input");
               AddField("@NEWCARDNO", "string", "16", "input");
               AddField("@OLDCARDNO", "string", "16", "input");
               AddField("@ONLINECARDTRADENO", "string", "4", "input");
               AddField("@CHECKSTAFFNO", "string", "6", "input");
               AddField("@CHECKDEPARTNO", "string", "4", "input");
               AddField("@CHANGECODE", "string", "2", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@SELLCHANNELCODE", "string", "2", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@DEPOSIT", "Int32", "", "input");
               AddField("@SERSTARTTIME", "DateTime", "", "input");
               AddField("@SERVICEMONE", "Int32", "", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@NEWSERSTAKETAG", "string", "1", "input");
               AddField("@SUPPLYREALMONEY", "Int32", "", "input");
               AddField("@TOTALSUPPLYMONEY", "Int32", "", "input");
               AddField("@OLDDEPOSIT", "Int32", "", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@NEXTMONEY", "Int32", "", "input");
               AddField("@CURRENTMONEY", "Int32", "", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@CURRENTTIME", "DateTime", "", "output");
               AddField("@TRADEID", "string", "16", "output");
               AddField("@TRADEID2", "string", "16", "output");

               InitEnd();
          }

          // 记录流水号
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 持卡人资料类型
          public string CUSTRECTYPECODE
          {
              get { return  Getstring("CUSTRECTYPECODE"); }
              set { Setstring("CUSTRECTYPECODE",value); }
          }

          // 新卡卡费
          public Int32 CARDCOST
          {
              get { return  GetInt32("CARDCOST"); }
              set { SetInt32("CARDCOST",value); }
          }

          // 新卡卡号
          public string NEWCARDNO
          {
              get { return  Getstring("NEWCARDNO"); }
              set { Setstring("NEWCARDNO",value); }
          }

          // 旧卡卡号
          public string OLDCARDNO
          {
              get { return  Getstring("OLDCARDNO"); }
              set { Setstring("OLDCARDNO",value); }
          }

          // 联机交易序号
          public string ONLINECARDTRADENO
          {
              get { return  Getstring("ONLINECARDTRADENO"); }
              set { Setstring("ONLINECARDTRADENO",value); }
          }

          // 审批员工编码
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // 审批部门编码
          public string CHECKDEPARTNO
          {
              get { return  Getstring("CHECKDEPARTNO"); }
              set { Setstring("CHECKDEPARTNO",value); }
          }

          // 换卡类型
          public string CHANGECODE
          {
              get { return  Getstring("CHANGECODE"); }
              set { Setstring("CHANGECODE",value); }
          }

          // 新卡应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 卡类型编码
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 售卡渠道编码
          public string SELLCHANNELCODE
          {
              get { return  Getstring("SELLCHANNELCODE"); }
              set { Setstring("SELLCHANNELCODE",value); }
          }

          // 交易类型编码
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 新卡押金
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // 新卡服务开始日期
          public DateTime SERSTARTTIME
          {
              get { return  GetDateTime("SERSTARTTIME"); }
              set { SetDateTime("SERSTARTTIME",value); }
          }

          // 新卡实收卡服务费
          public Int32 SERVICEMONE
          {
              get { return  GetInt32("SERVICEMONE"); }
              set { SetInt32("SERVICEMONE",value); }
          }

          // 新卡卡内余额
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // 新卡服务费收取标志
          public string NEWSERSTAKETAG
          {
              get { return  Getstring("NEWSERSTAKETAG"); }
              set { Setstring("NEWSERSTAKETAG",value); }
          }

          // 旧卡余额
          public Int32 SUPPLYREALMONEY
          {
              get { return  GetInt32("SUPPLYREALMONEY"); }
              set { SetInt32("SUPPLYREALMONEY",value); }
          }

          // 总充值金额
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // 旧卡剩余押金
          public Int32 OLDDEPOSIT
          {
              get { return  GetInt32("OLDDEPOSIT"); }
              set { SetInt32("OLDDEPOSIT",value); }
          }

          // 旧卡服务费收取标志
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // 新卡发生前余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // 新卡发生后余额
          public Int32 NEXTMONEY
          {
              get { return  GetInt32("NEXTMONEY"); }
              set { SetInt32("NEXTMONEY",value); }
          }

          // 新卡发生余额
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
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

          // 返回系统时间
          public DateTime CURRENTTIME
          {
              get { return  GetDateTime("CURRENTTIME"); }
              set { SetDateTime("CURRENTTIME",value); }
          }

          // 返回交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }
          
          // 返回交易序列号
          public string TRADEID2
          {
              get { return  Getstring("TRADEID2"); }
              set { Setstring("TRADEID2",value); }
          }

     }
}


