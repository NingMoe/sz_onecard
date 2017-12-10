using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // ���⳵ת������ƾ֤��ϸ��
     public class TF_TAXILQ_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TAXILQ_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TAXILQ_SERIALNO_DETAIL";

               columns = new String[3][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"FINDATE", "string"};
               columns[2] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[3];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("FINDATE", 1);
               hash.Add("TRANSFEE", 2);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
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


