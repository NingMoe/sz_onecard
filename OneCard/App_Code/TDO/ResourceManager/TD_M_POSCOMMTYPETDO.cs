using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POSͨ�����ͱ����
     public class TD_M_POSCOMMTYPETDO : DDOBase
     {
          public TD_M_POSCOMMTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSCOMMTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"COMMTYPECODE", "string"};
               columns[1] = new String[]{"COMMTYPE", "String"};
               columns[2] = new String[]{"COMMTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "COMMTYPECODE",
               };


               array = new String[7];
               hash.Add("COMMTYPECODE", 0);
               hash.Add("COMMTYPE", 1);
               hash.Add("COMMTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // POSͨ�����ͱ���
          public string COMMTYPECODE
          {
              get { return  Getstring("COMMTYPECODE"); }
              set { Setstring("COMMTYPECODE",value); }
          }

          // POSͨ������
          public String COMMTYPE
          {
              get { return  GetString("COMMTYPE"); }
              set { SetString("COMMTYPE",value); }
          }

          // POSͨ������˵��
          public String COMMTYPENOTE
          {
              get { return  GetString("COMMTYPENOTE"); }
              set { SetString("COMMTYPENOTE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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

     }
}


