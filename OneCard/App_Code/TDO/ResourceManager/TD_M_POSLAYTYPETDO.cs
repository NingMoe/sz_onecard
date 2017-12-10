using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS�������ͱ����
     public class TD_M_POSLAYTYPETDO : DDOBase
     {
          public TD_M_POSLAYTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSLAYTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"LAYTYPECODE", "string"};
               columns[1] = new String[]{"LAYTYPE", "String"};
               columns[2] = new String[]{"LAYTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "LAYTYPECODE",
               };


               array = new String[7];
               hash.Add("LAYTYPECODE", 0);
               hash.Add("LAYTYPE", 1);
               hash.Add("LAYTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // POS�������ͱ���
          public string LAYTYPECODE
          {
              get { return  Getstring("LAYTYPECODE"); }
              set { Setstring("LAYTYPECODE",value); }
          }

          // POS��������
          public String LAYTYPE
          {
              get { return  GetString("LAYTYPE"); }
              set { SetString("LAYTYPE",value); }
          }

          // POS��������˵��
          public String LAYTYPENOTE
          {
              get { return  GetString("LAYTYPENOTE"); }
              set { SetString("LAYTYPENOTE",value); }
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


