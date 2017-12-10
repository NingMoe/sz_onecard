using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 部门信息修改
     public class SP_PS_DeptInfoChangeModifyPDO : PDOBase
     {
          public SP_PS_DeptInfoChangeModifyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_DeptInfoChangeModify",13);

               AddField("@departNo", "string", "4", "input");
               AddField("@depart", "String", "40", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@dpartMark", "String", "50", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@dpartPhone", "String", "40", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               InitEnd();
          }

          // 部门编码
          public string departNo
          {
              get { return  Getstring("departNo"); }
              set { Setstring("departNo",value); }
          }

          // 部门名称
          public String depart
          {
              get { return  GetString("depart"); }
              set { SetString("depart",value); }
          }

          // 单位编码
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // 部门说明
          public String dpartMark
          {
              get { return  GetString("dpartMark"); }
              set { SetString("dpartMark",value); }
          }

          // 联系人
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // 联系电话
          public String dpartPhone
          {
              get { return  GetString("dpartPhone"); }
              set { SetString("dpartPhone",value); }
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


