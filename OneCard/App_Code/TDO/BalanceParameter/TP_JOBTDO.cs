using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // ������ȹ����
     public class TP_JOBTDO : DDOBase
     {
          public TP_JOBTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_JOB";

               columns = new String[16][];
               columns[0] = new String[]{"JOBNO", "string"};
               columns[1] = new String[]{"PROGNO", "String"};
               columns[2] = new String[]{"PROGTYPE", "string"};
               columns[3] = new String[]{"CHNLNO", "String"};
               columns[4] = new String[]{"NAME", "String"};
               columns[5] = new String[]{"PREJOBNO", "string"};
               columns[6] = new String[]{"NEXTJOBNO", "string"};
               columns[7] = new String[]{"RUNSTATE", "string"};
               columns[8] = new String[]{"TRIGGERTYPE", "string"};
               columns[9] = new String[]{"TRIGGERVALUE", "String"};
               columns[10] = new String[]{"EXECSTATE", "string"};
               columns[11] = new String[]{"EXECDESC", "String"};
               columns[12] = new String[]{"PREEXECTIME", "DateTime"};
               columns[13] = new String[]{"NEXTEXECTIME", "DateTime"};
               columns[14] = new String[]{"REALEXECTIME", "DateTime"};
               columns[15] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "JOBNO",
               };


               array = new String[16];
               hash.Add("JOBNO", 0);
               hash.Add("PROGNO", 1);
               hash.Add("PROGTYPE", 2);
               hash.Add("CHNLNO", 3);
               hash.Add("NAME", 4);
               hash.Add("PREJOBNO", 5);
               hash.Add("NEXTJOBNO", 6);
               hash.Add("RUNSTATE", 7);
               hash.Add("TRIGGERTYPE", 8);
               hash.Add("TRIGGERVALUE", 9);
               hash.Add("EXECSTATE", 10);
               hash.Add("EXECDESC", 11);
               hash.Add("PREEXECTIME", 12);
               hash.Add("NEXTEXECTIME", 13);
               hash.Add("REALEXECTIME", 14);
               hash.Add("REMARK", 15);
          }

          // ������
          public string JOBNO
          {
              get { return  Getstring("JOBNO"); }
              set { Setstring("JOBNO",value); }
          }

          // ������
          public String PROGNO
          {
              get { return  GetString("PROGNO"); }
              set { SetString("PROGNO",value); }
          }

          // ��������
          public string PROGTYPE
          {
              get { return  Getstring("PROGTYPE"); }
              set { Setstring("PROGTYPE",value); }
          }

          // ͨ�����
          public String CHNLNO
          {
              get { return  GetString("CHNLNO"); }
              set { SetString("CHNLNO",value); }
          }

          // ��������
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // ǰ��������
          public string PREJOBNO
          {
              get { return  Getstring("PREJOBNO"); }
              set { Setstring("PREJOBNO",value); }
          }

          // ����������
          public string NEXTJOBNO
          {
              get { return  Getstring("NEXTJOBNO"); }
              set { Setstring("NEXTJOBNO",value); }
          }

          // ����״̬
          public string RUNSTATE
          {
              get { return  Getstring("RUNSTATE"); }
              set { Setstring("RUNSTATE",value); }
          }

          // ������ʽ
          public string TRIGGERTYPE
          {
              get { return  Getstring("TRIGGERTYPE"); }
              set { Setstring("TRIGGERTYPE",value); }
          }

          // ��������
          public String TRIGGERVALUE
          {
              get { return  GetString("TRIGGERVALUE"); }
              set { SetString("TRIGGERVALUE",value); }
          }

          // ִ�н��
          public string EXECSTATE
          {
              get { return  Getstring("EXECSTATE"); }
              set { Setstring("EXECSTATE",value); }
          }

          // ִ�н������
          public String EXECDESC
          {
              get { return  GetString("EXECDESC"); }
              set { SetString("EXECDESC",value); }
          }

          // �ϴ�ִ��ʱ��
          public DateTime PREEXECTIME
          {
              get { return  GetDateTime("PREEXECTIME"); }
              set { SetDateTime("PREEXECTIME",value); }
          }

          // �´�ִ��ʱ��
          public DateTime NEXTEXECTIME
          {
              get { return  GetDateTime("NEXTEXECTIME"); }
              set { SetDateTime("NEXTEXECTIME",value); }
          }

          // �ϴ�ʵ��ִ��ʱ��
          public DateTime REALEXECTIME
          {
              get { return  GetDateTime("REALEXECTIME"); }
              set { SetDateTime("REALEXECTIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


