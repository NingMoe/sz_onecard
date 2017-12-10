using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // �۳���㵥Ԫ�����
     public class TF_SELSUP_BALUNITTDO : DDOBase
     {
          public TF_SELSUP_BALUNITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SELSUP_BALUNIT";

               columns = new String[25][];
               columns[0] = new String[]{"BALUNITNO", "string"};
               columns[1] = new String[]{"BALUNIT", "String"};
               columns[2] = new String[]{"BALUNITTYPECODE", "string"};
               columns[3] = new String[]{"CHANNELNO", "string"};
               columns[4] = new String[]{"CALLINGNO", "string"};
               columns[5] = new String[]{"CORPNO", "string"};
               columns[6] = new String[]{"DEPARTNO", "string"};
               columns[7] = new String[]{"BANKCODE", "string"};
               columns[8] = new String[]{"BANKACCNO", "String"};
               columns[9] = new String[]{"CREATETIME", "DateTime"};
               columns[10] = new String[]{"SERMANAGERCODE", "string"};
               columns[11] = new String[]{"BALLEVEL", "string"};
               columns[12] = new String[]{"BALCYCLETYPECODE", "string"};
               columns[13] = new String[]{"BALINTERVAL", "Int32"};
               columns[14] = new String[]{"FINCYCLETYPECODE", "string"};
               columns[15] = new String[]{"FININTERVAL", "Int32"};
               columns[16] = new String[]{"FINTYPECODE", "string"};
               columns[17] = new String[]{"COMFEETAKECODE", "string"};
               columns[18] = new String[]{"FINBANKCODE", "string"};
               columns[19] = new String[]{"LINKMAN", "String"};
               columns[20] = new String[]{"UNITPHONE", "String"};
               columns[21] = new String[]{"UNITADD", "String"};
               columns[22] = new String[]{"UPDATESTAFFNO", "string"};
               columns[23] = new String[]{"UPDATETIME", "DateTime"};
               columns[24] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "BALUNITNO",
               };


               array = new String[25];
               hash.Add("BALUNITNO", 0);
               hash.Add("BALUNIT", 1);
               hash.Add("BALUNITTYPECODE", 2);
               hash.Add("CHANNELNO", 3);
               hash.Add("CALLINGNO", 4);
               hash.Add("CORPNO", 5);
               hash.Add("DEPARTNO", 6);
               hash.Add("BANKCODE", 7);
               hash.Add("BANKACCNO", 8);
               hash.Add("CREATETIME", 9);
               hash.Add("SERMANAGERCODE", 10);
               hash.Add("BALLEVEL", 11);
               hash.Add("BALCYCLETYPECODE", 12);
               hash.Add("BALINTERVAL", 13);
               hash.Add("FINCYCLETYPECODE", 14);
               hash.Add("FININTERVAL", 15);
               hash.Add("FINTYPECODE", 16);
               hash.Add("COMFEETAKECODE", 17);
               hash.Add("FINBANKCODE", 18);
               hash.Add("LINKMAN", 19);
               hash.Add("UNITPHONE", 20);
               hash.Add("UNITADD", 21);
               hash.Add("UPDATESTAFFNO", 22);
               hash.Add("UPDATETIME", 23);
               hash.Add("REMARK", 24);
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ���㵥Ԫ����
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // ��Ԫ���ͱ���
          public string BALUNITTYPECODE
          {
              get { return  Getstring("BALUNITTYPECODE"); }
              set { Setstring("BALUNITTYPECODE",value); }
          }

          // ͨ������
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
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

          // �ͷ��������
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // ���㼶�����
          public string BALLEVEL
          {
              get { return  Getstring("BALLEVEL"); }
              set { Setstring("BALLEVEL",value); }
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

          // Ӷ��ۼ���ʽ����
          public string COMFEETAKECODE
          {
              get { return  Getstring("COMFEETAKECODE"); }
              set { Setstring("COMFEETAKECODE",value); }
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


