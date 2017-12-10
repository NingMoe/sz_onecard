using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // ���⳵������
     public class SP_TS_ChangeCardPDO : PDOBase
     {
          public SP_TS_ChangeCardPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_TS_ChangeCard",29);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@NewCardNo", "String", "16", "input");
               AddField("@OldCardNo", "String", "16", "input");
               AddField("@CARNO", "string", "8", "input");
               AddField("@strState", "string", "2", "input");
               AddField("@BANKCODE", "string", "4", "input");
               AddField("@BANKACCNO", "String", "20", "input");
               AddField("@STAFFNAME", "String", "20", "input");
               AddField("@STAFFSEX", "string", "1", "input");
               AddField("@STAFFPHONE", "String", "20", "input");
               AddField("@STAFFMOBILE", "String", "15", "input");
               AddField("@STAFFPAPERTYPECODE", "string", "2", "input");
               AddField("@STAFFPAPERNO", "String", "20", "input");
               AddField("@STAFFPOST", "String", "6", "input");
               AddField("@STAFFADDR", "String", "50", "input");
               AddField("@STAFFEMAIL", "String", "30", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DEPARTNO", "string", "4", "input");
               AddField("@POSID", "string", "8", "input");
               AddField("@COLLECTCARDNO", "String", "16", "input");
               AddField("@COLLECTCARDPWD", "String", "8", "input");
               AddField("@DIMISSIONTAG", "string", "1", "input");
               AddField("@REMARK", "String", "100", "input");
               AddField("@operCardNo", "String", "16", "input");

               InitEnd();
          }

          // ��ҵԱ������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // Ա���¿���
          public String NewCardNo
          {
              get { return  GetString("NewCardNo"); }
              set { SetString("NewCardNo",value); }
          }

          // Ա���ɿ���
          public String OldCardNo
          {
              get { return  GetString("OldCardNo"); }
              set { SetString("OldCardNo",value); }
          }

          // ����
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // ˾������ʼ״̬
          public string strState
          {
              get { return  Getstring("strState"); }
              set { Setstring("strState",value); }
          }

          // �������б���
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // �����˺�
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // Ա������
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // Ա���Ա�
          public string STAFFSEX
          {
              get { return  Getstring("STAFFSEX"); }
              set { Setstring("STAFFSEX",value); }
          }

          // Ա����ϵ�绰
          public String STAFFPHONE
          {
              get { return  GetString("STAFFPHONE"); }
              set { SetString("STAFFPHONE",value); }
          }

          // Ա���ƶ��绰
          public String STAFFMOBILE
          {
              get { return  GetString("STAFFMOBILE"); }
              set { SetString("STAFFMOBILE",value); }
          }

          // Ա��֤������
          public string STAFFPAPERTYPECODE
          {
              get { return  Getstring("STAFFPAPERTYPECODE"); }
              set { Setstring("STAFFPAPERTYPECODE",value); }
          }

          // Ա��֤������
          public String STAFFPAPERNO
          {
              get { return  GetString("STAFFPAPERNO"); }
              set { SetString("STAFFPAPERNO",value); }
          }

          // �ʱ��ַ
          public String STAFFPOST
          {
              get { return  GetString("STAFFPOST"); }
              set { SetString("STAFFPOST",value); }
          }

          // Ա����ϵ��ַ
          public String STAFFADDR
          {
              get { return  GetString("STAFFADDR"); }
              set { SetString("STAFFADDR",value); }
          }

          // EMAIL��ַ
          public String STAFFEMAIL
          {
              get { return  GetString("STAFFEMAIL"); }
              set { SetString("STAFFEMAIL",value); }
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

          // POSID
          public string POSID
          {
              get { return  Getstring("POSID"); }
              set { Setstring("POSID",value); }
          }

          // �ɼ�����
          public String COLLECTCARDNO
          {
              get { return  GetString("COLLECTCARDNO"); }
              set { SetString("COLLECTCARDNO",value); }
          }

          // �ɼ�������
          public String COLLECTCARDPWD
          {
              get { return  GetString("COLLECTCARDPWD"); }
              set { SetString("COLLECTCARDPWD",value); }
          }

          // ��ְ��־
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ����Ա����
          public String operCardNo
          {
              get { return  GetString("operCardNo"); }
              set { SetString("operCardNo",value); }
          }

     }
}


