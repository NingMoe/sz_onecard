using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ���ű������ϱ���ӱ�
     public class TF_B_DEPARTCHANGETDO : DDOBase
     {
          public TF_B_DEPARTCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_DEPARTCHANGE";

               columns = new String[8][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"DEPARTNO", "string"};
               columns[2] = new String[]{"DEPART", "String"};
               columns[3] = new String[]{"CORPNO", "string"};
               columns[4] = new String[]{"DPARTMARK", "String"};
               columns[5] = new String[]{"LINKMAN", "String"};
               columns[6] = new String[]{"DEPARTPHONE", "String"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[8];
               hash.Add("TRADEID", 0);
               hash.Add("DEPARTNO", 1);
               hash.Add("DEPART", 2);
               hash.Add("CORPNO", 3);
               hash.Add("DPARTMARK", 4);
               hash.Add("LINKMAN", 5);
               hash.Add("DEPARTPHONE", 6);
               hash.Add("REMARK", 7);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ��������
          public String DEPART
          {
              get { return  GetString("DEPART"); }
              set { SetString("DEPART",value); }
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ����˵��
          public String DPARTMARK
          {
              get { return  GetString("DPARTMARK"); }
              set { SetString("DPARTMARK",value); }
          }

          // ��ϵ��
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // ��ϵ�绰
          public String DEPARTPHONE
          {
              get { return  GetString("DEPARTPHONE"); }
              set { SetString("DEPARTPHONE",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


