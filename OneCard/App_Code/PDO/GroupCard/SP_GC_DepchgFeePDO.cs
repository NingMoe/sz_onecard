using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // ��Ѻ��ת����
     public class SP_GC_DepchgFeePDO : PDOBase
     {
          public SP_GC_DepchgFeePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_DepchgFee",9);

               AddField("@BeginCardNo", "string", "16", "input");
               AddField("@EndCardNo", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ��ʼ����
          public string BeginCardNo
          {
              get { return  Getstring("BeginCardNo"); }
              set { Setstring("BeginCardNo",value); }
          }

          // ��ֹ����
          public string EndCardNo
          {
              get { return  Getstring("EndCardNo"); }
              set { Setstring("EndCardNo",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


