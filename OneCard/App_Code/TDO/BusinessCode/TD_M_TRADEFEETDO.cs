using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ǰ̨ҵ���׷��ñ�
     public class TD_M_TRADEFEETDO : DDOBase
     {
          public TD_M_TRADEFEETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_TRADEFEE";

               columns = new String[5][];
               columns[0] = new String[]{"TRADETYPECODE", "string"};
               columns[1] = new String[]{"FEETYPECODE", "string"};
               columns[2] = new String[]{"BASEFEE", "Int32"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "TRADETYPECODE",
                   "FEETYPECODE",
               };


               array = new String[5];
               hash.Add("TRADETYPECODE", 0);
               hash.Add("FEETYPECODE", 1);
               hash.Add("BASEFEE", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // �������ͱ���
          public string FEETYPECODE
          {
              get { return  Getstring("FEETYPECODE"); }
              set { Setstring("FEETYPECODE",value); }
          }

          // ���û���
          public Int32 BASEFEE
          {
              get { return  GetInt32("BASEFEE"); }
              set { SetInt32("BASEFEE",value); }
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


