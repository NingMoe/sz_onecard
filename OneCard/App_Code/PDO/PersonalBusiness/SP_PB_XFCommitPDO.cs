using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // 充值卡提交
     public class SP_PB_XFCommitPDO : PDOBase
     {
          public SP_PB_XFCommitPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_XFCommit",12);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@PASSWD", "string", "32", "input");
               AddField("@XFCARDNO", "string", "14", "output");
               AddField("@sMONEY", "Int32", "", "output");
               AddField("@CURRENTTIME", "DateTime", "", "output");
               AddField("@TRADEID", "string", "16", "input");
               AddField("@TERMNO", "string", "12", "input");

               InitEnd();
          }

          // 卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 充值卡密码
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // 充值卡卡号
          public string XFCARDNO
          {
              get { return  Getstring("XFCARDNO"); }
              set { Setstring("XFCARDNO",value); }
          }

          // 充值卡金额
          public Int32 sMONEY
          {
              get { return  GetInt32("sMONEY"); }
              set { SetInt32("sMONEY",value); }
          }

          // 返回系统时间
          public DateTime CURRENTTIME
          {
              get { return  GetDateTime("CURRENTTIME"); }
              set { SetDateTime("CURRENTTIME",value); }
          }

          // 交易序列号
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // 终端号
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

     }
}


