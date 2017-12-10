using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC���ʽ𷵻��˻����ݱ�
     public class TB_F_CARDRETURNACCTDO : DDOBase
     {
          public TB_F_CARDRETURNACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TB_F_CARDRETURNACC";

               columns = new String[14][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REUSEDATE", "DateTime"};
               columns[2] = new String[]{"TETURNMONEY", "Int32"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"PASSWD", "string"};
               columns[5] = new String[]{"BEGINTIME", "DateTime"};
               columns[6] = new String[]{"ENDTIME", "DateTime"};
               columns[7] = new String[]{"LASUPPLYMONEY", "Int32"};
               columns[8] = new String[]{"LASUPPLYTIME", "DateTime"};
               columns[9] = new String[]{"TOTALRETURNTIMES", "Int32"};
               columns[10] = new String[]{"TOTALRETURNMONEY", "Int32"};
               columns[11] = new String[]{"LASTSUPPLYPOSNO", "string"};
               columns[12] = new String[]{"LASTSUPPLYSAMNO", "string"};
               columns[13] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
                   "REUSEDATE",
               };


               array = new String[14];
               hash.Add("CARDNO", 0);
               hash.Add("REUSEDATE", 1);
               hash.Add("TETURNMONEY", 2);
               hash.Add("USETAG", 3);
               hash.Add("PASSWD", 4);
               hash.Add("BEGINTIME", 5);
               hash.Add("ENDTIME", 6);
               hash.Add("LASUPPLYMONEY", 7);
               hash.Add("LASUPPLYTIME", 8);
               hash.Add("TOTALRETURNTIMES", 9);
               hash.Add("TOTALRETURNMONEY", 10);
               hash.Add("LASTSUPPLYPOSNO", 11);
               hash.Add("LASTSUPPLYSAMNO", 12);
               hash.Add("REMARK", 13);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��������
          public DateTime REUSEDATE
          {
              get { return  GetDateTime("REUSEDATE"); }
              set { SetDateTime("REUSEDATE",value); }
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


