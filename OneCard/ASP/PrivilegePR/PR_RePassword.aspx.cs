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
using Master;
using TM;
using TDO.UserManager;
using TM.UserManager;

public partial class ASP_PrivilegePR_PR_RePassword : Master.Master
{
    private Boolean RePasswordValidation()
    {
        //对部门名称进行非空检验

        //String strselDEPARTNO = selDEPARTNO.Text.Trim();

        //if (strselDEPARTNO == "")
        //    context.AddError("A010003021", selDEPARTNO);

        //对员工姓名进行非空检验

        String strselSTAFFNO = selSTAFFNO.Text.Trim();

        if (strselSTAFFNO == "")
            context.AddError("A010003022", selSTAFFNO);

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            UserCardHelper.selectDepts(context, selDEPARTNO, true);

            UserCardHelper.selectStaffs(context, selSTAFFNO, selDEPARTNO, true);
        }
    }

    protected void selDEPARTNO_SelectedIndexChanged(object sender, EventArgs e)
    {
        UserCardHelper.selectStaffs(context, selSTAFFNO, selDEPARTNO, true);
    }

    protected void btnRePassword_Click(object sender, EventArgs e)
    {
        if (!RePasswordValidation())
            return;

        //重置密码
        //获取库内配置
        string initPwd = "szcic12!!";
        DataTable dtCheckTable = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "getInitPwdPara");
        if (dtCheckTable.Rows.Count > 0)
        {
            initPwd = dtCheckTable.Rows[0]["PWD"].ToString();
        }
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();

        tdoTD_M_INSIDESTAFFIn.STAFFNO = selSTAFFNO.SelectedValue;
        tdoTD_M_INSIDESTAFFIn.OPERCARDPWD = DecryptString.EncodeString(initPwd);//2013/8/26 初始密码改为库内系统参数

        int recordSum = tmTD_M_INSIDESTAFF.updRecord(context, tdoTD_M_INSIDESTAFFIn);
        context.DBCommit();
        //修改数据不成功显示错误信息
        if (recordSum == 0)
        {
            context.AddError("S010003023");
        }
        else
        {
            //同步卡管中同工号账户的密码
            context.DBOpen("StorePro");
            context.AddField("p_staffno").Value = selSTAFFNO.SelectedValue;
            context.AddField("P_OPERCARDPWD").Value = DecryptString.EncodeString(initPwd);//密码重置为系统参数中配置的初始密码

            if (context.ExecuteSP("SP_PR_SYNCSTAFFPWD"))
            {
                AddMessage("同步卡管帐户成功");
            }
            context.DBCommit();
        }
        AddMessage("M010003110");
    }


    
}
    

