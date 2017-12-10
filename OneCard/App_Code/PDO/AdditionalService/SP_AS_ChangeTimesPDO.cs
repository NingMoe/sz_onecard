using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ��Ʊ���ۿ���������
     public class SP_AS_ChangeTimesPDO : PDOBase
     {
          public SP_AS_ChangeTimesPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_ChangeTimes",8);

               AddField("@cardNo", "string", "16", "input");
               AddField("@gardenTimes", "Int32", "", "input");
               AddField("@relaxTimes", "Int32", "", "input");
               AddField("@wujlvyouTimes", "Int32", "", "input");

               InitEnd();
          }

          // ����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // ԰�ִ���
          public Int32 gardenTimes
          {
              get { return  GetInt32("gardenTimes"); }
              set { SetInt32("gardenTimes",value); }
          }

          // ���д���
          public Int32 relaxTimes
          {
              get { return  GetInt32("relaxTimes"); }
              set { SetInt32("relaxTimes",value); }
          }

        // �⽭�����꿨���� add by liuhe20120507
        public Int32 wujlvyouTimes
        {
          get { return GetInt32("wujlvyouTimes"); }
          set { SetInt32("wujlvyouTimes", value); }
        }

     }
}


