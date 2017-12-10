using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 转值
     public class SP_PB_TransitBalancePDO : PDOBase
     {
          public SP_PB_TransitBalancePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_TransitBalance",20);

               AddField("@SESSIONID", "String", "32", "input");
               AddField("@NEWCARDNO", "string", "16", "input");
               AddField("@OLDCARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@NEWCARDACCMONEY", "Int32", "", "input");
               AddField("@CURRENTMONEY", "Int32", "", "input");
               AddField("@OLDCARDACCMONEY", "Int32", "", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CHANGERECORD", "string", "1", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // 会话ID
          public String SESSIONID
          {
              get { return  GetString("SESSIONID"); }
              set { SetString("SESSIONID",value); }
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
          
          // 交易类型
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // 新卡帐户余额
          public Int32 NEWCARDACCMONEY
          {
              get { return  GetInt32("NEWCARDACCMONEY"); }
              set { SetInt32("NEWCARDACCMONEY",value); }
          }

          // 转值金额
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
          }

          // 旧卡帐户余额
          public Int32 OLDCARDACCMONEY
          {
              get { return  GetInt32("OLDCARDACCMONEY"); }
              set { SetInt32("OLDCARDACCMONEY",value); }
          }

          // 新卡卡内余额
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // 新卡应用序列号
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // 联机交易序号
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // 新卡类型
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // 当前转值标志
          public string CHANGERECORD
          {
              get { return  Getstring("CHANGERECORD"); }
              set { Setstring("CHANGERECORD",value); }
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

          // 返回交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


