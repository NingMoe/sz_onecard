using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // ��Ʊ���ͺ����������Ӧ��ϵ�����
     public class TD_M_APPAREATDO : DDOBase
     {
          public TD_M_APPAREATDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_APPAREA";

               columns = new String[6][];
               columns[0] = new String[]{"APPTYPE", "string"};
               columns[1] = new String[]{"AREACODE", "string"};
               columns[2] = new String[]{"FLAG", "string"};
               columns[3] = new String[]{"AREANAME", "String"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "APPTYPE",
                   "AREACODE",
               };


               array = new String[6];
               hash.Add("APPTYPE", 0);
               hash.Add("AREACODE", 1);
               hash.Add("FLAG", 2);
               hash.Add("AREANAME", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
          }

          // ��Ʊ����
          public string APPTYPE
          {
              get { return  Getstring("APPTYPE"); }
              set { Setstring("APPTYPE",value); }
          }

          // �����������
          public string AREACODE
          {
              get { return  Getstring("AREACODE"); }
              set { Setstring("AREACODE",value); }
          }

          // �¾ɱ�ʶ
          public string FLAG
          {
              get { return  Getstring("FLAG"); }
              set { Setstring("FLAG",value); }
          }

          // ������������
          public String AREANAME
          {
              get { return  GetString("AREANAME"); }
              set { SetString("AREANAME",value); }
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


