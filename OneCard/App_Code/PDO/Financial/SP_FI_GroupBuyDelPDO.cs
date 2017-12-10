using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Financial
{
     // ȡ���Ź����
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

        // �Ź���
        public String msgGroupCodes
        {
            get { return GetString("msgGroupCodes"); }
            set { SetString("msgGroupCodes", value); }
        }
        // �Ź��̼�����
        public String msgGroupNames
        {
            get { return GetString("msgGroupNames"); }
            set { SetString("msgGroupNames", value); }
        }
     
    }
}


