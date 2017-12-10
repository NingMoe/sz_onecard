using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // �̻�Ӷ��ƾ֤���״̬��
     public class TF_TRADECF_SERIALNO_STATUSTDO : DDOBase
     {
          public TF_TRADECF_SERIALNO_STATUSTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADECF_SERIALNO_STATUS";

               columns = new String[2][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"DEALSTATECODE", "string"};

               columnKeys = new String[]{
                   "FIANCE_SERIALNO",
               };


               array = new String[2];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("DEALSTATECODE", 1);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // ����״̬��
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

     }
}


