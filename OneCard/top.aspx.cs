using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web.UI;
using Master;
using PDO.PrivilegePR;
using TDO.UserManager;
using TM.UserManager;

public partial class top : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        Session["MenuType"] = null;
        labDepartName.Text = context.s_DepartName;
        labUserID.Text = context.s_UserID;
        labUserName.Text = context.s_UserName;
        LabCardNo.Text = context.s_CardID;

        //初始化子系统链接,退出链接


        string loginURL = string.Empty;
        if (Session["LogonInfo"] != null)
        {
            DataTable dt = (DataTable)Session["SSOInfo"];
            if (dt != null)
            {
                if (dt.Select("IsAuth = 'True' and SysName = 'onecard'").Length == 1)
                {
                    liOneCard.Visible = true;
                }
                if (dt.Select("IsAuth = 'True' and SysName = 'smk'").Length == 1)
                {
                    liSMK.Visible = true;
                }
                //if (dt.Select("IsAuth = 'True' and SysName = 'newcard'").Length == 1)
                //{
                //    liNewCard.Visible = true;
                //}
            }

            //资源标签
            if (CheckResourcePower())
            {
                liResource.Visible = true;

            }
            //专有帐户标签
            if (CheckGroupCardPower())
            {
                liGroupCard.Visible = true;

            }
            //判断交通一卡通权限
            if (CheckNewCardPower())
            {
                liNewCard.Visible = true;
            }

            Hashtable hash = (Hashtable)Session["LogonInfo"];
            string type = string.Empty;
            if (hash["Debugging"].ToString() == "True")
            {
                type = "test";
                linkLogout.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logontest.aspx?Logout=1";
                linkSMK.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logontest.aspx?Login=1&SysName=smk";
                //linkNewCard.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logontest.aspx?Login=1&SysName=newcard";
                //linkOneCard.NavigateUrl = "#";
                //linkOneCard.Target = "";
            }
            //logonadmin
            else if (hash["LogonLevel"].ToString() == "Admin")
            {
                type = "admin";
                linkLogout.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logonadmin.aspx?Logout=1";
                linkSMK.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logonadmin.aspx?Login=1&SysName=smk";
                //linkOneCard.NavigateUrl = "#";
                //linkOneCard.Target = "";
            }
            //普通情况
            else
            {
                type = "normal";
                linkLogout.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logon.aspx?Logout=1";
                linkSMK.NavigateUrl = ConfigurationManager.AppSettings["LoginServer"] + "/logon.aspx?Login=1&SysName=smk";
                //linkOneCard.NavigateUrl = "#";
                //linkOneCard.Target = "";
            }
            linkNewCard.NavigateUrl = ConfigurationManager.AppSettings["LoginNewServer"] +
                string.Format("/home/login?type={0}&deptno={1}&deptname={2}&staffno={3}&staffname={4}&operateCard={5}&token={6}",
                type, context.s_DepartID, context.s_DepartName, context.s_UserID, context.s_UserName, context.s_CardID, Session["token"]);
        }

        //卡管数据库检查


        if (Session["SMKCHECK"] != null && !(bool)Session["SMKCHECK"])
        {
            labSMKCheck.Text = "卡管系统数据异常，请联系相关人员";
        }

        ////新系统数据库检查
        //if (Session["NEWCARDCHECK"] != null && !(bool)Session["NEWCARDCHECK"])
        //{
        //    labSMKCheck.Text = "省一卡通系统数据异常，请联系相关人员";
        //}

        btnConfirm_Click(sender, e);
    }

    /// <summary>
    /// 验证省交通一卡通权限
    /// </summary>
    /// <returns></returns>
    private bool CheckNewCardPower()
    {
        DDOBase tdoDDOBaseIn = new DDOBase();
        TD_M_MENUTM tmTD_M_MENU = new TD_M_MENUTM();
        tdoDDOBaseIn.Columns = new String[1][];
        tdoDDOBaseIn.Columns[0] = new String[] { "STAFFNO", "String" };
        tdoDDOBaseIn.Hash.Add("STAFFNO", 0);
        String[] array = new String[1];
        tdoDDOBaseIn.setArray(array);
        tdoDDOBaseIn.ArrayList.SetValue(context.s_UserID, 0);

        TD_M_MENUTDO[] tdoTD_M_MENUOutArr = tmTD_M_MENU.selByPK(context, tdoDDOBaseIn);
        bool result = false;
        foreach (TD_M_MENUTDO menu in tdoTD_M_MENUOutArr)
        {
            if (menu.PMENUNO == "N10000" || menu.PMENUNO == "N20000" || menu.PMENUNO == "N30000")
            {
                result = true;
                break;
            }
        }
        return result;
    }

    //判断是否有资源全选

    private bool CheckResourcePower()
    {
        DDOBase tdoDDOBaseIn = new DDOBase();
        TD_M_MENUTM tmTD_M_MENU = new TD_M_MENUTM();
        tdoDDOBaseIn.Columns = new String[1][];
        tdoDDOBaseIn.Columns[0] = new String[] { "STAFFNO", "String" };
        tdoDDOBaseIn.Hash.Add("STAFFNO", 0);
        String[] array = new String[1];
        tdoDDOBaseIn.setArray(array);
        tdoDDOBaseIn.ArrayList.SetValue(context.s_UserID, 0);

        TD_M_MENUTDO[] tdoTD_M_MENUOutArr = tmTD_M_MENU.selByPK(context, tdoDDOBaseIn);
        bool result = false;
        foreach (TD_M_MENUTDO menu in tdoTD_M_MENUOutArr)
        {
        	if (menu.MENUNO == "R00100" || menu.MENUNO == "R00200" || menu.MENUNO == "710000" || menu.MENUNO == "400000" || menu.MENUNO == "800000" || menu.MENUNO == "860000" || menu.MENUNO == "TL0000")
            {
                result = true;
                break;
            }
        }
        return result;
    }

    protected void linkResource_Click(object sender, EventArgs e)
    {
        linkResource.CssClass = "on";
        linkOneCard.CssClass = "";
        linkGroupCard.CssClass = "";
        Session["MenuType"] = 1;
        ScriptManager.RegisterStartupScript(
                this, this.GetType(), "reloadPage",
                "window.parent.frames['main'].window.frames['menu'].location.href('menu.aspx'); ", true);
    }

    ////判断是否有专有帐户全选

    private bool CheckGroupCardPower()
    {
        DDOBase tdoDDOBaseIn = new DDOBase();
        TD_M_MENUTM tmTD_M_MENU = new TD_M_MENUTM();
        tdoDDOBaseIn.Columns = new String[1][];
        tdoDDOBaseIn.Columns[0] = new String[] { "STAFFNO", "String" };
        tdoDDOBaseIn.Hash.Add("STAFFNO", 0);
        String[] array = new String[1];
        tdoDDOBaseIn.setArray(array);
        tdoDDOBaseIn.ArrayList.SetValue(context.s_UserID, 0);

        TD_M_MENUTDO[] tdoTD_M_MENUOutArr = tmTD_M_MENU.selByPK(context, tdoDDOBaseIn);
        bool result = false;
        foreach (TD_M_MENUTDO menu in tdoTD_M_MENUOutArr)
        {
            if (menu.MENUNO == "230000" || menu.MENUNO == "230500")
            {
                result = true;
                break;
            }
        }
        return result;
    }

    protected void linkGroupCard_Click(object sender, EventArgs e)
    {

        Session["MenuType"] = 2;
        linkResource.CssClass = "";
        linkOneCard.CssClass = "";
        linkGroupCard.CssClass = "on";
        ScriptManager.RegisterStartupScript(
                this, this.GetType(), "reloadPage",
                "window.parent.frames['main'].window.frames['menu'].location.href('menu.aspx'); ", true);
    }

    protected void linkOneCard_Click(object sender, EventArgs e)
    {

        Session["MenuType"] = null;
        linkResource.CssClass = "";
        linkOneCard.CssClass = "on";
        linkGroupCard.CssClass = "";
        ScriptManager.RegisterStartupScript(
                this, this.GetType(), "reloadPage",
                "window.parent.frames['main'].window.frames['menu'].location.href('menu.aspx'); ", true);
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        pdo.funcCode = "QueryNewMsgNum";
        pdo.var1 = context.s_DepartID;
        pdo.var2 = context.s_UserID;

        DataTable dt = new StoreProScene().Execute(context, pdo);
        labNewMsgNum.Text = "" + dt.Rows[0].ItemArray[0];

        ScriptManager.RegisterStartupScript(
            this, this.GetType(), "refreshScript",
            "refreshNewMsgNum();", true);

    }
}
