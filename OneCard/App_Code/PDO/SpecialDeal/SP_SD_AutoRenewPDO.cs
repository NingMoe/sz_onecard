using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // �Զ�����
     public class SP_SD_AutoRenewPDO : PDOBase
     {
          public SP_SD_AutoRenewPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_AutoRenew",6);

               AddField("@renewDate", "String", "6", "input");

               InitEnd();
          }

          // ����ʱ��
          public String renewDate
          {
              get { return  GetString("renewDate"); }
              set { SetString("renewDate",value); }
          }

     }
}


