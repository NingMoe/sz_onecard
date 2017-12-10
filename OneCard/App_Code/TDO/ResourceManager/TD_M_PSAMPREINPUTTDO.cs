using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // POS��SAM����Ӧ��ϵ��
     public class TD_M_PSAMPREINPUTTDO : DDOBase
     {
         public TD_M_PSAMPREINPUTTDO()
          {
          }

          protected override void Init()
          {
              tableName = "TD_M_PSAMPREINPUT";

               columns = new String[3][];
               columns[0] = new String[]{"POSNO", "string"};
               columns[1] = new String[]{"PSAMNO", "string"};
               columns[2] = new String[]{"PREINPUTTIME", "DateTime"};

               columnKeys = new String[]{
                   "POSNO",
               };


               array = new String[3];
               hash.Add("POSNO", 0);
               hash.Add("PSAMNO", 1);
               hash.Add("PREINPUTTIME", 2);
           
          }

          // SAM���
          public string PSAMNO
          {
              get { return Getstring("PSAMNO"); }
              set { Setstring("PSAMNO", value); }
          }

          // POS���
          public string POSNO
          {
              get { return Getstring("POSNO"); }
              set { Setstring("POSNO", value); }
          }


         

        

       

          // ����ʱ��
          public DateTime PREINPUTTIME
          {
              get { return GetDateTime("PREINPUTTIME"); }
              set { SetDateTime("PREINPUTTIME", value); }
          }

         

     }
}


