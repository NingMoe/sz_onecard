using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC����������
     public class TD_M_CARDSURFACETDO : DDOBase
     {
          public TD_M_CARDSURFACETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CARDSURFACE";

               columns = new String[7][];
               columns[0] = new String[]{"CARDSURFACECODE", "string"};
               columns[1] = new String[]{"CARDSURFACENAME", "String"};
               columns[2] = new String[]{"CARDSURFACENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDSURFACECODE",
               };


               array = new String[7];
               hash.Add("CARDSURFACECODE", 0);
               hash.Add("CARDSURFACENAME", 1);
               hash.Add("CARDSURFACENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // �������
          public string CARDSURFACECODE
          {
              get { return  Getstring("CARDSURFACECODE"); }
              set { Setstring("CARDSURFACECODE",value); }
          }

          // ��������
          public String CARDSURFACENAME
          {
              get { return  GetString("CARDSURFACENAME"); }
              set { SetString("CARDSURFACENAME",value); }
          }

          // ����˵��
          public String CARDSURFACENOTE
          {
              get { return  GetString("CARDSURFACENOTE"); }
              set { SetString("CARDSURFACENOTE",value); }
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


