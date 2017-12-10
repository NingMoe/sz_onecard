using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // ��ֵ�쳣��Ϣ����
     public class SP_SD_SupplyErrRecPDO : PDOBase
     {
          public SP_SD_SupplyErrRecPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SupplyErrRec",8);

               AddField("@renewRemark", "String", "150", "input");
               AddField("@billMonth", "string", "2", "input");
               AddField("@sessionID", "String", "32", "input");

               InitEnd();
          }

          // ����˵��
          public String renewRemark
          {
              get { return  GetString("renewRemark"); }
              set { SetString("renewRemark",value); }
          }

          // �����嵥�·�
          public string billMonth
          {
              get { return  Getstring("billMonth"); }
              set { Setstring("billMonth",value); }
          }

          // �ỰID
          public String sessionID
          {
              get { return  GetString("sessionID"); }
              set { SetString("sessionID",value); }
          }

     }
}


