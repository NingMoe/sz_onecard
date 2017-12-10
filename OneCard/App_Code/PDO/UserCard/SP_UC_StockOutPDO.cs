using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // ������
     public class SP_UC_StockOutPDO : PDOBase
     {
          public SP_UC_StockOutPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_StockOut",11);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@assignedStaff", "string", "6", "input");
               AddField("@serviceCycle", "string", "2", "input");
               AddField("@serviceFee", "Int32", "", "input");
               AddField("@retValMode", "string", "1", "input");

               //�ۿ���ʽ
               AddField("@saleType", "string", "2", "input");
               
               InitEnd();
          }

          //add by jiangbb 2012-05-10
          //�ۿ���ʽ
          public String saleType
          {
              get { return Getstring("saleType"); }
              set { SetString("saleType", value); }
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

          // ����Ա��
          public string assignedStaff
          {
              get { return  Getstring("assignedStaff"); }
              set { Setstring("assignedStaff",value); }
          }

          // ��������
          public string serviceCycle
          {
              get { return  Getstring("serviceCycle"); }
              set { Setstring("serviceCycle",value); }
          }

          // ÿ�ڷ����
          public Int32 serviceFee
          {
              get { return  GetInt32("serviceFee"); }
              set { SetInt32("serviceFee",value); }
          }

          // ��ֵģʽ
          public string retValMode
          {
              get { return  Getstring("retValMode"); }
              set { Setstring("retValMode",value); }
          }

     }
}


