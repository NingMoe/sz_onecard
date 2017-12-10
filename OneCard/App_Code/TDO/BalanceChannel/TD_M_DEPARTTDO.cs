using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ���ű����
     public class TD_M_DEPARTTDO : DDOBase
     {
          public TD_M_DEPARTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_DEPART";

               columns = new String[10][];
               columns[0] = new String[]{"DEPARTNO", "string"};
               columns[1] = new String[]{"DEPART", "String"};
               columns[2] = new String[]{"CORPNO", "string"};
               columns[3] = new String[]{"DPARTMARK", "String"};
               columns[4] = new String[]{"LINKMAN", "String"};
               columns[5] = new String[]{"DEPARTPHONE", "String"};
               columns[6] = new String[]{"USETAG", "string"};
               columns[7] = new String[]{"UPDATESTAFFNO", "string"};
               columns[8] = new String[]{"UPDATETIME", "DateTime"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DEPARTNO",
               };


               array = new String[10];
               hash.Add("DEPARTNO", 0);
               hash.Add("DEPART", 1);
               hash.Add("CORPNO", 2);
               hash.Add("DPARTMARK", 3);
               hash.Add("LINKMAN", 4);
               hash.Add("DEPARTPHONE", 5);
               hash.Add("USETAG", 6);
               hash.Add("UPDATESTAFFNO", 7);
               hash.Add("UPDATETIME", 8);
               hash.Add("REMARK", 9);
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


