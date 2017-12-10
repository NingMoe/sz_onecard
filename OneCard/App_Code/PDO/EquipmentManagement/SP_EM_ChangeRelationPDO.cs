using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // ���������ϵ
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
               AddField("@isTradeLimit", "String", "1", "input");//�Ƿ������������� add by youyue 20131024

               InitEnd();
          }

          // ��POS���
          public string newPosNo
          {
              get { return  Getstring("newPosNo"); }
              set { Setstring("newPosNo",value); }
          }

          // ԭPOS���
          public string oldPosNo
          {
              get { return  Getstring("oldPosNo"); }
              set { Setstring("oldPosNo",value); }
          }

          // ��PSAM����
          public string newPsamNo
          {
              get { return  Getstring("newPsamNo"); }
              set { Setstring("newPsamNo",value); }
          }

          // ԭPSAM����
          public string oldPsamNo
          {
              get { return  Getstring("oldPsamNo"); }
              set { Setstring("oldPsamNo",value); }
          }

          // ��ҵ����
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // ��λ����
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // ���ű���
          public string deptNo
          {
              get { return  Getstring("deptNo"); }
              set { Setstring("deptNo",value); }
          }

          // �̻��������
          public string svcMgrNo
          {
              get { return  Getstring("svcMgrNo"); }
              set { Setstring("svcMgrNo",value); }
          }

          // POS��Դ
          public string posSource
          {
              get { return  Getstring("posSource"); }
              set { Setstring("posSource",value); }
          }

          // ���㵥Ԫ����
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // ����Ʒ���㵥Ԫ����
          public string UnitNo
          {
              get { return Getstring("UnitNo"); }
              set { Setstring("UnitNo", value); }
          }

          // ��ע
          public String note
          {
              get { return  GetString("note"); }
              set { SetString("note",value); }
          }

          // psam����
          public String psamType
          {
              get { return GetString("psamType"); }
              set { SetString("psamType", value); }
          }
          // �Ƿ�������������
          public String isTradeLimit
          {
              get { return GetString("isTradeLimit"); }
              set { SetString("isTradeLimit", value); }
          }

     }
}


