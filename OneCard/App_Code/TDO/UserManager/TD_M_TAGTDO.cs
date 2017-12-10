using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // ϵͳ������
     public class TD_M_TAGTDO : DDOBase
     {
          public TD_M_TAGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_TAG";

               columns = new String[7][];
               columns[0] = new String[]{"TAGCODE", "string"};
               columns[1] = new String[]{"TAGNAME", "String"};
               columns[2] = new String[]{"TAGVALUE", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TAGCODE",
               };


               array = new String[7];
               hash.Add("TAGCODE", 0);
               hash.Add("TAGNAME", 1);
               hash.Add("TAGVALUE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // ��������
          public string TAGCODE
          {
              get { return  Getstring("TAGCODE"); }
              set { Setstring("TAGCODE",value); }
          }

          // ��������
          public String TAGNAME
          {
              get { return  GetString("TAGNAME"); }
              set { SetString("TAGNAME",value); }
          }

          // ����ֵ
          public string TAGVALUE
          {
              get { return  Getstring("TAGVALUE"); }
              set { Setstring("TAGVALUE",value); }
          }

          // ��Ч��ʶ
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


