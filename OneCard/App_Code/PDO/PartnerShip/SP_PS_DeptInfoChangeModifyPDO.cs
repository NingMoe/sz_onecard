using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ������Ϣ�޸�
     public class SP_PS_DeptInfoChangeModifyPDO : PDOBase
     {
          public SP_PS_DeptInfoChangeModifyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_DeptInfoChangeModify",13);

               AddField("@departNo", "string", "4", "input");
               AddField("@depart", "String", "40", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@dpartMark", "String", "50", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@dpartPhone", "String", "40", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               InitEnd();
          }

          // ���ű���
          public string departNo
          {
              get { return  Getstring("departNo"); }
              set { Setstring("departNo",value); }
          }

          // ��������
          public String depart
          {
              get { return  GetString("depart"); }
              set { SetString("depart",value); }
          }

          // ��λ����
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // ����˵��
          public String dpartMark
          {
              get { return  GetString("dpartMark"); }
              set { SetString("dpartMark",value); }
          }

          // ��ϵ��
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // ��ϵ�绰
          public String dpartPhone
          {
              get { return  GetString("dpartPhone"); }
              set { SetString("dpartPhone",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // ��Ч��־
          public string useTag
          {
              get { return  Getstring("useTag"); }
              set { Setstring("useTag",value); }
          }

     }
}


