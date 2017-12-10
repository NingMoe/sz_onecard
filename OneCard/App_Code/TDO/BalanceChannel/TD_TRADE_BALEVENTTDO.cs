using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ���ѽ�����Ϣ����¼���
     public class TD_TRADE_BALEVENTTDO : DDOBase
     {
          public TD_TRADE_BALEVENTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_TRADE_BALEVENT";

               columns = new String[9][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"EVENTTYPECODE", "string"};
               columns[2] = new String[]{"BALUNITNO", "string"};
               columns[3] = new String[]{"PARAM1", "String"};
               columns[4] = new String[]{"PARAM2", "String"};
               columns[5] = new String[]{"DEALSTATECODE1", "string"};
               columns[6] = new String[]{"DEALSTATECODE2", "string"};
               columns[7] = new String[]{"OCCURTIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[9];
               hash.Add("ID", 0);
               hash.Add("EVENTTYPECODE", 1);
               hash.Add("BALUNITNO", 2);
               hash.Add("PARAM1", 3);
               hash.Add("PARAM2", 4);
               hash.Add("DEALSTATECODE1", 5);
               hash.Add("DEALSTATECODE2", 6);
               hash.Add("OCCURTIME", 7);
               hash.Add("REMARK", 8);
          }

          // �¼���ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // �¼����ͱ���
          public string EVENTTYPECODE
          {
              get { return  Getstring("EVENTTYPECODE"); }
              set { Setstring("EVENTTYPECODE",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ����1
          public String PARAM1
          {
              get { return  GetString("PARAM1"); }
              set { SetString("PARAM1",value); }
          }

          // ����2
          public String PARAM2
          {
              get { return  GetString("PARAM2"); }
              set { SetString("PARAM2",value); }
          }

          // ����״̬1
          public string DEALSTATECODE1
          {
              get { return  Getstring("DEALSTATECODE1"); }
              set { Setstring("DEALSTATECODE1",value); }
          }

          // ����״̬2
          public string DEALSTATECODE2
          {
              get { return  Getstring("DEALSTATECODE2"); }
              set { Setstring("DEALSTATECODE2",value); }
          }

          // ����ʱ��
          public DateTime OCCURTIME
          {
              get { return  GetDateTime("OCCURTIME"); }
              set { SetDateTime("OCCURTIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


