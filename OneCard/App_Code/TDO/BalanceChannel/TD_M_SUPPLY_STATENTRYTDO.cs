using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ��ֵͳ������
     public class TD_M_SUPPLY_STATENTRYTDO : DDOBase
     {
          public TD_M_SUPPLY_STATENTRYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SUPPLY_STATENTRY";

               columns = new String[8][];
               columns[0] = new String[]{"ENTRYNO", "string"};
               columns[1] = new String[]{"ENTRYNAME", "String"};
               columns[2] = new String[]{"STATCOLUMN", "string"};
               columns[3] = new String[]{"BALUNITNO", "string"};
               columns[4] = new String[]{"WHERECLAUSE", "String"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ENTRYNO",
               };


               array = new String[8];
               hash.Add("ENTRYNO", 0);
               hash.Add("ENTRYNAME", 1);
               hash.Add("STATCOLUMN", 2);
               hash.Add("BALUNITNO", 3);
               hash.Add("WHERECLAUSE", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // ͳ������
          public string ENTRYNO
          {
              get { return  Getstring("ENTRYNO"); }
              set { Setstring("ENTRYNO",value); }
          }

          // ͳ��������
          public String ENTRYNAME
          {
              get { return  GetString("ENTRYNAME"); }
              set { SetString("ENTRYNAME",value); }
          }

          // ͳ���ֶ�
          public string STATCOLUMN
          {
              get { return  Getstring("STATCOLUMN"); }
              set { Setstring("STATCOLUMN",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ��ѯ����
          public String WHERECLAUSE
          {
              get { return  GetString("WHERECLAUSE"); }
              set { SetString("WHERECLAUSE",value); }
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


