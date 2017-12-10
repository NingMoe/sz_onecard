using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 集团客户信息修改
     public class SP_PS_GroupCustChangePDO : PDOBase
     {
          public SP_PS_GroupCustChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_GroupCustChange",14);

               AddField("@corpCode", "string", "4", "input");
               AddField("@corpName", "String", "50", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@corpAdd", "String", "40", "input");
               AddField("@corpPhone", "String", "100", "input");
               AddField("@serManagerCode", "string", "6", "input");
               AddField("@corpEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               InitEnd();
          }

          // 集团客户编码
          public string corpCode
          {
              get { return  Getstring("corpCode"); }
              set { Setstring("corpCode",value); }
          }

          // 集团客户名称
          public String corpName
          {
              get { return  GetString("corpName"); }
              set { SetString("corpName",value); }
          }

          // 联系人
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // 联系地址
          public String corpAdd
          {
              get { return  GetString("corpAdd"); }
              set { SetString("corpAdd",value); }
          }

          // 联系电话
          public String corpPhone
          {
              get { return  GetString("corpPhone"); }
              set { SetString("corpPhone",value); }
          }

          // 客服经理编码
          public string serManagerCode
          {
              get { return  Getstring("serManagerCode"); }
              set { Setstring("serManagerCode",value); }
          }

          // 电子邮件
          public String corpEmail
          {
              get { return  GetString("corpEmail"); }
              set { SetString("corpEmail",value); }
          }

          // 备注
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // 有效标志
          public string useTag
          {
              get { return  Getstring("useTag"); }
              set { Setstring("useTag",value); }
          }

     }
}


