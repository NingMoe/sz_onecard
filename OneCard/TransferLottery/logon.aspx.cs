using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using Common;
using PDO.PrivilegePR;
using TDO.UserManager;
using TM;
using TM.UserManager;

public partial class TransferLottery_logon : Master.MasterBase
{
    public override void ErrorMsgShow()
    {
        Msg.Text = "";
        ArrayList errorMessages = context.ErrorMessage;
        for (int index = 0; index < errorMessages.Count; index++)
        {
            if (index > 0)
                Msg.Text += "|";

            String error = errorMessages[index].ToString();
            int start = error.IndexOf(":");
            if (start > 0)
            {
                error = error.Substring(start + 1, error.Length - start - 1);
            }

            Msg.Text += error;
        }
    }

    //进入登录页面
    protected void Page_Load(object sender, EventArgs e)
    {
        Session["LogonInfo"] = null; 
        if (Page.IsPostBack) return;
        
    } 

    /************************************************************************
     * 输入检查
     * @param
     * @return
     ************************************************************************/
    private Boolean InputCheck()
    {
        if (UserName.Text.Trim() == "")
        {
            context.AddError("A100001001", UserName);
        }

        if (UserPass.Text.Trim() == "")
            context.AddError("A100001002", UserPass);

        //卡有效性检查


        //context.AddError("A100001004");

        if (context.hasError())
            return false;
        else
            return true;
    }


    /************************************************************************
     * 对登录用户进行有效性判断，成功后向后续页面传递数据
     * @param
     * @return
     ************************************************************************/
    protected void LogonBtn_Click(object sender, EventArgs e)
    {
        String strIpAdr = "";
        if (Request.Headers["x-forwarded-for"] != null)
            strIpAdr = Request.Headers["x-forwarded-for"].ToString();
        else
            strIpAdr = Request.UserHostAddress;


        if (!InputCheck())
            return;

        //从内部员工编码表中提取数据，并判断用户名、卡号、密码和有效性


        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFOut = null;

        tdoTD_M_INSIDESTAFFIn.STAFFNO = UserName.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.OPERCARDNO = "";
        tdoTD_M_INSIDESTAFFIn.OPERCARDPWD = DecryptString.EncodeString(UserPass.Text.Trim());

        tdoTD_M_INSIDESTAFFOut = tmTD_M_INSIDESTAFF.selByPK(context, tdoTD_M_INSIDESTAFFIn, 0);
        if (tdoTD_M_INSIDESTAFFOut == null)
            return;

        //在内部员工登录限制表中判断是否有限制
        //TD_M_INSIDESTAFFLOGINTM tmTD_M_INSIDESTAFFLOGIN = new TD_M_INSIDESTAFFLOGINTM();
        //TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();

        //tdoTD_M_INSIDESTAFFLOGINIn.STAFFNO = tdoTD_M_INSIDESTAFFIn.STAFFNO;
        //tdoTD_M_INSIDESTAFFLOGINIn.IPADDR = strIpAdr;
        //if (!tmTD_M_INSIDESTAFFLOGIN.isUsage(context, tdoTD_M_INSIDESTAFFLOGINIn))
        //    return;

        //从内部部门表中读取数据


        TD_M_INSIDEDEPARTTM tmTD_M_INSIDEDEPART = new TD_M_INSIDEDEPARTTM();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        tdoTD_M_INSIDEDEPARTIn.DEPARTNO = tdoTD_M_INSIDESTAFFOut.DEPARTNO;
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTOut = tmTD_M_INSIDEDEPART.selByPK(context, tdoTD_M_INSIDEDEPARTIn);


        context.s_UserID = tdoTD_M_INSIDESTAFFOut.STAFFNO;
        context.s_DepartID = tdoTD_M_INSIDESTAFFOut.DEPARTNO;
        SP_PR_LogonLogPDO pdo = new SP_PR_LogonLogPDO();
        pdo.IPADDR = strIpAdr;
        pdo.LOGONPAGE = "TrabsferLottery/Logon.aspx";

        bool ok = TMStorePModule.Excute(context, pdo);

        if (!ok)
        {
            return;
        }

        
        //设定向后传递的数据
        Hashtable hash = new Hashtable();
        hash.Add("UserID",tdoTD_M_INSIDESTAFFOut.STAFFNO);
        hash.Add("UserName", tdoTD_M_INSIDESTAFFOut.STAFFNAME);
        hash.Add("DepartID", tdoTD_M_INSIDESTAFFOut.DEPARTNO);
        hash.Add("DepartName", tdoTD_M_INSIDEDEPARTOut.DEPARTNAME);
        hash.Add("CardID", "                ");

        hash.Add("RegionCode", tdoTD_M_INSIDEDEPARTOut.REGIONCODE);//部门的归属区域
        context.s_RegionCode = tdoTD_M_INSIDEDEPARTOut.REGIONCODE;//部门的归属区域
        String dtNow = DateTime.Now.Ticks.ToString();
        String prePasswd = tdoTD_M_INSIDESTAFFOut.STAFFNO + dtNow;
        String postPasswd = DecryptString.EncodeString(prePasswd);
        hash.Add("DateTime", dtNow);
        hash.Add("DecryptString", postPasswd);
        hash.Add("Debugging", "False");
        hash.Add("LogonLevel", "Admin"); 
        Session["LogonInfo"] = hash;

        Transfer("Lottery.aspx");

    }
}