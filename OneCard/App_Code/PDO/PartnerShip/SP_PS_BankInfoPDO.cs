using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // �������б���
     public class SP_PS_BankInfoPDO : PDOBase
     {
          public SP_PS_BankInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_BankInfo",9);

               AddField("@BankCode", "string", "4", "input");
               AddField("@Bank", "String", "200", "input");
               AddField("@BankAddr", "String", "50", "input");
               AddField("@BankPhone", "String", "20", "input");

               InitEnd();
          }

          // ���б���
          public string BankCode
          {
              get { return  Getstring("BankCode"); }
              set { Setstring("BankCode",value); }
          }

          // ��������
          public String Bank
          {
              get { return  GetString("Bank"); }
              set { SetString("Bank",value); }
          }

          // ���е�ַ
          public String BankAddr
          {
              get { return  GetString("BankAddr"); }
              set { SetString("BankAddr",value); }
          }

          // ��ϵ��ʽ
          public String BankPhone
          {
              get { return  GetString("BankPhone"); }
              set { SetString("BankPhone",value); }
          }

     }
}


