using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
    public class TD_M_INVOICEPROJECTTDO : DDOBase
    {
        public TD_M_INVOICEPROJECTTDO()
        {
            //
            // TODO: Add constructor logic here
            //
        }
        protected override void Init()
        {
            tableName = "TD_M_INVOICEPROJECT";

            columns = new String[3][];
            columns[0] = new String[] { "PROJECTNO", "string" };
            columns[1] = new String[] { "PROJECTNAME", "String" };
            columns[2] = new String[] { "USETAG", "string" };

            columnKeys = new String[]{
                   "PROJECTNO",
               };


            array = new String[3];
            hash.Add("PROJECTNO", 0);
            hash.Add("PROJECTNAME", 1);
            hash.Add("USETAG", 2);
        }

        // 发票项目编码
        public string PROJECTNO
        {
            get { return Getstring("PROJECTNO"); }
            set { Setstring("PROJECTNO", value); }
        }

        // 发票项目名称
        public String PROJECTNAME
        {
            get { return GetString("PROJECTNAME"); }
            set { SetString("PROJECTNAME", value); }
        }

        public string USETAG
        {
            get { return Getstring("USETAG"); }
            set { Setstring("USETAG", value); }
        }

        
    }
}