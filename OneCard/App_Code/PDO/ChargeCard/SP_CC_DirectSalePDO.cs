using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // ��ֵ��ֱ��
     public class SP_CC_DirectSalePDO : PDOBase
     {
          public SP_CC_DirectSalePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_DirectSale",12);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@custName", "String", "20", "input");
               AddField("@payMode", "string", "1", "input");
               AddField("@accRecv", "string", "1", "input");
               AddField("@recvDate", "string", "8", "input");
               AddField("@remark", "String", "50", "input");

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

          // �ͻ�����
          public String custName
          {
              get { return  GetString("custName"); }
              set { SetString("custName",value); }
          }

          // ���ʽ
          public string payMode
          {
              get { return  Getstring("payMode"); }
              set { Setstring("payMode",value); }
          }

          // ���ʱ��
          public string accRecv
          {
              get { return  Getstring("accRecv"); }
              set { Setstring("accRecv",value); }
          }

          // ��������
          public string recvDate
          {
              get { return  Getstring("recvDate"); }
              set { Setstring("recvDate",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

     }
}


