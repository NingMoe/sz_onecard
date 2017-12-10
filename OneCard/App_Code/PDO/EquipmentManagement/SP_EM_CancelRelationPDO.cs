using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // ��ֹ�����ϵ
     public class SP_EM_CancelRelationPDO : PDOBase
     {
          public SP_EM_CancelRelationPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_EM_CancelRelation",14);

               AddField("@posNo", "string", "6", "input");
               AddField("@psamNo", "string", "12", "input");
               AddField("@callingNo", "string", "4", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@deptNo", "string", "4", "input");
               AddField("@svcMgrNo", "string", "6", "input");
               AddField("@posSource", "string", "1", "input");
               AddField("@balUnitNo", "string", "8", "input");
               AddField("@note", "String", "100", "input");

               InitEnd();
          }

          // POS���
          public string posNo
          {
              get { return  Getstring("posNo"); }
              set { Setstring("posNo",value); }
          }

          // PSAM����
          public string psamNo
          {
              get { return  Getstring("psamNo"); }
              set { Setstring("psamNo",value); }
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

          // ��ע
          public String note
          {
              get { return  GetString("note"); }
              set { SetString("note",value); }
          }

     }
}


