using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Financial
{
     // 取消团购标记
    public class SP_FI_GroupBuyDelPDO : PDOBase
    {
        public SP_FI_GroupBuyDelPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_FI_GroupBuyDel", 14);

            AddField("@msgGroupCodes", "String", "1024", "input");
            AddField("@msgGroupNames", "String", "1024", "input");
            InitEnd();
        }

        // 团购劵
        public String msgGroupCodes
        {
            get { return GetString("msgGroupCodes"); }
            set { SetString("msgGroupCodes", value); }
        }
        // 团购商家名称
        public String msgGroupNames
        {
            get { return GetString("msgGroupNames"); }
            set { SetString("msgGroupNames", value); }
        }
     
    }
}


