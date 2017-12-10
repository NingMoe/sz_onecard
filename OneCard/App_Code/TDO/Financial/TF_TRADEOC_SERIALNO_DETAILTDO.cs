using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // �̻�ת��ƾ֤��ϸ��
     public class TF_TRADEOC_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TRADEOC_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADEOC_SERIALNO_DETAIL";

               columns = new String[5][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"BANK", "String"};
               columns[2] = new String[]{"FINANCENO", "string"};
               columns[3] = new String[]{"BALUNIT", "String"};
               columns[4] = new String[]{"TRANSFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("BANK", 1);
               hash.Add("FINANCENO", 2);
               hash.Add("BALUNIT", 3);
               hash.Add("TRANSFEE", 4);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // ת����
          public String BANK
          {
              get { return  GetString("BANK"); }
              set { SetString("BANK",value); }
          }

          // �̻�����
          public string FINANCENO
          {
              get { return  Getstring("FINANCENO"); }
              set { Setstring("FINANCENO",value); }
          }

          // �̻�����
          public String BALUNIT
          {
              get { return  GetString("BALUNIT"); }
              set { SetString("BALUNIT",value); }
          }

          // ת�˽��
          public Int32 TRANSFEE
          {
              get { return  GetInt32("TRANSFEE"); }
              set { SetInt32("TRANSFEE",value); }
          }

     }
}


