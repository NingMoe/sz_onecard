using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // ������������־��
     public class TF_F_OPERATIONLOGTDO : DDOBase
     {
          public TF_F_OPERATIONLOGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_OPERATIONLOG";

               columns = new String[4][];
               columns[0] = new String[]{"OPERATION_TIME", "DateTime"};
               columns[1] = new String[]{"OPERATESTAFFNO", "string"};
               columns[2] = new String[]{"OPERATION_TYPE", "string"};
               columns[3] = new String[]{"REMARK", "string"};

               columnKeys = new String[]{
                   "OPERATION_TIME",
                   "OPERATESTAFFNO",
               };


               array = new String[4];
               hash.Add("OPERATION_TIME", 0);
               hash.Add("OPERATESTAFFNO", 1);
               hash.Add("OPERATION_TYPE", 2);
               hash.Add("REMARK", 3);
          }

          // ����ʱ��
          public DateTime OPERATION_TIME
          {
              get { return  GetDateTime("OPERATION_TIME"); }
              set { SetDateTime("OPERATION_TIME",value); }
          }

          // ����Ա����
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // �������ͱ���
          public string OPERATION_TYPE
          {
              get { return  Getstring("OPERATION_TYPE"); }
              set { Setstring("OPERATION_TYPE",value); }
          }

          // ������ע
          public string REMARK
          {
              get { return  Getstring("REMARK"); }
              set { Setstring("REMARK",value); }
          }

     }
}


