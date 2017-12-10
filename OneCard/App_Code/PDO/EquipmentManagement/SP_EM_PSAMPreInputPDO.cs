using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.EquipmentManagement
{
     // 建立结算关系
     public class SP_EM_PSAMPreInputPDO : PDOBase
     {
         public SP_EM_PSAMPreInputPDO()
          {
          }

          protected override void Init()
          {
              InitBegin("SP_EM_PSAMPreInput_U", 16);

               AddField("@posNo", "string", "6", "input");
               AddField("@psamNo", "string", "12", "input");
              

               InitEnd();
          }

          // POS编号
          public string posNo
          {
              get { return  Getstring("posNo"); }
              set { Setstring("posNo",value); }
          }

          // PSAM卡号
          public string psamNo
          {
              get { return  Getstring("psamNo"); }
              set { Setstring("psamNo",value); }
          }

     }
}


