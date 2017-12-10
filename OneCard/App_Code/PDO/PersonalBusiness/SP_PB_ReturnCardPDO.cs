using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // �˿�
     public class SP_PB_ReturnCardPDO : PDOBase
     {
          public SP_PB_ReturnCardPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ReturnCard",22);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@REASONCODE", "string", "2", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@REFUNDMONEY", "Int32", "", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@REFUNDDEPOSIT", "Int32", "", "input");
               AddField("@CHECKSTAFFNO", "string", "6", "input");
               AddField("@CHECKDEPARTNO", "string", "4", "input");
               AddField("@TRADEPROCFEE", "Int32", "", "input");
               AddField("@OTHERFEE", "Int32", "", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
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

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // �����ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // �˿����ͱ���
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // �˳�ֵ
          public Int32 REFUNDMONEY
          {
              get { return  GetInt32("REFUNDMONEY"); }
              set { SetInt32("REFUNDMONEY",value); }
          }

          // �������ȡ��־
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // �˿�Ѻ��
          public Int32 REFUNDDEPOSIT
          {
              get { return  GetInt32("REFUNDDEPOSIT"); }
              set { SetInt32("REFUNDDEPOSIT",value); }
          }

          // ����Ա������
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

          // ҵ��������
          public Int32 TRADEPROCFEE
          {
              get { return  GetInt32("TRADEPROCFEE"); }
              set { SetInt32("TRADEPROCFEE",value); }
          }

          // ��������
          public Int32 OTHERFEE
          {
              get { return  GetInt32("OTHERFEE"); }
              set { SetInt32("OTHERFEE",value); }
          }

          // �ն˺�
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ����Ա����
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


