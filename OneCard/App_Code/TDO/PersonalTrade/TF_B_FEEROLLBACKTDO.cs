using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // �ֽ�����Ȩ̨�ʱ�
     public class TF_B_FEEROLLBACKTDO : DDOBase
     {
          public TF_B_FEEROLLBACKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_FEEROLLBACK";

               columns = new String[9][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CANCELTRADEID", "string"};
               columns[2] = new String[]{"CANCELTAG", "string"};
               columns[3] = new String[]{"OPERATESTAFFNO", "string"};
               columns[4] = new String[]{"OPERATEDEPARTID", "string"};
               columns[5] = new String[]{"OPERATETIME", "DateTime"};
               columns[6] = new String[]{"RSRV1", "Int32"};
               columns[7] = new String[]{"RSRV2", "String"};
               columns[8] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[9];
               hash.Add("TRADEID", 0);
               hash.Add("CANCELTRADEID", 1);
               hash.Add("CANCELTAG", 2);
               hash.Add("OPERATESTAFFNO", 3);
               hash.Add("OPERATEDEPARTID", 4);
               hash.Add("OPERATETIME", 5);
               hash.Add("RSRV1", 6);
               hash.Add("RSRV2", 7);
               hash.Add("RSRV3", 8);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ������¼��ˮ��
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // ����״̬
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
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
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


