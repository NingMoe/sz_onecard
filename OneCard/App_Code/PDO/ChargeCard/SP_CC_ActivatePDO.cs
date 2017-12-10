using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.ChargeCard
{
     // ��ֵ�������ر�
     public class SP_CC_ActivatePDO : PDOBase
     {
          public SP_CC_ActivatePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_CC_Activate",9);

               AddField("@fromCardNo", "String", "14", "input");
               AddField("@toCardNo", "String", "14", "input");
               AddField("@stateCode", "string", "1", "input");
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

          // ״̬����
          public string stateCode
          {
              get { return  Getstring("stateCode"); }
              set { Setstring("stateCode",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

     }
}


