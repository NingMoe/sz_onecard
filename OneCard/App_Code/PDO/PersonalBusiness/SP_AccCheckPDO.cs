using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ���˻���Ч�Լ���
     public class SP_AccCheckPDO : PDOBase
     {
          public SP_AccCheckPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AccCheck",6);

               AddField("@CARDNO", "string", "16", "input");

               InitEnd();
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

     }
}


