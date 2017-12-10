using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // ��������
     public class SP_GC_AccLockPDO : PDOBase
     {
          public SP_GC_AccLockPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_AccLock",7);

               AddField("@lockType", "string", "1", "input");
               AddField("@cardNo", "String", "16", "input");

               InitEnd();
          }

          // ��������
          public string lockType
          {
              get { return  Getstring("lockType"); }
              set { Setstring("lockType",value); }
          }

          // ��������
          public String cardNo
          {
              get { return  GetString("cardNo"); }
              set { SetString("cardNo",value); }
          }

     }
}


