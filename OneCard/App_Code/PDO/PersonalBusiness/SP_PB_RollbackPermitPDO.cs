using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // �ֽ�����Ȩ
     public class SP_PB_RollbackPermitPDO : PDOBase
     {
          public SP_PB_RollbackPermitPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_RollbackPermit",7);

               AddField("@CANCELTRADEID", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ������¼��ˮ��
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


