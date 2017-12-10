using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ��Ʊ���ۿ���������
    public class SP_AS_ZJGMonthlyCardCheckPDO : PDOBase
     {
          public SP_AS_ZJGMonthlyCardCheckPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_AS_ZJGMonthlyCardCheck", 8);
              AddField("@cardNo", "string", "16", "input");
              AddField("@OPERCARDNO", "string", "16", "input");
              AddField("@ENDDATE", "string", "8", "output");
              InitEnd();
          }

          // ����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }
          // ����Ա��
          public string OPERCARDNO
          {
              get { return Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO", value); }
          }
     }
}


