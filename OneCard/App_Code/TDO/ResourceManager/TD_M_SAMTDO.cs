using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // ��ֵSAM����Դ��
     public class TD_M_SAMTDO : DDOBase
     {
          public TD_M_SAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SAM";

               columns = new String[10][];
               columns[0] = new String[]{"SAMNO", "string"};
               columns[1] = new String[]{"VERNO", "string"};
               columns[2] = new String[]{"CALLINGNO", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"DEPARTNO", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"RSRV1", "String"};
               columns[8] = new String[]{"RSRV2", "String"};
               columns[9] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "SAMNO",
               };


               array = new String[10];
               hash.Add("SAMNO", 0);
               hash.Add("VERNO", 1);
               hash.Add("CALLINGNO", 2);
               hash.Add("USETAG", 3);
               hash.Add("DEPARTNO", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("RSRV1", 7);
               hash.Add("RSRV2", 8);
               hash.Add("RSRV3", 9);
          }

          // ��ֵSAM����
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // �汾��
          public string VERNO
          {
              get { return  Getstring("VERNO"); }
              set { Setstring("VERNO",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ����Ա������
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
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


