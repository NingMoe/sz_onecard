using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // 更换结算关系
     public class SP_EM_ChangeRelationPDO : PDOBase
     {
          public SP_EM_ChangeRelationPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_EM_ChangeRelation",17);

               AddField("@newPosNo", "string", "6", "input");
               AddField("@oldPosNo", "string", "6", "input");
               AddField("@newPsamNo", "string", "12", "input");
               AddField("@oldPsamNo", "string", "12", "input");
               AddField("@callingNo", "string", "4", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@deptNo", "string", "4", "input");
               AddField("@svcMgrNo", "string", "6", "input");
               AddField("@posSource", "string", "1", "input");
               AddField("@balUnitNo", "string", "8", "input");
               AddField("@UnitNo", "string", "8", "input");
               AddField("@note", "String", "100", "input");
               AddField("@psamType", "String", "1", "input");
               AddField("@isTradeLimit", "String", "1", "input");//是否允许联机消费 add by youyue 20131024

               InitEnd();
          }

          // 新POS编号
          public string newPosNo
          {
              get { return  Getstring("newPosNo"); }
              set { Setstring("newPosNo",value); }
          }

          // 原POS编号
          public string oldPosNo
          {
              get { return  Getstring("oldPosNo"); }
              set { Setstring("oldPosNo",value); }
          }

          // 新PSAM卡号
          public string newPsamNo
          {
              get { return  Getstring("newPsamNo"); }
              set { Setstring("newPsamNo",value); }
          }

          // 原PSAM卡号
          public string oldPsamNo
          {
              get { return  Getstring("oldPsamNo"); }
              set { Setstring("oldPsamNo",value); }
          }

          // 行业编码
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // 单位编码
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // 部门编码
          public string deptNo
          {
              get { return  Getstring("deptNo"); }
              set { Setstring("deptNo",value); }
          }

          // 商户经理编码
          public string svcMgrNo
          {
              get { return  Getstring("svcMgrNo"); }
              set { Setstring("svcMgrNo",value); }
          }

          // POS来源
          public string posSource
          {
              get { return  Getstring("posSource"); }
              set { Setstring("posSource",value); }
          }

          // 结算单元编码
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // 非油品结算单元编码
          public string UnitNo
          {
              get { return Getstring("UnitNo"); }
              set { Setstring("UnitNo", value); }
          }

          // 备注
          public String note
          {
              get { return  GetString("note"); }
              set { SetString("note",value); }
          }

          // psam类型
          public String psamType
          {
              get { return GetString("psamType"); }
              set { SetString("psamType", value); }
          }
          // 是否允许联机消费
          public String isTradeLimit
          {
              get { return GetString("isTradeLimit"); }
              set { SetString("isTradeLimit", value); }
          }

     }
}


