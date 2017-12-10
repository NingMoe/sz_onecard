using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // �ڲ�Ա�������
     public class TD_M_INSIDESTAFFTDO : DDOBase
     {
          public TD_M_INSIDESTAFFTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDESTAFF";

               columns = new String[9][];
               columns[0] = new String[]{"STAFFNO", "string"};
               columns[1] = new String[]{"STAFFNAME", "String"};
               columns[2] = new String[]{"OPERCARDNO", "string"};
               columns[3] = new String[]{"OPERCARDPWD", "String"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"DIMISSIONTAG", "string"};
               columns[6] = new String[]{"UPDATESTAFFNO", "string"};
               columns[7] = new String[]{"UPDATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "STAFFNO",
               };


               array = new String[9];
               hash.Add("STAFFNO", 0);
               hash.Add("STAFFNAME", 1);
               hash.Add("OPERCARDNO", 2);
               hash.Add("OPERCARDPWD", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("DIMISSIONTAG", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("UPDATETIME", 7);
               hash.Add("REMARK", 8);
          }

          // Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // Ա������
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // Ա������
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // Ա��������
          public String OPERCARDPWD
          {
              get { return  GetString("OPERCARDPWD"); }
              set { SetString("OPERCARDPWD",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ��ְ��־
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
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


