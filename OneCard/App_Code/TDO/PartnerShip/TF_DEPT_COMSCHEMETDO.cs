using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ����Ӷ�𷽰������
     public class TF_DEPT_COMSCHEMETDO : DDOBase
     {
          public TF_DEPT_COMSCHEMETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_DEPT_COMSCHEME";

               columns = new String[8][];
               columns[0] = new String[]{"DCOMSCHEMENO", "string"};
               columns[1] = new String[]{"NAME", "String"};
               columns[2] = new String[]{"TYPECODE", "string"};
               columns[3] = new String[]{"DATACODE", "string"};
               columns[4] = new String[]{"USETAG", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DCOMSCHEMENO",
               };


               array = new String[8];
               hash.Add("DCOMSCHEMENO", 0);
               hash.Add("NAME", 1);
               hash.Add("TYPECODE", 2);
               hash.Add("DATACODE", 3);
               hash.Add("USETAG", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // ��������
          public string DCOMSCHEMENO
          {
              get { return  Getstring("DCOMSCHEMENO"); }
              set { Setstring("DCOMSCHEMENO",value); }
          }

          // ������
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // �������ͱ���
          public string TYPECODE
          {
              get { return  Getstring("TYPECODE"); }
              set { Setstring("TYPECODE",value); }
          }

          // �������ͱ���
          public string DATACODE
          {
              get { return  Getstring("DATACODE"); }
              set { Setstring("DATACODE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ����Ա��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


