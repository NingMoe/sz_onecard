using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // �������ͱ����
     public class TD_M_FEETYPETDO : DDOBase
     {
          public TD_M_FEETYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_FEETYPE";

               columns = new String[4][];
               columns[0] = new String[]{"FEETYPECODE", "string"};
               columns[1] = new String[]{"FEETYPENAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "FEETYPECODE",
               };


               array = new String[4];
               hash.Add("FEETYPECODE", 0);
               hash.Add("FEETYPENAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
          }

          // �������ͱ���
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // ������������
          public String FEETYPENAME
          {
              get { return  GetString("FEETYPENAME"); }
              set { SetString("FEETYPENAME",value); }
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


