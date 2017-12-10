using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // �˿�
     public class SP_PB_RefundPDO : PDOBase
     {
          public SP_PB_RefundPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Refund",15);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@BACKMONEY", "Int32", "", "input");
               AddField("@BANKCODE", "string", "4", "input");
               AddField("@BANKACCNO", "String", "30", "input");
               AddField("@CUSTNAME", "String", "50", "input");
               AddField("@BACKSLOPE", "Decimal", "10,8", "input");
               AddField("@FACTMONEY", "Int32", "", "input");
               AddField("@TRADEID", "string", "16", "output");

               //add by jiangbb 2012-05-18 �����տ����˻�����
               AddField("@purposeType", "string", "1", "input");
               
               InitEnd();
          }

          //�տ����˻�����
          public string purposeType
          {
              get { return Getstring("purposeType"); }
              set { Setstring("purposeType", value); }
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // �˿���
          public Int32 BACKMONEY
          {
              get { return  GetInt32("BACKMONEY"); }
              set { SetInt32("BACKMONEY",value); }
          }

          // ���б���
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

          // ����
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // ��������
          public Decimal BACKSLOPE
          {
              get { return  GetDecimal("BACKSLOPE"); }
              set { SetDecimal("BACKSLOPE",value); }
          }

          // ʵ���˿���
          public Int32 FACTMONEY
          {
              get { return  GetInt32("FACTMONEY"); }
              set { SetInt32("FACTMONEY",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


