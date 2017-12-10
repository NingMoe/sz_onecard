using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // �������ͱ����
     public class TD_M_FUNCTIONTYPETDO : DDOBase
     {
          public TD_M_FUNCTIONTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_FUNCTIONTYPE";

               columns = new String[5][];
               columns[0] = new String[]{"FUNCTIONTYPECODE", "string"};
               columns[1] = new String[]{"FUNCTIONTYPE", "String"};
               columns[2] = new String[]{"CANCANCELTAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "FUNCTIONTYPECODE",
               };


               array = new String[5];
               hash.Add("FUNCTIONTYPECODE", 0);
               hash.Add("FUNCTIONTYPE", 1);
               hash.Add("CANCANCELTAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
          }

          // �������ͱ���
          public string FUNCTIONTYPECODE
          {
              get { return  Getstring("FUNCTIONTYPECODE"); }
              set { Setstring("FUNCTIONTYPECODE",value); }
          }

          // ��������
          public String FUNCTIONTYPE
          {
              get { return  GetString("FUNCTIONTYPE"); }
              set { SetString("FUNCTIONTYPE",value); }
          }

          // ҵ����˱�־
          public string CANCANCELTAG
          {
              get { return  Getstring("CANCANCELTAG"); }
              set { Setstring("CANCANCELTAG",value); }
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


