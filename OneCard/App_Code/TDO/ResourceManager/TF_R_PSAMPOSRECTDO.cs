using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS��SAM����Ӧ��ϵ��
     public class TF_R_PSAMPOSRECTDO : DDOBase
     {
          public TF_R_PSAMPOSRECTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_R_PSAMPOSREC";

               columns = new String[18][];
               columns[0] = new String[]{"SAMNO", "string"};
               columns[1] = new String[]{"POSNO", "string"};
               columns[2] = new String[]{"BALUNITNO", "string"};
               columns[3] = new String[]{"USETYPECODE", "string"};
               columns[4] = new String[]{"CALLINGNO", "string"};
               columns[5] = new String[]{"CORPNO", "string"};
               columns[6] = new String[]{"DEPARTNO", "string"};
               columns[7] = new String[]{"SERMANAGERCODE", "string"};
               columns[8] = new String[]{"TAKETIME", "DateTime"};
               columns[9] = new String[]{"POSDEPOSIT", "Int32"};
               columns[10] = new String[]{"DEPREBEGINTIME", "DateTime"};
               columns[11] = new String[]{"DEPREMONTHS", "Int32"};
               columns[12] = new String[]{"SAMDEPOSIT", "Int32"};
               columns[13] = new String[]{"VALIDBEGINDATE", "string"};
               columns[14] = new String[]{"VALIDENDDATE", "string"};
               columns[15] = new String[]{"UPDATESTAFFNO", "string"};
               columns[16] = new String[]{"UPDATETIME", "DateTime"};
               columns[17] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "SAMNO",
               };


               array = new String[18];
               hash.Add("SAMNO", 0);
               hash.Add("POSNO", 1);
               hash.Add("BALUNITNO", 2);
               hash.Add("USETYPECODE", 3);
               hash.Add("CALLINGNO", 4);
               hash.Add("CORPNO", 5);
               hash.Add("DEPARTNO", 6);
               hash.Add("SERMANAGERCODE", 7);
               hash.Add("TAKETIME", 8);
               hash.Add("POSDEPOSIT", 9);
               hash.Add("DEPREBEGINTIME", 10);
               hash.Add("DEPREMONTHS", 11);
               hash.Add("SAMDEPOSIT", 12);
               hash.Add("VALIDBEGINDATE", 13);
               hash.Add("VALIDENDDATE", 14);
               hash.Add("UPDATESTAFFNO", 15);
               hash.Add("UPDATETIME", 16);
               hash.Add("REMARK", 17);
          }

          // SAM���
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // POS���
          public string POSNO
          {
              get { return  Getstring("POSNO"); }
              set { Setstring("POSNO",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // POS��Դ
          public string USETYPECODE
          {
              get { return  Getstring("USETYPECODE"); }
              set { Setstring("USETYPECODE",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // �̻��������
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // ��������
          public DateTime TAKETIME
          {
              get { return  GetDateTime("TAKETIME"); }
              set { SetDateTime("TAKETIME",value); }
          }

          // POSѺ��
          public Int32 POSDEPOSIT
          {
              get { return  GetInt32("POSDEPOSIT"); }
              set { SetInt32("POSDEPOSIT",value); }
          }

          // ��ʼ�۾�ʱ��
          public DateTime DEPREBEGINTIME
          {
              get { return  GetDateTime("DEPREBEGINTIME"); }
              set { SetDateTime("DEPREBEGINTIME",value); }
          }

          // �۾�ʱ��
          public Int32 DEPREMONTHS
          {
              get { return  GetInt32("DEPREMONTHS"); }
              set { SetInt32("DEPREMONTHS",value); }
          }

          // SAMѺ��
          public Int32 SAMDEPOSIT
          {
              get { return  GetInt32("SAMDEPOSIT"); }
              set { SetInt32("SAMDEPOSIT",value); }
          }

          // ��ʼ��Ч��
          public string VALIDBEGINDATE
          {
              get { return  Getstring("VALIDBEGINDATE"); }
              set { Setstring("VALIDBEGINDATE",value); }
          }

          // ��ֹ��Ч��
          public string VALIDENDDATE
          {
              get { return  Getstring("VALIDENDDATE"); }
              set { Setstring("VALIDENDDATE",value); }
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


