using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ҵ�������Ʊ����
     public class TD_M_FUNCTIONTDO : DDOBase
     {
          public TD_M_FUNCTIONTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_FUNCTION";

               columns = new String[4][];
               columns[0] = new String[]{"FUNCTIONTYPE", "string"};
               columns[1] = new String[]{"FUNCTIONNAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "FUNCTIONTYPE",
               };


               array = new String[4];
               hash.Add("FUNCTIONTYPE", 0);
               hash.Add("FUNCTIONNAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
          }

          // ���ܱ���
          public string FUNCTIONTYPE
          {
              get { return  Getstring("FUNCTIONTYPE"); }
              set { Setstring("FUNCTIONTYPE",value); }
          }

          // ��������
          public String FUNCTIONNAME
          {
              get { return  GetString("FUNCTIONNAME"); }
              set { SetString("FUNCTIONNAME",value); }
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


