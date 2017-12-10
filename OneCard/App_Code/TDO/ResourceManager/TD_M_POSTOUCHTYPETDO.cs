using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS�Ӵ����ͱ����
     public class TD_M_POSTOUCHTYPETDO : DDOBase
     {
          public TD_M_POSTOUCHTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_POSTOUCHTYPE";

               columns = new String[7][];
               columns[0] = new String[]{"TOUCHTYPECODE", "string"};
               columns[1] = new String[]{"TOUCHTYPE", "String"};
               columns[2] = new String[]{"TOUCHTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "TOUCHTYPECODE",
               };


               array = new String[7];
               hash.Add("TOUCHTYPECODE", 0);
               hash.Add("TOUCHTYPE", 1);
               hash.Add("TOUCHTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("RSRV1", 6);
          }

          // POS�Ӵ����ͱ���
          public string TOUCHTYPECODE
          {
              get { return  Getstring("TOUCHTYPECODE"); }
              set { Setstring("TOUCHTYPECODE",value); }
          }

          // POS�Ӵ�����
          public String TOUCHTYPE
          {
              get { return  GetString("TOUCHTYPE"); }
              set { SetString("TOUCHTYPE",value); }
          }

          // POS�Ӵ�����˵��
          public String TOUCHTYPENOTE
          {
              get { return  GetString("TOUCHTYPENOTE"); }
              set { SetString("TOUCHTYPENOTE",value); }
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


