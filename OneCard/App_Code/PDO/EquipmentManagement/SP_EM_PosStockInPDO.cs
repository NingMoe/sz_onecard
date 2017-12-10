using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // POS���
     public class SP_EM_PosStockInPDO : PDOBase
     {
          public SP_EM_PosStockInPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_EM_PosStockIn",15);

               AddField("@posNo", "string", "6", "input");
               AddField("@posSort", "string", "2", "input");
               AddField("@posModel", "string", "2", "input");
               AddField("@touchType", "string", "2", "input");
               AddField("@layType", "string", "2", "input");
               AddField("@commType", "string", "2", "input");
               AddField("@posPrice", "Int32", "", "input");
               AddField("@posManu", "string", "2", "input");
               AddField("@posSource", "string", "1", "input");
               AddField("@hardwareNum", "String", "50", "input");

               InitEnd();
          }

          // POS���
          public string posNo
          {
              get { return  Getstring("posNo"); }
              set { Setstring("posNo",value); }
          }

          // POS���
          public string posSort
          {
              get { return  Getstring("posSort"); }
              set { Setstring("posSort",value); }
          }

          // POS�ͺ�
          public string posModel
          {
              get { return  Getstring("posModel"); }
              set { Setstring("posModel",value); }
          }

          // �Ӵ�����
          public string touchType
          {
              get { return  Getstring("touchType"); }
              set { Setstring("touchType",value); }
          }

          // ��������
          public string layType
          {
              get { return  Getstring("layType"); }
              set { Setstring("layType",value); }
          }

          // ͨѶ����
          public string commType
          {
              get { return  Getstring("commType"); }
              set { Setstring("commType",value); }
          }

          // POS�۸�
          public Int32 posPrice
          {
              get { return  GetInt32("posPrice"); }
              set { SetInt32("posPrice",value); }
          }

          // POS����
          public string posManu
          {
              get { return  Getstring("posManu"); }
              set { Setstring("posManu",value); }
          }

          // POS��Դ
          public string posSource
          {
              get { return  Getstring("posSource"); }
              set { Setstring("posSource",value); }
          }

          // Ӳ�����к�
          public String hardwareNum
          {
              get { return  GetString("hardwareNum"); }
              set { SetString("hardwareNum",value); }
          }

     }
}


