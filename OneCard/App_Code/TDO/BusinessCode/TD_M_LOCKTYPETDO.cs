using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ��Ƭ�������ͱ����
     public class TD_M_LOCKTYPETDO : DDOBase
     {
          public TD_M_LOCKTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_LOCKTYPE";

               columns = new String[4][];
               columns[0] = new String[]{"LOCKTYPECODE", "string"};
               columns[1] = new String[]{"LOCKTYPE", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "LOCKTYPECODE",
               };


               array = new String[4];
               hash.Add("LOCKTYPECODE", 0);
               hash.Add("LOCKTYPE", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
          }

          // �������ͱ���
          public string LOCKTYPECODE
          {
              get { return  Getstring("LOCKTYPECODE"); }
              set { Setstring("LOCKTYPECODE",value); }
          }

          // ��������
          public String LOCKTYPE
          {
              get { return  GetString("LOCKTYPE"); }
              set { SetString("LOCKTYPE",value); }
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


