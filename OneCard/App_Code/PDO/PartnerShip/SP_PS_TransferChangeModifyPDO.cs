using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���㵥Ԫ��Ϣ�޸�
     public class SP_PS_TransferChangeModifyPDO : PDOBase
     {
          public SP_PS_TransferChangeModifyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_TransferChangeModify",35);

               AddField("@balUnitNo", "string", "8", "input");
               AddField("@balUnit", "String", "100", "input");
               AddField("@balUnitTypeCode", "string", "2", "input");
               AddField("@sourceTypeCode", "string", "2", "input");
               AddField("@callingNo", "string", "2", "input");
               AddField("@corpNo", "string", "4", "input");
               AddField("@departNo", "string", "4", "input");
               AddField("@bankCode", "string", "4", "input");
               AddField("@bankAccno", "String", "20", "input");
               AddField("@serManagerCode", "string", "6", "input");
               AddField("@balLevel", "string", "1", "input");
               AddField("@balCycleTypeCode", "string", "2", "input");
               AddField("@balInterval", "Int32", "", "input");
               AddField("@finCycleTypeCode", "string", "2", "input");
               AddField("@finInterval", "Int32", "", "input");
               AddField("@finTypeCode", "string", "1", "input");
               AddField("@comFeeTakeCode", "string", "1", "input");
               AddField("@finBankCode", "string", "4", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@unitPhone", "String", "20", "input");
               AddField("@unitAdd", "String", "50", "input");
               AddField("@unitEmail", "String", "200", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@useTag", "string", "1", "input");

               AddField("@aprvState", "string", "1", "input");
               AddField("@seqNo", "string", "16", "input");

               AddField("@comSchemeNo", "string", "8", "input");
               AddField("@beginTime", "string", "20", "input");
               AddField("@endTime", "string", "20", "input");

               AddField("@keyInfoChanged", "string", "1", "input");

               //add by jiangbb 2012-05-18 �����տ����˻�����
               AddField("@purposeType", "string", "1", "input");
               AddField("@bankChannel", "string", "1", "input");

               AddField("@RegionCode", "string", "1", "input");
               AddField("@DeliveryModeCode", "string", "1", "input");
               AddField("@AppCallingCode", "string", "1", "input");
               InitEnd();
          }
          
          //�տ����˻�����
          public string purposeType
          {
              get { return Getstring("purposeType"); }
              set { Setstring("purposeType", value); }
          }

         //������������
          public string bankChannel
          {
              get { return Getstring("bankChannel"); }
              set { Setstring("bankChannel", value); }
          }

          // �ؼ���Ϣ�Ƿ��޸�
          public string keyInfoChanged
          {
              get { return  Getstring("keyInfoChanged"); }
              set { Setstring("keyInfoChanged",value); }
          }
          
          // ���㵥Ԫ����
          public string balUnitNo
          {
              get { return  Getstring("balUnitNo"); }
              set { Setstring("balUnitNo",value); }
          }

          // ���㵥Ԫ����
          public String balUnit
          {
              get { return  GetString("balUnit"); }
              set { SetString("balUnit",value); }
          }

          // ��Ԫ���ͱ���
          public string balUnitTypeCode
          {
              get { return  Getstring("balUnitTypeCode"); }
              set { Setstring("balUnitTypeCode",value); }
          }

          // ��Դʶ�����ͱ���
          public string sourceTypeCode
          {
              get { return  Getstring("sourceTypeCode"); }
              set { Setstring("sourceTypeCode",value); }
          }

          // ��ҵ����
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // ��λ����
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // ���ű���
          public string departNo
          {
              get { return  Getstring("departNo"); }
              set { Setstring("departNo",value); }
          }

          // �������б���
          public string bankCode
          {
              get { return  Getstring("bankCode"); }
              set { Setstring("bankCode",value); }
          }

          // �����ʺ�
          public String bankAccno
          {
              get { return  GetString("bankAccno"); }
              set { SetString("bankAccno",value); }
          }

          // �̻��������
          public string serManagerCode
          {
              get { return  Getstring("serManagerCode"); }
              set { Setstring("serManagerCode",value); }
          }

          // ���㼶�����
          public string balLevel
          {
              get { return  Getstring("balLevel"); }
              set { Setstring("balLevel",value); }
          }

          // �����������ͱ���
          public string balCycleTypeCode
          {
              get { return  Getstring("balCycleTypeCode"); }
              set { Setstring("balCycleTypeCode",value); }
          }

          // �������ڿ��
          public Int32 balInterval
          {
              get { return  GetInt32("balInterval"); }
              set { SetInt32("balInterval",value); }
          }

          // �����������ͱ���
          public string finCycleTypeCode
          {
              get { return  Getstring("finCycleTypeCode"); }
              set { Setstring("finCycleTypeCode",value); }
          }

          // �������ڿ��
          public Int32 finInterval
          {
              get { return  GetInt32("finInterval"); }
              set { SetInt32("finInterval",value); }
          }

          // ת������
          public string finTypeCode
          {
              get { return  Getstring("finTypeCode"); }
              set { Setstring("finTypeCode",value); }
          }

          // Ӷ��ۼ���ʽ����
          public string comFeeTakeCode
          {
              get { return  Getstring("comFeeTakeCode"); }
              set { Setstring("comFeeTakeCode",value); }
          }

          // ת�����б���
          public string finBankCode
          {
              get { return  Getstring("finBankCode"); }
              set { Setstring("finBankCode",value); }
          }

          // ��ϵ��
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // ��ϵ�绰
          public String unitPhone
          {
              get { return  GetString("unitPhone"); }
              set { SetString("unitPhone",value); }
          }

          // ��ϵ��ַ
          public String unitAdd
          {
              get { return  GetString("unitAdd"); }
              set { SetString("unitAdd",value); }
          }

          // �����ʼ�
          public String unitEmail
          {
              get { return GetString("unitEmail"); }
              set { SetString("unitEmail", value); }
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

         public string aprvState
         {
             get { return Getstring("aprvState"); }
             set { Setstring("aprvState", value); }
         }
         public string seqNo
         {
             get { return Getstring("seqNo"); }
             set { Setstring("seqNo", value); }
         }

          // Ӷ�𷽰�����
          public string comSchemeNo
          {
              get { return Getstring("comSchemeNo"); }
              set { Setstring("comSchemeNo", value); }
          }

          // Ӷ�𷽰���ʼ����
          public string beginTime
          {
              get { return Getstring("beginTime"); }
              set { Setstring("beginTime", value); }
          }

          // Ӷ�𷽰���ֹ����
          public string endTime
          {
              get { return Getstring("endTime"); }
              set { Setstring("endTime", value); }
          }

          // ��������
          public string RegionCode
          {
              get { return Getstring("RegionCode"); }
              set { Setstring("RegionCode", value); }
          }

          // POSͶ��ģʽ
          public string DeliveryModeCode
          {
              get { return Getstring("DeliveryModeCode"); }
              set { Setstring("DeliveryModeCode", value); }
          }

          // Ӧ����ҵ
          public string AppCallingCode
          {
              get { return Getstring("AppCallingCode"); }
              set { Setstring("AppCallingCode", value); }
          }

     }
}


