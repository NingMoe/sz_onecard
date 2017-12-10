using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // �˻���ԭ������
     public class TD_M_REASONTYPETDO : DDOBase
     {
          public TD_M_REASONTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_REASONTYPE";

               columns = new String[5][];
               columns[0] = new String[]{"REASONCODE", "string"};
               columns[1] = new String[]{"REASON", "String"};
               columns[2] = new String[]{"DEPOSITTAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "REASONCODE",
               };


               array = new String[5];
               hash.Add("REASONCODE", 0);
               hash.Add("REASON", 1);
               hash.Add("DEPOSITTAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
          }

          // ԭ�����
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // ԭ������
          public String REASON
          {
              get { return  GetString("REASON"); }
              set { SetString("REASON",value); }
          }

          // Ѻ����ȡ/�˻���־
          public string DEPOSITTAG
          {
              get { return  Getstring("DEPOSITTAG"); }
              set { Setstring("DEPOSITTAG",value); }
          }

          // ����Ա��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

     }
}


