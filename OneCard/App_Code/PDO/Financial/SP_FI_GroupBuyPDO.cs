using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Financial
{
     // �Ź����
    public class SP_FI_GroupBuyPDO : PDOBase
    {
        public SP_FI_GroupBuyPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_FI_GroupBuy", 14);

            AddField("@msgTradeIds", "String", "1024", "input");
            AddField("@msgGroupCode", "String", "1024", "input");
            AddField("@msgShopNo", "String", "1024", "input");
            AddField("@msgRemark", "String", "1024", "input");
            InitEnd();
        }

        // ҵ����ˮ��
        public String msgTradeIds
        {
            get { return GetString("msgTradeIds"); }
            set { SetString("msgTradeIds", value); }
        }

        // �Ź���
        public String msgGroupCode
        {
            get { return GetString("msgGroupCode"); }
            set { SetString("msgGroupCode", value); }
        }

        // �̼ұ��
        public String msgShopNo
        {
            get { return GetString("msgShopNo"); }
            set { SetString("msgShopNo", value); }
        }

        // ��ע
        public String msgRemark
        {
            get { return GetString("msgRemark"); }
            set { SetString("msgRemark", value); }
        }

       
    }
}


