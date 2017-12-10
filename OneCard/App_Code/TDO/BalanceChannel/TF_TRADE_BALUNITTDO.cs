using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ���ѽ��㵥Ԫ�����
     public class TF_TRADE_BALUNITTDO : DDOBase
     {
          public TF_TRADE_BALUNITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADE_BALUNIT";

               columns = new String[29][];
               columns[0] = new String[]{"BALUNITNO", "string"};
               columns[1] = new String[]{"BALUNIT", "String"};
               columns[2] = new String[]{"BALUNITTYPECODE", "string"};
               columns[3] = new String[]{"CHANNELNO", "string"};
               columns[4] = new String[]{"SOURCETYPECODE", "string"};
               columns[5] = new String[]{"CALLINGNO", "string"};
               columns[6] = new String[]{"CORPNO", "string"};
               columns[7] = new String[]{"DEPARTNO", "string"};
               columns[8] = new String[]{"CALLINGSTAFFNO", "string"};
               columns[9] = new String[]{"BANKCODE", "string"};
               columns[10] = new String[]{"BANKACCNO", "String"};
               columns[11] = new String[]{"CREATETIME", "DateTime"};
               columns[12] = new String[]{"SERMANAGERCODE", "string"};
               columns[13] = new String[]{"BALLEVEL", "string"};
               columns[14] = new String[]{"BALCYCLETYPECODE", "string"};
               columns[15] = new String[]{"BALINTERVAL", "Int32"};
               columns[16] = new String[]{"FINCYCLETYPECODE", "string"};
               columns[17] = new String[]{"FININTERVAL", "Int32"};
               columns[18] = new String[]{"FINTYPECODE", "string"};
               columns[19] = new String[]{"COMFEETAKECODE", "string"};
               columns[20] = new String[]{"FINBANKCODE", "string"};
               columns[21] = new String[]{"LINKMAN", "String"};
               columns[22] = new String[]{"UNITPHONE", "String"};
               columns[23] = new String[]{"UNITADD", "String"};
               columns[24] = new String[]{"UNITEMAIL", "String"};
               columns[25] = new String[]{"USETAG", "string"};
               columns[26] = new String[]{"UPDATESTAFFNO", "string"};
               columns[27] = new String[]{"UPDATETIME", "DateTime"};
               columns[28] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "BALUNITNO",
               };


               array = new String[29];
               hash.Add("BALUNITNO", 0);
               hash.Add("BALUNIT", 1);
               hash.Add("BALUNITTYPECODE", 2);
               hash.Add("CHANNELNO", 3);
               hash.Add("SOURCETYPECODE", 4);
               hash.Add("CALLINGNO", 5);
               hash.Add("CORPNO", 6);
               hash.Add("DEPARTNO", 7);
               hash.Add("CALLINGSTAFFNO", 8);
               hash.Add("BANKCODE", 9);
               hash.Add("BANKACCNO", 10);
               hash.Add("CREATETIME", 11);
               hash.Add("SERMANAGERCODE", 12);
               hash.Add("BALLEVEL", 13);
               hash.Add("BALCYCLETYPECODE", 14);
               hash.Add("BALINTERVAL", 15);
               hash.Add("FINCYCLETYPECODE", 16);
               hash.Add("FININTERVAL", 17);
               hash.Add("FINTYPECODE", 18);
               hash.Add("COMFEETAKECODE", 19);
               hash.Add("FINBANKCODE", 20);
               hash.Add("LINKMAN", 21);
               hash.Add("UNITPHONE", 22);
               hash.Add("UNITADD", 23);
               hash.Add("UNITEMAIL", 24);
               hash.Add("USETAG", 25);
               hash.Add("UPDATESTAFFNO", 26);
               hash.Add("UPDATETIME", 27);
               hash.Add("REMARK", 28);
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

          // ��Դʶ�����ͱ���
          public string SOURCETYPECODE
          {
              get { return  Getstring("SOURCETYPECODE"); }
              set { Setstring("SOURCETYPECODE",value); }
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

          // ��ҵԱ������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
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


