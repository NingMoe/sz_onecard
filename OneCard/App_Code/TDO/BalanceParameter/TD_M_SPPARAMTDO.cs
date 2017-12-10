using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // �ս��½�洢���̲������ñ�
     public class TD_M_SPPARAMTDO : DDOBase
     {
          public TD_M_SPPARAMTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SPPARAM";

               columns = new String[8][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"NAME", "String"};
               columns[2] = new String[]{"SPID", "string"};
               columns[3] = new String[]{"VALUE", "String"};
               columns[4] = new String[]{"NOINSP", "Int32"};
               columns[5] = new String[]{"DATATYPE", "Int32"};
               columns[6] = new String[]{"USETAG", "string"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[8];
               hash.Add("ID", 0);
               hash.Add("NAME", 1);
               hash.Add("SPID", 2);
               hash.Add("VALUE", 3);
               hash.Add("NOINSP", 4);
               hash.Add("DATATYPE", 5);
               hash.Add("USETAG", 6);
               hash.Add("REMARK", 7);
          }

          // �������
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ��������
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // �洢���̱��
          public string SPID
          {
              get { return  Getstring("SPID"); }
              set { Setstring("SPID",value); }
          }

          // ����ֵ
          public String VALUE
          {
              get { return  GetString("VALUE"); }
              set { SetString("VALUE",value); }
          }

          // �������
          public Int32 NOINSP
          {
              get { return  GetInt32("NOINSP"); }
              set { SetInt32("NOINSP",value); }
          }

          // ��������
          public Int32 DATATYPE
          {
              get { return  GetInt32("DATATYPE"); }
              set { SetInt32("DATATYPE",value); }
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


