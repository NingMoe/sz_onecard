using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // �޸Ŀ�Ѻ��
     public class SP_UC_DepositChangePDO : PDOBase
     {
          public SP_UC_DepositChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_DepositChange",8);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@unitPrice", "Int32", "", "input");

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

          // ��Ƭ����
          public Int32 unitPrice
          {
              get { return  GetInt32("unitPrice"); }
              set { SetInt32("unitPrice",value); }
          }

     }
}


