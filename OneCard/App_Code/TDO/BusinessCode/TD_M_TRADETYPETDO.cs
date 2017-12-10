using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ҵ�����ͱ����
     public class TD_M_TRADETYPETDO : DDOBase
     {
          public TD_M_TRADETYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_TRADETYPE";

               columns = new String[6][];
               columns[0] = new String[]{"TRADETYPECODE", "string"};
               columns[1] = new String[]{"TRADETYPE", "String"};
               columns[2] = new String[]{"CANCELCODE", "string"};
               columns[3] = new String[]{"CANCANCELTAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "TRADETYPECODE",
               };


               array = new String[6];
               hash.Add("TRADETYPECODE", 0);
               hash.Add("TRADETYPE", 1);
               hash.Add("CANCELCODE", 2);
               hash.Add("CANCANCELTAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ҵ������
          public String TRADETYPE
          {
              get { return  GetString("TRADETYPE"); }
              set { SetString("TRADETYPE",value); }
          }

          // ����ҵ�����ͱ���
          public string CANCELCODE
          {
              get { return  Getstring("CANCELCODE"); }
              set { Setstring("CANCELCODE",value); }
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


