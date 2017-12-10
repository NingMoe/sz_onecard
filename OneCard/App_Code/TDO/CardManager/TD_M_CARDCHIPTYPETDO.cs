using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC��оƬ���ͱ����
     public class TD_M_CARDCHIPTYPETDO : DDOBase
     {
          public TD_M_CARDCHIPTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CARDCHIPTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[1] = new String[]{"CARDCHIPTYPENAME", "String"};
               columns[2] = new String[]{"CARDCHIPTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDCHIPTYPECODE",
               };


               array = new String[7];
               hash.Add("CARDCHIPTYPECODE", 0);
               hash.Add("CARDCHIPTYPENAME", 1);
               hash.Add("CARDCHIPTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // ��оƬ���ͱ���
          public string CARDCHIPTYPECODE
          {
              get { return  Getstring("CARDCHIPTYPECODE"); }
              set { Setstring("CARDCHIPTYPECODE",value); }
          }

          // ��оƬ��������
          public String CARDCHIPTYPENAME
          {
              get { return  GetString("CARDCHIPTYPENAME"); }
              set { SetString("CARDCHIPTYPENAME",value); }
          }

          // ��оƬ����˵��
          public String CARDCHIPTYPENOTE
          {
              get { return  GetString("CARDCHIPTYPENOTE"); }
              set { SetString("CARDCHIPTYPENOTE",value); }
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


