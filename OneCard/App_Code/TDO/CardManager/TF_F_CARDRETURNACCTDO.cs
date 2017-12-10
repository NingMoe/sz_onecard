using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC���ʽ𷵻��˻���
     public class TF_F_CARDRETURNACCTDO : DDOBase
     {
          public TF_F_CARDRETURNACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDRETURNACC";

               columns = new String[13][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"TETURNMONEY", "Int32"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"PASSWD", "string"};
               columns[4] = new String[]{"BEGINTIME", "DateTime"};
               columns[5] = new String[]{"ENDTIME", "DateTime"};
               columns[6] = new String[]{"LASUPPLYMONEY", "Int32"};
               columns[7] = new String[]{"LASUPPLYTIME", "DateTime"};
               columns[8] = new String[]{"TOTALRETURNTIMES", "Int32"};
               columns[9] = new String[]{"TOTALRETURNMONEY", "Int32"};
               columns[10] = new String[]{"LASTSUPPLYPOSNO", "string"};
               columns[11] = new String[]{"LASTSUPPLYSAMNO", "string"};
               columns[12] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[13];
               hash.Add("CARDNO", 0);
               hash.Add("TETURNMONEY", 1);
               hash.Add("USETAG", 2);
               hash.Add("PASSWD", 3);
               hash.Add("BEGINTIME", 4);
               hash.Add("ENDTIME", 5);
               hash.Add("LASUPPLYMONEY", 6);
               hash.Add("LASUPPLYTIME", 7);
               hash.Add("TOTALRETURNTIMES", 8);
               hash.Add("TOTALRETURNMONEY", 9);
               hash.Add("LASTSUPPLYPOSNO", 10);
               hash.Add("LASTSUPPLYSAMNO", 11);
               hash.Add("REMARK", 12);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �������
          public Int32 TETURNMONEY
          {
              get { return  GetInt32("TETURNMONEY"); }
              set { SetInt32("TETURNMONEY",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��ֵ����
          public string PASSWD
          {
              get { return  Getstring("PASSWD"); }
              set { Setstring("PASSWD",value); }
          }

          // ��Ч��ʼ����
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // ��Ч��������
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // ���ʵ�ʳ�ֵ���
          public Int32 LASUPPLYMONEY
          {
              get { return  GetInt32("LASUPPLYMONEY"); }
              set { SetInt32("LASUPPLYMONEY",value); }
          }

          // ���ʵ�ʳ�ֵʱ��
          public DateTime LASUPPLYTIME
          {
              get { return  GetDateTime("LASUPPLYTIME"); }
              set { SetDateTime("LASUPPLYTIME",value); }
          }

          // �ܷ�������
          public Int32 TOTALRETURNTIMES
          {
              get { return  GetInt32("TOTALRETURNTIMES"); }
              set { SetInt32("TOTALRETURNTIMES",value); }
          }

          // �ܷ������
          public Int32 TOTALRETURNMONEY
          {
              get { return  GetInt32("TOTALRETURNMONEY"); }
              set { SetInt32("TOTALRETURNMONEY",value); }
          }

          // ���ʵ�ʳ�ֵPOS���
          public string LASTSUPPLYPOSNO
          {
              get { return  Getstring("LASTSUPPLYPOSNO"); }
              set { Setstring("LASTSUPPLYPOSNO",value); }
          }

          // ���ʵ�ʳ�ֵPSAM���
          public string LASTSUPPLYSAMNO
          {
              get { return  Getstring("LASTSUPPLYSAMNO"); }
              set { Setstring("LASTSUPPLYSAMNO",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


