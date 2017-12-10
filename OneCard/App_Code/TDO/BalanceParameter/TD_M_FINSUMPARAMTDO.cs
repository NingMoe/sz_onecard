using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // ת�����ʲ������ñ�
     public class TD_M_FINSUMPARAMTDO : DDOBase
     {
          public TD_M_FINSUMPARAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_FINSUMPARAM";

               columns = new String[6][];
               columns[0] = new String[]{"CHNLTYPE", "string"};
               columns[1] = new String[]{"PARAMNO", "string"};
               columns[2] = new String[]{"PARAMNAME", "String"};
               columns[3] = new String[]{"PARAMVALUE", "String"};
               columns[4] = new String[]{"USETAG", "string"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CHNLTYPE",
                   "PARAMNO",
               };


               array = new String[6];
               hash.Add("CHNLTYPE", 0);
               hash.Add("PARAMNO", 1);
               hash.Add("PARAMNAME", 2);
               hash.Add("PARAMVALUE", 3);
               hash.Add("USETAG", 4);
               hash.Add("REMARK", 5);
          }

          // ͨ������
          public string CHNLTYPE
          {
              get { return  Getstring("CHNLTYPE"); }
              set { Setstring("CHNLTYPE",value); }
          }

          // ��������
          public string PARAMNO
          {
              get { return  Getstring("PARAMNO"); }
              set { Setstring("PARAMNO",value); }
          }

          // ������
          public String PARAMNAME
          {
              get { return  GetString("PARAMNAME"); }
              set { SetString("PARAMNAME",value); }
          }

          // ����ֵ
          public String PARAMVALUE
          {
              get { return  GetString("PARAMVALUE"); }
              set { SetString("PARAMVALUE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


