using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // ��ֵ�ȶ�������Ϣ����
     public class SP_SD_SupplyDiffErrRecPDO : PDOBase
     {
          public SP_SD_SupplyDiffErrRecPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SupplyDiffErrRec",7);

               AddField("@renewRemark", "String", "150", "input");
               AddField("@sessionID", "String", "32", "input");

               InitEnd();
          }

          // ����˵��
          public String renewRemark
          {
              get { return  GetString("renewRemark"); }
              set { SetString("renewRemark",value); }
          }

          // �ỰID
          public String sessionID
          {
              get { return  GetString("sessionID"); }
              set { SetString("sessionID",value); }
          }

     }
}


