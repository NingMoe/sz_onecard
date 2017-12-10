using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // �ͷ��۳�ƾ֤��ϸ��
     public class TF_SERVICE_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_SERVICE_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SERVICE_SERIALNO_DETAIL";

               columns = new String[5][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"SERVICEDATE", "string"};
               columns[2] = new String[]{"UNITNAME", "String"};
               columns[3] = new String[]{"FEETYPENAME", "String"};
               columns[4] = new String[]{"SERVICEFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("SERVICEDATE", 1);
               hash.Add("UNITNAME", 2);
               hash.Add("FEETYPENAME", 3);
               hash.Add("SERVICEFEE", 4);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // �۳�����
          public string SERVICEDATE
          {
              get { return  Getstring("SERVICEDATE"); }
              set { Setstring("SERVICEDATE",value); }
          }

          // �ͷ�����
          public String UNITNAME
          {
              get { return  GetString("UNITNAME"); }
              set { SetString("UNITNAME",value); }
          }

          // ��������
          public String FEETYPENAME
          {
              get { return  GetString("FEETYPENAME"); }
              set { SetString("FEETYPENAME",value); }
          }

          // �۳���
          public Int32 SERVICEFEE
          {
              get { return  GetInt32("SERVICEFEE"); }
              set { SetInt32("SERVICEFEE",value); }
          }

     }
}


