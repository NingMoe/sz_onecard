using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // �����
     public class SP_UC_StockInPDO : PDOBase
     {
          public SP_UC_StockInPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_StockIn",16);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@cosType", "string", "2", "input");
               AddField("@unitPrice", "Int32", "", "input");
               AddField("@faceType", "string", "4", "input");
               AddField("@cardType", "string", "2", "input");
               AddField("@chipType", "string", "2", "input");
               AddField("@producer", "string", "2", "input");
               AddField("@appVersion", "string", "2", "input");
               AddField("@effDate", "string", "8", "input");
               AddField("@expDate", "string", "8", "input");

               InitEnd();
          }

          // ��ʼ����
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // ��������
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // COS����
          public string cosType
          {
              get { return  Getstring("cosType"); }
              set { Setstring("cosType",value); }
          }

          // ��Ƭ����
          public Int32 unitPrice
          {
              get { return  GetInt32("unitPrice"); }
              set { SetInt32("unitPrice",value); }
          }

          // �������
          public string faceType
          {
              get { return  Getstring("faceType"); }
              set { Setstring("faceType",value); }
          }

          // ��Ƭ����
          public string cardType
          {
              get { return  Getstring("cardType"); }
              set { Setstring("cardType",value); }
          }

          // ��оƬ����
          public string chipType
          {
              get { return  Getstring("chipType"); }
              set { Setstring("chipType",value); }
          }

          // ��Ƭ����
          public string producer
          {
              get { return  Getstring("producer"); }
              set { Setstring("producer",value); }
          }

          // Ӧ�ð汾
          public string appVersion
          {
              get { return  Getstring("appVersion"); }
              set { Setstring("appVersion",value); }
          }

          // ��ʼ��Ч��
          public string effDate
          {
              get { return  Getstring("effDate"); }
              set { Setstring("effDate",value); }
          }

          // ��ֹ��Ч��
          public string expDate
          {
              get { return  Getstring("expDate"); }
              set { Setstring("expDate",value); }
          }

     }
}


