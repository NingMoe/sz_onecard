using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ������㵥Ԫ�����
     public class TF_DEPT_BALUNITTDO : DDOBase
     {
          public TF_DEPT_BALUNITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_DEPT_BALUNIT";

               columns = new String[22][];
               columns[0] = new String[]{"DBALUNITNO", "string"};
               columns[1] = new String[]{"DBALUNIT", "String"};
               columns[2] = new String[]{"BANKCODE", "string"};
               columns[3] = new String[]{"BANKACCNO", "String"};
               columns[4] = new String[]{"CREATETIME", "DateTime"};
               columns[5] = new String[]{"BALCYCLETYPECODE", "string"};
               columns[6] = new String[]{"BALINTERVAL", "Int32"};
               columns[7] = new String[]{"FINCYCLETYPECODE", "string"};
               columns[8] = new String[]{"FININTERVAL", "Int32"};
               columns[9] = new String[]{"FINTYPECODE", "string"};
               columns[10] = new String[]{"FINBANKCODE", "string"};
               columns[11] = new String[]{"LINKMAN", "String"};
               columns[12] = new String[]{"UNITPHONE", "String"};
               columns[13] = new String[]{"UNITADD", "String"};
               columns[14] = new String[]{"UNITEMAIL", "String"};
               columns[15] = new String[]{"USETAG", "string"};
               columns[16] = new String[]{"DEPTTYPE", "string"};
               columns[17] = new String[]{"PREPAYWARNLINE", "Int32"};
               columns[18] = new String[]{"PREPAYLIMITLINE", "Int32"};
               columns[19] = new String[]{"UPDATESTAFFNO", "string"};
               columns[20] = new String[]{"UPDATETIME", "DateTime"};
               columns[21] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DBALUNITNO",
               };


               array = new String[22];
               hash.Add("DBALUNITNO", 0);
               hash.Add("DBALUNIT", 1);
               hash.Add("BANKCODE", 2);
               hash.Add("BANKACCNO", 3);
               hash.Add("CREATETIME", 4);
               hash.Add("BALCYCLETYPECODE", 5);
               hash.Add("BALINTERVAL", 6);
               hash.Add("FINCYCLETYPECODE", 7);
               hash.Add("FININTERVAL", 8);
               hash.Add("FINTYPECODE", 9);
               hash.Add("FINBANKCODE", 10);
               hash.Add("LINKMAN", 11);
               hash.Add("UNITPHONE", 12);
               hash.Add("UNITADD", 13);
               hash.Add("UNITEMAIL", 14);
               hash.Add("USETAG", 15);
               hash.Add("DEPTTYPE", 16);
               hash.Add("PREPAYWARNLINE", 17);
               hash.Add("PREPAYLIMITLINE", 18);
               hash.Add("UPDATESTAFFNO", 19);
               hash.Add("UPDATETIME", 20);
               hash.Add("REMARK", 21);
          }

          // ���㵥Ԫ����
          public string DBALUNITNO
          {
              get { return  Getstring("DBALUNITNO"); }
              set { Setstring("DBALUNITNO",value); }
          }

          // ���㵥Ԫ����
          public String DBALUNIT
          {
              get { return  GetString("DBALUNIT"); }
              set { SetString("DBALUNIT",value); }
          }

          // �������б���
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // �����ʺ�
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // ����ʱ��
          public DateTime CREATETIME
          {
              get { return  GetDateTime("CREATETIME"); }
              set { SetDateTime("CREATETIME",value); }
          }

          // �����������ͱ���
          public string BALCYCLETYPECODE
          {
              get { return  Getstring("BALCYCLETYPECODE"); }
              set { Setstring("BALCYCLETYPECODE",value); }
          }

          // �������ڿ��
          public Int32 BALINTERVAL
          {
              get { return  GetInt32("BALINTERVAL"); }
              set { SetInt32("BALINTERVAL",value); }
          }

          // �����������ͱ���
          public string FINCYCLETYPECODE
          {
              get { return  Getstring("FINCYCLETYPECODE"); }
              set { Setstring("FINCYCLETYPECODE",value); }
          }

          // �������ڿ��
          public Int32 FININTERVAL
          {
              get { return  GetInt32("FININTERVAL"); }
              set { SetInt32("FININTERVAL",value); }
          }

          // ת������
          public string FINTYPECODE
          {
              get { return  Getstring("FINTYPECODE"); }
              set { Setstring("FINTYPECODE",value); }
          }

          // ת�������д���
          public string FINBANKCODE
          {
              get { return  Getstring("FINBANKCODE"); }
              set { Setstring("FINBANKCODE",value); }
          }

          // ��ϵ��
          public String LINKMAN
          {
              get { return  GetString("LINKMAN"); }
              set { SetString("LINKMAN",value); }
          }

          // ��ϵ�绰
          public String UNITPHONE
          {
              get { return  GetString("UNITPHONE"); }
              set { SetString("UNITPHONE",value); }
          }

          // ��ϵ��ַ
          public String UNITADD
          {
              get { return  GetString("UNITADD"); }
              set { SetString("UNITADD",value); }
          }

          // EMAIL��ַ
          public String UNITEMAIL
          {
              get { return  GetString("UNITEMAIL"); }
              set { SetString("UNITEMAIL",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��������
          public string DEPTTYPE
          {
              get { return  Getstring("DEPTTYPE"); }
              set { Setstring("DEPTTYPE",value); }
          }

          // Ԥ����Ԥ��ֵ
          public Int32 PREPAYWARNLINE
          {
              get { return  GetInt32("PREPAYWARNLINE"); }
              set { SetInt32("PREPAYWARNLINE",value); }
          }

          // Ԥ�������ֵ
          public Int32 PREPAYLIMITLINE
          {
              get { return  GetInt32("PREPAYLIMITLINE"); }
              set { SetInt32("PREPAYLIMITLINE",value); }
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


