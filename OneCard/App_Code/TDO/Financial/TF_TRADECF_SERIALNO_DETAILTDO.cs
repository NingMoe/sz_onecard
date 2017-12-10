using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // �̻�Ӷ��ƾ֤��ϸ��
     public class TF_TRADECF_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_TRADECF_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TRADECF_SERIALNO_DETAIL";

               columns = new String[8][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"SERMANAGERCODE", "string"};
               columns[2] = new String[]{"CALLING", "String"};
               columns[3] = new String[]{"CORP", "String"};
               columns[4] = new String[]{"DEPART", "String"};
               columns[5] = new String[]{"SLOPE", "String"};
               columns[6] = new String[]{"FINFEE", "Int32"};
               columns[7] = new String[]{"COMFEE", "Int32"};

               columnKeys = new String[]{
               };


               array = new String[8];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("SERMANAGERCODE", 1);
               hash.Add("CALLING", 2);
               hash.Add("CORP", 3);
               hash.Add("DEPART", 4);
               hash.Add("SLOPE", 5);
               hash.Add("FINFEE", 6);
               hash.Add("COMFEE", 7);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // �̻�����
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

          // ��ҵ����
          public String CALLING
          {
              get { return  GetString("CALLING"); }
              set { SetString("CALLING",value); }
          }

          // ��λ����
          public String CORP
          {
              get { return  GetString("CORP"); }
              set { SetString("CORP",value); }
          }

          // ��������
          public String DEPART
          {
              get { return  GetString("DEPART"); }
              set { SetString("DEPART",value); }
          }

          // Ӷ�����
          public String SLOPE
          {
              get { return  GetString("SLOPE"); }
              set { SetString("SLOPE",value); }
          }

          // �����ܽ��
          public Int32 FINFEE
          {
              get { return  GetInt32("FINFEE"); }
              set { SetInt32("FINFEE",value); }
          }

          // Ӷ���ܶ�
          public Int32 COMFEE
          {
              get { return  GetInt32("COMFEE"); }
              set { SetInt32("COMFEE",value); }
          }

     }
}


