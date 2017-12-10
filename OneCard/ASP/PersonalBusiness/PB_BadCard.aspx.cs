using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_BadCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    //坏卡登记判断
    private Boolean badCardbookinValidation()
    {
        //对卡号进行非空、长度、数字检验


        if (txtCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A001004114", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001004115", txtCardno);
        }

        return !(context.hasError());
    }
    protected void btnBadCard_Click(object sender, EventArgs e)
    {
        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtCardno.Text;
        bool smkNo = TMStorePModule.Excute(context, smkpdo);
        if (smkNo == false)
        {
            return;
        }
        //对输入卡号进行检验

        if (!badCardbookinValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        SP_PB_BadCardPDO pdo = new SP_PB_BadCardPDO();

        //存储过程赋值

        pdo.CARDNO = txtCardno.Text;
        pdo.TRADETYPECODE = "93";

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001001003");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }
    }
}
