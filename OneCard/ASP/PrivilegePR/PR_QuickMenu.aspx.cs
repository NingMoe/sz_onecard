using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
//快捷菜单配置页面 

public partial class ASP_PrivilegePR_PR_QuickMenu : Master.Master
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定员工GridView DataKeyNames
            lvwQuickMeno.DataKeyNames = new string[] { "MENUNO", "MENUNAME", "SORT"  };
            //初始化页面
            InitMenuList();
            InitPage();
        }
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 选择行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwQuickMeno_SelectedIndexChanged(object sender, EventArgs e)
    {
         //选择员工GRIDVIEW中的一行记录
        selMenuList.SelectedIndex = selMenuList.Items.IndexOf(selMenuList.Items.FindByValue(getDataKeys("MENUNO")));
        txtSort.Text = getDataKeys("SORT");
    }

    /// <summary>
    /// 注册行单击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwQuickMeno_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwQuickMeno','Select$" + e.Row.RowIndex + "')");
        }
    }


    /// <summary>
    /// 新增快捷菜单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //校验
        if (!ValidInput())
        {
            return;
        }
        //保存快捷菜单存储过程
        context.SPOpen();
        context.AddField("p_staffno").Value = context.s_UserID;
        context.AddField("P_MENUNO").Value = selMenuList.SelectedValue;
        context.AddField("P_SORT").Value = Convert.ToInt32(txtSort.Text.Trim());
        context.AddField("P_TYPE").Value = "0";  //新增
        bool ok = context.ExecuteSP("SP_PR_QUICKMENU");
        if (ok)
        {
            context.AddMessage("快捷菜单设置成功,请重新登录系统");
            InitPage();
        }
    }

    /// <summary>
    /// 修改快捷菜单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //校验
        if (!ValidInput())
        {
            return;
        }
        //保存快捷菜单存储过程
        context.SPOpen();
        context.AddField("p_staffno").Value = context.s_UserID;
        context.AddField("P_MENUNO").Value = selMenuList.SelectedValue;
        context.AddField("P_SORT").Value = Convert.ToInt32(txtSort.Text.Trim());
        context.AddField("P_TYPE").Value = "1";  //修改
        bool ok = context.ExecuteSP("SP_PR_QUICKMENU");
        if (ok)
        {
            context.AddMessage("快捷菜单设置成功,请重新登录系统");
            InitPage();
        }
    }


    /// <summary>
    /// 删除快捷菜单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        //保存快捷菜单存储过程
        context.SPOpen();
        context.AddField("p_staffno").Value = context.s_UserID;
        context.AddField("P_MENUNO").Value = selMenuList.SelectedValue;
        context.AddField("P_SORT").Value = 0;
        context.AddField("P_TYPE").Value = "2";  //删除
        bool ok = context.ExecuteSP("SP_PR_QUICKMENU");
        if (ok)
        {
            context.AddMessage("快捷菜单设置成功,请重新登录系统");
            InitPage();
        }
    }
    #endregion

    #region Private
    /// <summary>
    /// 有效性验证
    /// </summary>
    private bool ValidInput()
    {
        if (selMenuList.SelectedValue == "")
        {
            context.AddError("请选择一个菜单", selMenuList);
            return false;
        }

        if (string.IsNullOrEmpty(txtSort.Text))
        {
            context.AddError("请输入排序因子", txtSort);
            return false;
        }
        else if (!Validation.isNum(txtSort.Text.Trim()))
        {
            context.AddError("排序因子必须为整数", txtSort);
            return false;
        }

        //快捷菜单数量不能大于20
        if (lvwQuickMeno.Rows.Count >= 20)
        {
            context.AddError("快捷菜单数量不能大于20");
            return false;
        }
        return true;
    }
    /// <summary>
    /// 查找指定列key值
    /// </summary>
    private String getDataKeys(String keysname)
    {
        return lvwQuickMeno.DataKeys[lvwQuickMeno.SelectedIndex][keysname].ToString();
    }
    /// <summary>
    /// 初始化页面
    /// </summary>
    private void InitPage()
    {
        //查询已保存的快捷菜单
        DataTable quickMenu = SPHelper.callQuery("SP_PR_Query", context, "QueryQuickMenu", context.s_UserID);
        lvwQuickMeno.DataSource = quickMenu;
        lvwQuickMeno.DataBind();
        selMenuList.SelectedIndex = -1;
        txtSort.Text = "";
    }

    /// <summary>
    /// 初始化菜单下拉菜单
    /// </summary>
    protected void InitMenuList()
    {
        //查询有权限的页面
        DataTable data = SPHelper.callQuery("SP_PR_Query", context, "QueryHasPowerMenu", context.s_UserID);

        List<string> grouplist = new List<string>();

        //循环显示树形菜单节点
        foreach (DataRow dr in data.Rows)
        {
            if (!grouplist.Contains(dr[2].ToString()))
            {
                ListItem li = new ListItem();
                //设置子系统节点
                selMenuList.AddItemGroup(dr[3].ToString());
                grouplist.Add(dr[2].ToString());
            }

            //设置页面节点
            selMenuList.Items.Add(new ListItem(dr[1].ToString(), dr[0].ToString()));
        }
    }
    #endregion
}