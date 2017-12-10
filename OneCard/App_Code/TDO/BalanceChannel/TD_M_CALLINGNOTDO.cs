using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ��ҵ�����
     public class TD_M_CALLINGNOTDO : DDOBase
     {
          public TD_M_CALLINGNOTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CALLINGNO";

               columns = new String[7][];
               columns[0] = new String[]{"CALLINGNO", "string"};
               columns[1] = new String[]{"CALLING", "String"};
               columns[2] = new String[]{"ISOPEN", "string"};
               columns[3] = new String[]{"CALLINGMARK", "String"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CALLINGNO",
               };


               array = new String[7];
               hash.Add("CALLINGNO", 0);
               hash.Add("CALLING", 1);
               hash.Add("ISOPEN", 2);
               hash.Add("CALLINGMARK", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��ҵ����
          public String CALLING
          {
              get { return  GetString("CALLING"); }
              set { SetString("CALLING",value); }
          }

          // �Ƿ�ͨ
          public string ISOPEN
          {
              get { return  Getstring("ISOPEN"); }
              set { Setstring("ISOPEN",value); }
          }

          // ��ҵ˵��
          public String CALLINGMARK
          {
              get { return  GetString("CALLINGMARK"); }
              set { SetString("CALLINGMARK",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


