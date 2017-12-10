using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
     // ��������
     public class SP_UC_BatchDistributionPDO : PDOBase
     {
          public SP_UC_BatchDistributionPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_UC_BatchDistribution",9);

               AddField("@fromCardNo", "String", "16", "input");
               AddField("@toCardNo", "String", "16", "input");
               AddField("@distType", "Int32", "", "input");
               AddField("@assignee", "string", "6", "input");

               InitEnd();
          }

          // ��ʼ����
          public String fromCardNo
          {
              get { return  GetString("fromCardNo"); }
              set { SetString("fromCardNo",value); }
          }

          // ��������
          public String toCardNo
          {
              get { return  GetString("toCardNo"); }
              set { SetString("toCardNo",value); }
          }

          // ��������
          public Int32 distType
          {
              get { return  GetInt32("distType"); }
              set { SetInt32("distType",value); }
          }

          // �������
          public string assignee
          {
              get { return  Getstring("assignee"); }
              set { Setstring("assignee",value); }
          }

     }
}


