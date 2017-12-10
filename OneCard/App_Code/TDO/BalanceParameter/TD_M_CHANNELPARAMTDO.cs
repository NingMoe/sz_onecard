using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // ͨ���������ñ�
     public class TD_M_CHANNELPARAMTDO : DDOBase
     {
          public TD_M_CHANNELPARAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CHANNELPARAM";

               columns = new String[6][];
               columns[0] = new String[]{"CHANNELNO", "string"};
               columns[1] = new String[]{"PARAMNO", "string"};
               columns[2] = new String[]{"PARAMNAME", "String"};
               columns[3] = new String[]{"PARAMVALUE", "String"};
               columns[4] = new String[]{"USETAG", "string"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CHANNELNO",
                   "PARAMNO",
               };


               array = new String[6];
               hash.Add("CHANNELNO", 0);
               hash.Add("PARAMNO", 1);
               hash.Add("PARAMNAME", 2);
               hash.Add("PARAMVALUE", 3);
               hash.Add("USETAG", 4);
               hash.Add("REMARK", 5);
          }

          // ͨ������
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
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


