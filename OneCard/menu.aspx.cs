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
using TM.UserManager;
using TDO.UserManager;
using Master;

public partial class menu : Master.Master
{
    public String menuStream;

    protected void Page_Load(object sender, EventArgs e)
    {
        Hashtable hash = (Hashtable)Session["LogonInfo"];
        String LogonLevel = hash["LogonLevel"].ToString();

        DDOBase tdoDDOBaseIn = new DDOBase();
        TD_M_MENUTM tmTD_M_MENU = new TD_M_MENUTM();
        tdoDDOBaseIn.Columns = new String[1][];
        tdoDDOBaseIn.Columns[0] = new String[] { "STAFFNO", "String" };
        tdoDDOBaseIn.Hash.Add("STAFFNO", 0);
        String[] array = new String[1];
        tdoDDOBaseIn.setArray(array);
        tdoDDOBaseIn.ArrayList.SetValue(context.s_UserID, 0);

        TD_M_MENUTDO[] tdoTD_M_MENUOutArr = tmTD_M_MENU.selByPK(context, tdoDDOBaseIn);
        if (tdoTD_M_MENUOutArr.Length == 0)
        {
            tdoTD_M_MENUOutArr = tmTD_M_MENU.selDefaultMenu(context, tdoDDOBaseIn);
        }

        TreeView NavigationMenu = new TreeView();
        TreeNode newTN;

        menuStream += "var root;";
        menuStream += "var item;";
        DataTable quickMenuData = SPHelper.callQuery("SP_PR_Query", context, "QueryQuickMenu", context.s_UserID);
        if (quickMenuData.Rows.Count != 0 && Session["MenuType"] == null)
        {
            menuStream += "root = addMenu('快捷菜单');";
            foreach (DataRow menu in quickMenuData.Rows)
            {
                newTN = new TreeNode();
                newTN.Value = menu["MENUNO"].ToString();
                newTN.NavigateUrl = context.GetUrl(menu["URL"].ToString());
                newTN.Text = menu["MENUNAME"].ToString();
                if (menu["TIPS"] == DBNull.Value || menu["TIPS"].ToString().Trim().Equals(""))
                    newTN.ToolTip = menu["MENUNAME"].ToString();
                else
                    newTN.ToolTip = menu["TIPS"].ToString();
                newTN.Target = menu["TARGET"].ToString();
                newTN.ImageToolTip = menu["CLICKFUC"].ToString(); 

                if (newTN.NavigateUrl.Equals(""))
                    menuStream += "item = addMenuItem(root, '" + newTN.Text + "', null , '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                else
                    if (newTN.ImageToolTip.Equals(""))
                        menuStream += "item = addMenuItem(root, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                    else
                        menuStream += "item = addMenuItem(root, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "','" + newTN.ImageToolTip + "');";

            }
        }

        TD_M_MENUTDO tdoTD_M_MENUOut = null;


        for (int index = 0; index < tdoTD_M_MENUOutArr.Length; index++)
        {
            if (tdoTD_M_MENUOutArr[index].ISNEW == "1")
            {
                continue;
            }
            if (Session["MenuType"] != null)
            {
                if ((int)Session["MenuType"] == 1 && (!tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("R") && !tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("710") && !tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("800") && !tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("400") && !tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("860") && !tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("TL0")))
                {
                    continue;
                }
                else if ((int)Session["MenuType"] == 2 && (!tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("230") ))
                {
                    continue;
                }
            }
            else
            {
                if (tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("R") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("710") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("800") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("400") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("860") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("TL0") || tdoTD_M_MENUOutArr[index].MENUNO.StartsWith("230"))
                {
                    continue;
                }
            }

            //add by gl 不显示交通局抽奖
            if (tdoTD_M_MENUOutArr[index].MENUNO == "TL0000" || tdoTD_M_MENUOutArr[index].PMENUNO == "TL0000")
                continue;

            tdoTD_M_MENUOut = tdoTD_M_MENUOutArr[index];
            newTN = new TreeNode();

            newTN.Value = tdoTD_M_MENUOut.MENUNO;

            if ("logon".Equals(tdoTD_M_MENUOut.URL, StringComparison.OrdinalIgnoreCase))
            {
                if (LogonLevel.Equals("Normal"))
                    newTN.NavigateUrl = context.GetUrl(tdoTD_M_MENUOut.URL);
                else if (LogonLevel.Equals("Admin"))
                    newTN.NavigateUrl = context.GetUrl(tdoTD_M_MENUOut.URL + "Admin");
            }
            else
                newTN.NavigateUrl = context.GetUrl(tdoTD_M_MENUOut.URL);

            newTN.Text = tdoTD_M_MENUOut.MENUNAME;

            newTN.ToolTip = tdoTD_M_MENUOut.TIPS;
            if (tdoTD_M_MENUOut.TIPS == null || tdoTD_M_MENUOut.TIPS.Trim().Equals(""))
                newTN.ToolTip = tdoTD_M_MENUOut.MENUNAME;

            newTN.Target = tdoTD_M_MENUOut.TARGET;
            newTN.ImageToolTip = tdoTD_M_MENUOut.CLICKFUC;


            if (tdoTD_M_MENUOut.PMENUNO.Equals("000000"))
            {
                menuStream += "root = addMenu('" + newTN.Text + "');";
                NavigationMenu.Nodes.Add(newTN);
            }
            else
            {

                foreach (TreeNode node in NavigationMenu.Nodes)
                {
                    if (node.Value.Equals(tdoTD_M_MENUOut.PMENUNO))
                    {
                        if (newTN.NavigateUrl.Equals(""))
                            menuStream += "item = addMenuItem(root, '" + newTN.Text + "', null , '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                        else
                            if (newTN.ImageToolTip.Equals(""))
                                menuStream += "item = addMenuItem(root, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                            else
                                menuStream += "item = addMenuItem(root, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "','" + newTN.ImageToolTip + "');";

                        node.ChildNodes.Add(newTN);
                        break;
                    }
                    else
                    {
                        MenuNodeFind(tdoTD_M_MENUOut, node, newTN);
                    }

                }
            }

        }

        menuStream += "drawMenu();";
        hidMenuStream.Value = menuStream;

    }

    private void MenuNodeFind(TD_M_MENUTDO tdoTD_M_MENUOut, TreeNode node, TreeNode newTN)
    {
        foreach (TreeNode childNode in node.ChildNodes)
        {
            if (childNode.Value.Equals(tdoTD_M_MENUOut.PMENUNO))
            {
                if (newTN.NavigateUrl.Trim().Equals(""))
                    menuStream += "item = addMenuItem(item, '" + newTN.Text + "', null , '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                else
                    if (newTN.ImageToolTip.Equals(""))
                        menuStream += "item = addMenuItem(item, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "',null);";
                    else
                        menuStream += "item = addMenuItem(item, '" + newTN.Text + "', '" + newTN.NavigateUrl + "', '" + newTN.Target + "', '" + newTN.ToolTip + "','" + newTN.ImageToolTip + "');";

                childNode.ChildNodes.Add(newTN);
                break;
            }
            else
            {
                MenuNodeFind(tdoTD_M_MENUOut, childNode, newTN);
            }
        }

    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "generateToken")
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "writeCardImpl();", true);
        }

        hidWarning.Value = "";
    }


}
