using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // ��ֵ���ۿ�
     public class SP_CC_SalePDO : PDOBase
     {
          public SP_CC_SalePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_Sale",8);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@remark", "String", "100", "input");

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

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

     }
}


