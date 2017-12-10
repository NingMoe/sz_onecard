using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���㵥Ԫ��ӦӶ������ϵ�޸�
     public class SP_PS_BalUnitComSchemeModifyPDO : PDOBase
     {
          public SP_PS_BalUnitComSchemeModifyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_BalUnitComSchemeModify",10);

               AddField("@balUnitNo", "string", "8", "input");
               AddField("@comSchemeNo", "string", "8", "input");
               AddField("@balComsId", "string", "8", "input");
               AddField("@beginTime", "string", "20", "input");
               AddField("@endTime", "string", "20", "input");

               InitEnd();
          }

          // ���㵥Ԫ����
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // Ӷ�𷽰�����
          public string comSchemeNo
          {
              get { return  Getstring("comSchemeNo"); }
              set { Setstring("comSchemeNo",value); }
          }

          // ���㵥Ԫ-Ӷ������ӦID
          public string balComsId
          {
              get { return  Getstring("balComsId"); }
              set { Setstring("balComsId",value); }
          }

          // Ӷ�𷽰���ʼ����
          public string beginTime
          {
              get { return  Getstring("beginTime"); }
              set { Setstring("beginTime",value); }
          }

          // Ӷ�𷽰���ֹ����
          public string endTime
          {
              get { return  Getstring("endTime"); }
              set { Setstring("endTime",value); }
          }

     }
}


