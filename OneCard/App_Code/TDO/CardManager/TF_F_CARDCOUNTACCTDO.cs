using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC����Ʊ�ƴ��˻���
     public class TF_F_CARDCOUNTACCTDO : DDOBase
     {
          public TF_F_CARDCOUNTACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDCOUNTACC";

               columns = new String[20][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"APPTYPE", "string"};
               columns[2] = new String[]{"ASSIGNEDAREA", "string"};
               columns[3] = new String[]{"APPTIME", "DateTime"};
               columns[4] = new String[]{"APPSTAFFNO", "string"};
               columns[5] = new String[]{"LASTAUDIT", "string"};
               columns[6] = new String[]{"LASTAUDITTIME", "DateTime"};
               columns[7] = new String[]{"LASTAUDITSTAFFNO", "string"};
               columns[8] = new String[]{"USETAG", "string"};
               columns[9] = new String[]{"ENDTIME", "string"};
               columns[10] = new String[]{"TOTALPAYTIMES", "Int32"};
               columns[11] = new String[]{"TOTALTIMES", "Int32"};
               columns[12] = new String[]{"SPARETIMES", "Int32"};
               columns[13] = new String[]{"TOTALCOUNT", "Int32"};
               columns[14] = new String[]{"UPDATESTAFFNO", "string"};
               columns[15] = new String[]{"UPDATETIME", "DateTime"};
               columns[16] = new String[]{"RSRV1", "Int32"};
               columns[17] = new String[]{"RSRV2", "String"};
               columns[18] = new String[]{"RSRV3", "DateTime"};
               columns[19] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[20];
               hash.Add("CARDNO", 0);
               hash.Add("APPTYPE", 1);
               hash.Add("ASSIGNEDAREA", 2);
               hash.Add("APPTIME", 3);
               hash.Add("APPSTAFFNO", 4);
               hash.Add("LASTAUDIT", 5);
               hash.Add("LASTAUDITTIME", 6);
               hash.Add("LASTAUDITSTAFFNO", 7);
               hash.Add("USETAG", 8);
               hash.Add("ENDTIME", 9);
               hash.Add("TOTALPAYTIMES", 10);
               hash.Add("TOTALTIMES", 11);
               hash.Add("SPARETIMES", 12);
               hash.Add("TOTALCOUNT", 13);
               hash.Add("UPDATESTAFFNO", 14);
               hash.Add("UPDATETIME", 15);
               hash.Add("RSRV1", 16);
               hash.Add("RSRV2", 17);
               hash.Add("RSRV3", 18);
               hash.Add("REMARK", 19);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��Ʊ����
          public string APPTYPE
          {
              get { return  Getstring("APPTYPE"); }
              set { Setstring("APPTYPE",value); }
          }

          // ��������
          public string ASSIGNEDAREA
          {
              get { return  Getstring("ASSIGNEDAREA"); }
              set { Setstring("ASSIGNEDAREA",value); }
          }

          // ����Ʊʱ��
          public DateTime APPTIME
          {
              get { return  GetDateTime("APPTIME"); }
              set { SetDateTime("APPTIME",value); }
          }

          // ����ƱԱ��
          public string APPSTAFFNO
          {
              get { return  Getstring("APPSTAFFNO"); }
              set { Setstring("APPSTAFFNO",value); }
          }

          // ����־
          public string LASTAUDIT
          {
              get { return  Getstring("LASTAUDIT"); }
              set { Setstring("LASTAUDIT",value); }
          }

          // ���ʱ��
          public DateTime LASTAUDITTIME
          {
              get { return  GetDateTime("LASTAUDITTIME"); }
              set { SetDateTime("LASTAUDITTIME",value); }
          }

          // ���Ա��
          public string LASTAUDITSTAFFNO
          {
              get { return  Getstring("LASTAUDITSTAFFNO"); }
              set { Setstring("LASTAUDITSTAFFNO",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��������
          public string ENDTIME
          {
              get { return  Getstring("ENDTIME"); }
              set { Setstring("ENDTIME",value); }
          }

          // �ܽɷѴ���
          public Int32 TOTALPAYTIMES
          {
              get { return  GetInt32("TOTALPAYTIMES"); }
              set { SetInt32("TOTALPAYTIMES",value); }
          }

          // �ܿ��ô���
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // ʣ����ô���
          public Int32 SPARETIMES
          {
              get { return  GetInt32("SPARETIMES"); }
              set { SetInt32("SPARETIMES",value); }
          }

          // �ۼƴ���
          public Int32 TOTALCOUNT
          {
              get { return  GetInt32("TOTALCOUNT"); }
              set { SetInt32("TOTALCOUNT",value); }
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

          // ����1
          public Int32 RSRV1
          {
              get { return  GetInt32("RSRV1"); }
              set { SetInt32("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


