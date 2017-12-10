using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ��λ�����
     public class TD_M_CORPTDO : DDOBase
     {
          public TD_M_CORPTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CORP";

               columns = new String[12][];
               columns[0] = new String[]{"CORPNO", "string"};
               columns[1] = new String[]{"CORP", "String"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"SUBCITYNO", "string"};
               columns[4] = new String[]{"CORPADD", "String"};
               columns[5] = new String[]{"CORPMARK", "String"};
               columns[6] = new String[]{"LINKMAN", "String"};
               columns[7] = new String[]{"CORPPHONE", "String"};
               columns[8] = new String[]{"USETAG", "string"};
               columns[9] = new String[]{"UPDATESTAFFNO", "string"};
               columns[10] = new String[]{"UPDATETIME", "DateTime"};
               columns[11] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CORPNO",
               };


               array = new String[12];
               hash.Add("CORPNO", 0);
               hash.Add("CORP", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("SUBCITYNO", 3);
               hash.Add("CORPADD", 4);
               hash.Add("CORPMARK", 5);
               hash.Add("LINKMAN", 6);
               hash.Add("CORPPHONE", 7);
               hash.Add("USETAG", 8);
               hash.Add("UPDATESTAFFNO", 9);
               hash.Add("UPDATETIME", 10);
               hash.Add("REMARK", 11);
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ��λ����
          public String CORP
          {
              get { return  GetString("CORP"); }
              set { SetString("CORP",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ���ر���
          public string SUBCITYNO
          {
              get { return  Getstring("SUBCITYNO"); }
              set { Setstring("SUBCITYNO",value); }
          }

          // ��λ��ַ
          public String CORPADD
          {
              get { return  GetString("CORPADD"); }
              set { SetString("CORPADD",value); }
          }

          // ��λ˵��
          public String CORPMARK
          {
              get { return  GetString("CORPMARK"); }
              set { SetString("CORPMARK",value); }
          }

          // ��ϵ��
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // ��ϵ�绰
          public String CORPPHONE
          {
              get { return  GetString("CORPPHONE"); }
              set { SetString("CORPPHONE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


