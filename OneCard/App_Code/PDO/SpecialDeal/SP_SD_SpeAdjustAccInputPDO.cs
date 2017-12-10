using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
     // �������¼��
     public class SP_SD_SpeAdjustAccInputPDO : PDOBase
     {
          public SP_SD_SpeAdjustAccInputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_SD_SpeAdjustAccInput",12);

               AddField("@ID", "string", "26", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardUser", "String", "50", "input");
               AddField("@userPhone", "String", "40", "input");
               AddField("@refundMoney", "Int32", "", "input");
               AddField("@adjAccReson", "string", "1", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@ReBrokerage", "Int32", "", "input");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // �ֿ����û���
          public String cardUser
          {
              get { return  GetString("cardUser"); }
              set { SetString("cardUser",value); }
          }

          // �ֿ��˵绰
          public String userPhone
          {
              get { return  GetString("userPhone"); }
              set { SetString("userPhone",value); }
          }

          // �˿���
          public Int32 refundMoney
          {
              get { return  GetInt32("refundMoney"); }
              set { SetInt32("refundMoney",value); }
          }

          // ����ԭ��
          public string adjAccReson
          {
              get { return  Getstring("adjAccReson"); }
              set { Setstring("adjAccReson",value); }
          }

          // ����˵��
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // Ӧ�˻��̻�Ӷ��
          public Int32 ReBrokerage
          {
              get { return GetInt32("ReBrokerage"); }
              set { SetInt32("ReBrokerage", value); }
          }

     }
}


