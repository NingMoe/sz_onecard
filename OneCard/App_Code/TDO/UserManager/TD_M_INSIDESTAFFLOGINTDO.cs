using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // �ڲ�Ա����¼���Ʊ�
     public class TD_M_INSIDESTAFFLOGINTDO : DDOBase
     {
          public TD_M_INSIDESTAFFLOGINTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDESTAFFLOGIN";

               columns = new String[9][];
               columns[0] = new String[]{"STAFFNO", "string"};
               columns[1] = new String[]{"IPADDR", "String"};
               columns[2] = new String[]{"STARTDATE", "string"};
               columns[3] = new String[]{"ENDDATE", "string"};
               columns[4] = new String[]{"STARTTIME", "string"};
               columns[5] = new String[]{"ENDTIME", "string"};
               columns[6] = new String[]{"VALIDTAG", "string"};
               columns[7] = new String[]{"UPDATESTAFFNO", "string"};
               columns[8] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "STAFFNO",
                   "IPADDR",
               };


               array = new String[9];
               hash.Add("STAFFNO", 0);
               hash.Add("IPADDR", 1);
               hash.Add("STARTDATE", 2);
               hash.Add("ENDDATE", 3);
               hash.Add("STARTTIME", 4);
               hash.Add("ENDTIME", 5);
               hash.Add("VALIDTAG", 6);
               hash.Add("UPDATESTAFFNO", 7);
               hash.Add("UPDATETIME", 8);
          }

          // Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // �����¼IP��ַ
          public String IPADDR
          {
              get { return  GetString("IPADDR"); }
              set { SetString("IPADDR",value); }
          }

          // �����¼��ʼ����
          public string STARTDATE
          {
              get { return  Getstring("STARTDATE"); }
              set { Setstring("STARTDATE",value); }
          }

          // �����¼��ֹ����
          public string ENDDATE
          {
              get { return  Getstring("ENDDATE"); }
              set { Setstring("ENDDATE",value); }
          }

          // �����¼��ʼʱ��
          public string STARTTIME
          {
              get { return  Getstring("STARTTIME"); }
              set { Setstring("STARTTIME",value); }
          }

          // �����¼��ֹʱ��
          public string ENDTIME
          {
              get { return  Getstring("ENDTIME"); }
              set { Setstring("ENDTIME",value); }
          }

          // ��Ч��־
          public string VALIDTAG
          {
              get { return  Getstring("VALIDTAG"); }
              set { Setstring("VALIDTAG",value); }
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


