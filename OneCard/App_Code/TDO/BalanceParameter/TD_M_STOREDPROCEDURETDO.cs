using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // �ս��½�洢�������ñ�
     public class TD_M_STOREDPROCEDURETDO : DDOBase
     {
          public TD_M_STOREDPROCEDURETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_STOREDPROCEDURE";

               columns = new String[5][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"NAME", "String"};
               columns[2] = new String[]{"JOBNO", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[5];
               hash.Add("ID", 0);
               hash.Add("NAME", 1);
               hash.Add("JOBNO", 2);
               hash.Add("USETAG", 3);
               hash.Add("REMARK", 4);
          }

          // ���̱��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ��������
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // ������
          public string JOBNO
          {
              get { return  Getstring("JOBNO"); }
              set { Setstring("JOBNO",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


