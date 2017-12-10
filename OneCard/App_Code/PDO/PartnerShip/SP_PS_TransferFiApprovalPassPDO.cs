using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ���㵥Ԫ��Ϣ�������ͨ��
     public class SP_PS_TransferFiApprovalPassPDO : PDOBase
     {
          public SP_PS_TransferFiApprovalPassPDO()
          {
          }

          protected override void Init()
          {
               InitBegin("SP_PS_TransferFiApprovalPass",32);

               AddField("@tradeId", "string", "16", "input");
               AddField("@tradeTypeCode", "string", "2", "input");
               AddField("@balUnitNo", "string", "8", "input");
               AddField("@balUnit", "String", "100", "input");
               AddField("@balUnitTypeCode", "string", "2", "input");
               AddField("@channelNo", "string", "4", "input");
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
               AddField("@uintEmail", "String", "200", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@updateStuff", "string", "6", "input");

               //add by jiangbb �����տ����˻�����
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

          //��������
          public string bankChannel
          {
              get { return Getstring("bankChannel"); }
              set { Setstring("bankChannel", value); }
          }

          // ҵ����ˮ��
          public string tradeId
          {
              get { return  Getstring("tradeId"); }
              set { Setstring("tradeId",value); }
          }

          // ҵ�����ͱ���
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
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

          // ͨ������
          public string channelNo
          {
              get { return  Getstring("channelNo"); }
              set { Setstring("channelNo",value); }
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
          public String uintEmail
          {
              get { return  GetString("uintEmail"); }
              set { SetString("uintEmail",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // ����Ա������(���㵥Ԫ��ɾ�ģ����㵥ԪӶ�𷽰���ɾ�ĵĲ���Ա������)
          public string updateStuff
          {
              get { return  Getstring("updateStuff"); }
              set { Setstring("updateStuff",value); }
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


