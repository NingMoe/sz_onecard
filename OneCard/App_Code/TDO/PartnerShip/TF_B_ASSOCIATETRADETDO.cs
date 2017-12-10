using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // �������ҵ��̨������
     public class TF_B_ASSOCIATETRADETDO : DDOBase
     {
          public TF_B_ASSOCIATETRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_ASSOCIATETRADE";

               columns = new String[12][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"ASSOCIATECODE", "String"};
               columns[3] = new String[]{"OPERATESTAFFNO", "string"};
               columns[4] = new String[]{"OPERATEDEPARTID", "string"};
               columns[5] = new String[]{"OPERATETIME", "DateTime"};
               columns[6] = new String[]{"CHECKSTAFFNO", "string"};
               columns[7] = new String[]{"CHECKDEPARTNO", "string"};
               columns[8] = new String[]{"CHECKTIME", "DateTime"};
               columns[9] = new String[]{"STATECODE", "string"};
               columns[10] = new String[]{"CANCELTAG", "string"};
               columns[11] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[12];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("ASSOCIATECODE", 2);
               hash.Add("OPERATESTAFFNO", 3);
               hash.Add("OPERATEDEPARTID", 4);
               hash.Add("OPERATETIME", 5);
               hash.Add("CHECKSTAFFNO", 6);
               hash.Add("CHECKDEPARTNO", 7);
               hash.Add("CHECKTIME", 8);
               hash.Add("STATECODE", 9);
               hash.Add("CANCELTAG", 10);
               hash.Add("RSRV1", 11);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ����������
          public String ASSOCIATECODE
          {
              get { return  GetString("ASSOCIATECODE"); }
              set { SetString("ASSOCIATECODE",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ���ű���
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ��������Ա
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // �������ű���
          public string CHECKDEPARTNO
          {
              get { return  Getstring("CHECKDEPARTNO"); }
              set { Setstring("CHECKDEPARTNO",value); }
          }

          // ����ʱ��
          public DateTime CHECKTIME
          {
              get { return  GetDateTime("CHECKTIME"); }
              set { SetDateTime("CHECKTIME",value); }
          }

          // ״̬����
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // ���˱�־
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

     }
}


