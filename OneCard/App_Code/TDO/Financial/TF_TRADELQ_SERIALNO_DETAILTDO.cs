using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // �̻�ת������ƾ֤��ϸ��
     public class TF_TRADELQ_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TRADELQ_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADELQ_SERIALNO_DETAIL";

               columns = new String[4][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"BALUNIT", "String"};
               columns[2] = new String[]{"FINDATE", "string"};
               columns[3] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[4];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("BALUNIT", 1);
               hash.Add("FINDATE", 2);
               hash.Add("TRANSFEE", 3);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // �̻�����
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // ת������
          public string FINDATE
          {
              get { return  Getstring("FINDATE"); }
              set { Setstring("FINDATE",value); }
          }

          // ת�˽��
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

     }
}


