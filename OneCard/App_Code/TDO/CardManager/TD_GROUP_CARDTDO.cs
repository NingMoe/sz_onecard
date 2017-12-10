using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // ���ſͻ�-�������Ӧ��ϵ��
     public class TD_GROUP_CARDTDO : DDOBase
     {
          public TD_GROUP_CARDTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_GROUP_CARD";

               columns = new String[6][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"CORPNO", "string"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "CORPNO",
               };


               array = new String[6];
               hash.Add("CARDNO", 0);
               hash.Add("CORPNO", 1);
               hash.Add("USETAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ���ſͻ�����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
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


