using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // ��ɫȨ�޶����
     public class TD_M_POWERTDO : DDOBase
     {
          public TD_M_POWERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POWER";

               columns = new String[3][];
               columns[0] = new String[]{"POWERCODE", "string"};
               columns[1] = new String[]{"POWERNAME", "String"};
               columns[2] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "POWERCODE",
               };


               array = new String[3];
               hash.Add("POWERCODE", 0);
               hash.Add("POWERNAME", 1);
               hash.Add("REMARK", 2);
          }

          // Ȩ�ޱ���
          public string POWERCODE
          {
              get { return  Getstring("POWERCODE"); }
              set { Setstring("POWERCODE",value); }
          }

          // Ȩ������
          public String POWERNAME
          {
              get { return  GetString("POWERNAME"); }
              set { SetString("POWERNAME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


