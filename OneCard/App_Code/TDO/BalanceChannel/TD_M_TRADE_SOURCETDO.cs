using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ���ѽ�����Դʶ������
     public class TD_M_TRADE_SOURCETDO : DDOBase
     {
          public TD_M_TRADE_SOURCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_TRADE_SOURCE";

               columns = new String[6][];
               columns[0] = new String[]{"SOURCECODE", "String"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "SOURCECODE",
               };


               array = new String[6];
               hash.Add("SOURCECODE", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("USETAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // ��Դʶ�����
          public String SOURCECODE
          {
              get { return  GetString("SOURCECODE"); }
              set { SetString("SOURCECODE",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


