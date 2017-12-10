using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ҵ��д��̨�ʱ�
     public class TF_CARD_RETRADETDO : DDOBase
     {
          public TF_CARD_RETRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARD_RETRADE";

               columns = new String[8][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"OPERATESTAFFNO", "string"};
               columns[4] = new String[]{"OPERATETIME", "DateTime"};
               columns[5] = new String[]{"RSRV1", "String"};
               columns[6] = new String[]{"RSRV2", "String"};
               columns[7] = new String[]{"RSRV3", "DateTime"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[8];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("OPERATESTAFFNO", 3);
               hash.Add("OPERATETIME", 4);
               hash.Add("RSRV1", 5);
               hash.Add("RSRV2", 6);
               hash.Add("RSRV3", 7);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ��д��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

     }
}


