using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // PSAM���
     public class SP_EM_PsamStockInPDO : PDOBase
     {
          public SP_EM_PsamStockInPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_EM_PsamStockIn",17);

               AddField("@prefix", "string", "2", "input");
               AddField("@firstNo", "Decimal", "", "input");
               AddField("@amount", "Int32", "", "input");
               AddField("@length", "Int32", "", "input");
               AddField("@cardKind", "string", "2", "input");
               AddField("@cosType", "string", "2", "input");
               AddField("@appVersion", "string", "2", "input");
               AddField("@cardType", "string", "2", "input");
               AddField("@cardPrice", "Int32", "", "input");
               AddField("@cardManu", "string", "2", "input");
               AddField("@validBeginDate", "string", "8", "input");
               AddField("@validEndDate", "string", "8", "input");

               InitEnd();
          }

          // ����ǰ׺
          public string prefix
          {
              get { return  Getstring("prefix"); }
              set { Setstring("prefix",value); }
          }

          // ��ʼ����
          public Decimal firstNo
          {
              get { return  GetDecimal("firstNo"); }
              set { SetDecimal("firstNo",value); }
          }

          // ������
          public Int32 amount
          {
              get { return  GetInt32("amount"); }
              set { SetInt32("amount",value); }
          }

          // ���ų���
          public Int32 length
          {
              get { return  GetInt32("length"); }
              set { SetInt32("length",value); }
          }

          // ��Ƭ���
          public string cardKind
          {
              get { return  Getstring("cardKind"); }
              set { Setstring("cardKind",value); }
          }

          // COS����
          public string cosType
          {
              get { return  Getstring("cosType"); }
              set { Setstring("cosType",value); }
          }

          // Ӧ�ð汾
          public string appVersion
          {
              get { return  Getstring("appVersion"); }
              set { Setstring("appVersion",value); }
          }

          // ������
          public string cardType
          {
              get { return  Getstring("cardType"); }
              set { Setstring("cardType",value); }
          }

          // ����
          public Int32 cardPrice
          {
              get { return  GetInt32("cardPrice"); }
              set { SetInt32("cardPrice",value); }
          }

          // ��Ƭ����
          public string cardManu
          {
              get { return  Getstring("cardManu"); }
              set { Setstring("cardManu",value); }
          }

          // ��ʼ��Ч��
          public string validBeginDate
          {
              get { return  Getstring("validBeginDate"); }
              set { Setstring("validBeginDate",value); }
          }

          // ��ֹ��Ч��
          public string validEndDate
          {
              get { return  Getstring("validEndDate"); }
              set { Setstring("validEndDate",value); }
          }

     }
}


