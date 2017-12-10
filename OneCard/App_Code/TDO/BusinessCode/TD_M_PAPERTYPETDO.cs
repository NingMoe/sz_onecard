using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ֤�����ͱ����
     public class TD_M_PAPERTYPETDO : DDOBase
     {
          public TD_M_PAPERTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_PAPERTYPE";

               columns = new String[4][];
               columns[0] = new String[]{"PAPERTYPECODE", "string"};
               columns[1] = new String[]{"PAPERTYPENAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "PAPERTYPECODE",
               };


               array = new String[4];
               hash.Add("PAPERTYPECODE", 0);
               hash.Add("PAPERTYPENAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
          }

          // ֤�����ͱ���
          public string PAPERTYPECODE
          {
              get { return  Getstring("PAPERTYPECODE"); }
              set { Setstring("PAPERTYPECODE",value); }
          }

          // ֤������
          public String PAPERTYPENAME
          {
              get { return  GetString("PAPERTYPENAME"); }
              set { SetString("PAPERTYPENAME",value); }
          }

          // Ա������
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


