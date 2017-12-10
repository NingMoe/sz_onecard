using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���ſͻ���Ϣ�޸�
     public class SP_PS_GroupCustChangePDO : PDOBase
     {
          public SP_PS_GroupCustChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_GroupCustChange",14);

               AddField("@corpCode", "string", "4", "input");
               AddField("@corpName", "String", "50", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@corpAdd", "String", "40", "input");
               AddField("@corpPhone", "String", "100", "input");
               AddField("@serManagerCode", "string", "6", "input");
               AddField("@corpEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               InitEnd();
          }

          // ���ſͻ�����
          public string corpCode
          {
              get { return  Getstring("corpCode"); }
              set { Setstring("corpCode",value); }
          }

          // ���ſͻ�����
          public String corpName
          {
              get { return  GetString("corpName"); }
              set { SetString("corpName",value); }
          }

          // ��ϵ��
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // ��ϵ��ַ
          public String corpAdd
          {
              get { return  GetString("corpAdd"); }
              set { SetString("corpAdd",value); }
          }

          // ��ϵ�绰
          public String corpPhone
          {
              get { return  GetString("corpPhone"); }
              set { SetString("corpPhone",value); }
          }

          // �ͷ��������
          public string serManagerCode
          {
              get { return  Getstring("serManagerCode"); }
              set { Setstring("serManagerCode",value); }
          }

          // �����ʼ�
          public String corpEmail
          {
              get { return  GetString("corpEmail"); }
              set { SetString("corpEmail",value); }
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


