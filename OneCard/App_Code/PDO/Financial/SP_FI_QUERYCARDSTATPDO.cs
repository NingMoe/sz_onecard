using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Financial
{
    public class SP_FI_QUERYCARDSTATPDO : PDOBase
    {
        public SP_FI_QUERYCARDSTATPDO()
        {
        }
        protected override void Init()
        {
            InitBegin("SP_FI_QUERYCARDSTAT", 4);

            AddField("@funcCode", "String", "16", "input");
            AddField("@MONTH", "String", "6", "input");
            AddField("@cursor", "Cursor", "", "output");
        }
        // 功能编码
        public String funcCode
        {
            get { return GetString("funcCode"); }
            set { SetString("funcCode", value); }
        }
        //查询年月
        public String MONTH
        {
            get { return GetString("MONTH"); }
            set { SetString("MONTH", value); }
        }
    }
}