using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CountBalance
{
     // �����꿨���ع��˱�
     public class TF_XXPARK_EXCLUDETDO : DDOBase
     {
          public TF_XXPARK_EXCLUDETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XXPARK_EXCLUDE";

               columns = new String[2][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"BATCHNO", "string"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[2];
               hash.Add("ID", 0);
               hash.Add("BATCHNO", 1);
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ���κ�
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

     }
}


