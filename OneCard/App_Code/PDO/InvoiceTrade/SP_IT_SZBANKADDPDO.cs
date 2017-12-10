using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.InvoiceTrade
{
     // �����洢����
     public class SP_IT_SZBANKADDPDO : PDOBase
     {
          public SP_IT_SZBANKADDPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_IT_SZBANKADD",9);

               AddField("@bankName", "String", "50", "input");
               AddField("@bankCode", "String", "30", "input");
               AddField("@isDefault", "String", "1", "input");
               AddField("@usetag", "String", "1", "input");

               InitEnd();
          }

          // ����������
          public String bankName
          {
              get { return  GetString("bankName"); }
              set { SetString("bankName",value); }
          }

          // �������ʺ�
          public String bankCode
          {
              get { return  GetString("bankCode"); }
              set { SetString("bankCode",value); }
          }

          // �Ƿ�Ĭ��
          public String isDefault
          {
              get { return  GetString("isDefault"); }
              set { SetString("isDefault",value); }
          }

          // ��Ч��ʶ
          public String usetag
          {
              get { return  GetString("usetag"); }
              set { SetString("usetag",value); }
          }

     }
}


