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
using System.Text.RegularExpressions;
using PDO.PrivilegePR;

public partial class TransferLottery_ChangePWD : Master.TransferLotteryMaster
{
    

    private Boolean ChangePasswordValidation()
    {
        //对原密码进行非空、长度、英数检验

        String strOPwd = txtOPwd.Text.Trim();

        if (strOPwd == "")
            context.AddError("A010001001", txtOPwd);
        //else
        //{
        //    if (!Validation.isCharNum(strOPwd))
        //        context.AddError("A010001003", txtOPwd);

        //}

        //对新密码进行非空、长度、英数检验


        String strNPwd = txtNPwd.Text.Trim();
        if (strNPwd == "")
            context.AddError("A010001004", txtNPwd);
        else
        {
            if (txtNPwd.Text.Trim().Length < 8)
            {
                context.AddError("A010001012", txtNPwd);
            }
            //if (!Validation.isCharNum(strNPwd))
            //    context.AddError("A010001006", txtNPwd);
            validNewPwd(strNPwd);

        }


        //对新密码确认进行非空检验


        String strANPwd = txtANPwd.Text.Trim();

        if (strANPwd == "")
            context.AddError("A010001007", txtANPwd);

        //对原密码与新密码是否一样进行检验

        if (!context.hasError())
        {
            if (strOPwd == strNPwd)
                context.AddError("A010001008", txtANPwd);
        }

        //对新密码与新密码确认是否一样进行检验

        if (!context.hasError())
        {
            if (strNPwd != strANPwd)
                context.AddError("A010001009", txtANPwd);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        if (!ChangePasswordValidation())
            return;

        //查询旧密码是否正确

        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.STAFFNO = context.s_UserID;
        ddoTD_M_INSIDESTAFFIn.OPERCARDPWD = DecryptString.EncodeString(txtOPwd.Text.Trim());
        //判断操作员卡号是否存在

        if (!string.IsNullOrEmpty(context.s_CardID.Trim()))
        {
            ddoTD_M_INSIDESTAFFIn.OPERCARDNO = context.s_CardID;
        }
        else
        {
            //context.AddError("无操作员卡号");
        }
        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();
        if (!tmTD_M_INSIDESTAFF.chkPassWD(context, ddoTD_M_INSIDESTAFFIn))
            return;

        //修改密码
        ddoTD_M_INSIDESTAFFIn.OPERCARDPWD = DecryptString.EncodeString(txtNPwd.Text.Trim());
        int recordSum = tmTD_M_INSIDESTAFF.updRecord(context, ddoTD_M_INSIDESTAFFIn);
        context.DBCommit();

        //修改数据不成功显示错误信息

        if (recordSum == 0)
        {
            context.AddError("S010001011");
        }
        else
        {
            //同步卡管中同工号账户的密码

            //context.DBOpen("StorePro");
            //context.AddField("p_staffno").Value = context.s_UserID;
            //context.AddField("P_OPERCARDPWD").Value = DecryptString.EncodeString(txtNPwd.Text.Trim());
            //if (context.ExecuteSP("SP_PR_SYNCSTAFFPWD"))
            //{
            //    AddMessage("同步卡管帐户成功");
            //}
            //context.DBCommit();
        }

        AddMessage("M010001105");
    }

    /// <summary>
    /// 验证新密码输入格式，密码设置至少包含字母、数据、符号三种中的两种 2013/8/26 add by youyue
    /// </summary>
    /// <param name="newPwd"></param>
    /// <returns></returns>
    private bool validNewPwd(string newPwd)
    {
        if (Regex.IsMatch(newPwd, @"^(?=.*?\d)(?=.*?[A-Za-z])|(?=.*?\d)(?=.*?[!@#$%^&])|(?=.*?[A-Za-z])(?=.*?[!@#$%^&])|[\dA-Za-z!@#$%^&]+$ "))
        {
            return true;
        }
        else
        {
            context.AddError("A010001006", txtNPwd);
            return false;
        }

    }
}