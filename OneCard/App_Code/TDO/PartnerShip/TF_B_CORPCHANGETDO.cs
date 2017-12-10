using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ��λ�������ϱ���ӱ�
     public class TF_B_CORPCHANGETDO : DDOBase
     {
          public TF_B_CORPCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_CORPCHANGE";

               columns = new String[10][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CORPNO", "string"};
               columns[2] = new String[]{"CORP", "String"};
               columns[3] = new String[]{"CALLINGNO", "string"};
               columns[4] = new String[]{"SUBCITYNO", "string"};
               columns[5] = new String[]{"CORPADD", "String"};
               columns[6] = new String[]{"CORPMARK", "String"};
               columns[7] = new String[]{"LINKMAN", "String"};
               columns[8] = new String[]{"CORPPHONE", "String"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[10];
               hash.Add("TRADEID", 0);
               hash.Add("CORPNO", 1);
               hash.Add("CORP", 2);
               hash.Add("CALLINGNO", 3);
               hash.Add("SUBCITYNO", 4);
               hash.Add("CORPADD", 5);
               hash.Add("CORPMARK", 6);
               hash.Add("LINKMAN", 7);
               hash.Add("CORPPHONE", 8);
               hash.Add("REMARK", 9);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


