using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
    // 补结算单元
    public class SP_SD_XXPARK_FillBalUnitPDO : PDOBase
    {
        public SP_SD_XXPARK_FillBalUnitPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_SD_XXPARK_FillBalUnit", 6);

            AddField("@yearmonth", "String", "6", "input");

            InitEnd();
        }

        // 处理日期
        public String yearmonth
        {
            get { return GetString("yearmonth"); }
            set { SetString("yearmonth", value); }
        }

    }
}


