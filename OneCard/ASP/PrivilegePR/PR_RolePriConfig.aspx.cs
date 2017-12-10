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
using TM;
using TDO.UserManager;
using Common;

public partial class ASP_PrivilegePR_PR_RolePriConfig : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //从角色编码表(TD_M_ROLE)读取数据，放入下拉列表中
            TD_M_ROLETDO tdoRule = new TD_M_ROLETDO();
            TD_M_ROLETDO[] tdoRuleArr = (TD_M_ROLETDO[])tmTMTableModule.selByPKArr(context, tdoRule, typeof(TD_M_ROLETDO), "S010006056", "", "");
            ControlDeal.SelectBoxFill(selRole.Items, tdoRuleArr, "ROLENAME", "ROLENO", true);

            //初始化页面项,
            treMenu.Attributes.Add("onclick", "selMenuCode();");
            InitMenuTree();

            //初始化操作权限类别

            InitOperRule();
        }
    }

    protected void lvw_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[1].Visible = false;
        }
    }

    private void InitOperRule()
    {
        //初始化操作权限类别

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POWERTDO tdoPower = new TD_M_POWERTDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoPower, "S010006058", "", null, 0);

        lvwPower.DataSource = data;
        lvwPower.DataBind();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //对角色名称非空的判断
        if (selRole.SelectedValue == "")
        {
            context.AddError("A010006130", selRole);
            return;
        }

        //删除当前角色权限信息
        context.DBOpen("Insert");
        context.ExecuteNonQuery("delete from TD_M_ROLEPOWER where ROLENO ='" + selRole.SelectedValue + "'");
        context.DBCommit();


        //取得所有选择的菜单信息和操作权限信息
        AddMenuPower();
        AddOperPower();

        AddMessage("M010006060");

        //清除角色权限信息
        //ClearRolePower();
        //selRole.SelectedValue = "";

    }



    protected void CheckAllPower(object sender, EventArgs e)
    {
        //全选操作权限信息记录

        CheckBox cbx = (CheckBox)sender;
        OperCheckBox(lvwPower, cbx.Checked, "ItemCheckBoxs");
    }


    protected void selRole_Changed(object sender, EventArgs e)
    {
        //清除角色权限信息
        ClearRolePower();

        if (selRole.SelectedValue != "")
        {
            //选择角色后,显示该角色已有的菜单项

            ShowMenuRolePower();

            //选择角色后,显示该角色已有的操作权限
            ShowOperRolePower();
        }
    }

    private void ClearRolePower()
    {
        //折叠树形菜单
        CollapseMenuTree();

        //清除所有的菜单选择
        ClearMenuChecked(treMenu.Nodes);

        //当角色名称为空时,清楚操作权限的选择项

        try
        {
            CheckBox chkPower = (CheckBox)lvwPower.HeaderRow.FindControl("CheckBox2");
            chkPower.Checked = false;
            OperCheckBox(lvwPower, false, "ItemCheckBoxs");
        }
        catch (Exception)
        {
        }
    }

    private void CollapseMenuTree()
    {
        //折叠树形菜单
        foreach (TreeNode tn in treMenu.Nodes)
        {
            for (int i = 0; i < tn.ChildNodes.Count; i++)
            {
                tn.ChildNodes[i].CollapseAll();
            }
        }
    }

    private void OperCheckBox(GridView lvw, bool check, string box)
    {
        //设置操作权限列表中选择框被选中或者没有选中

        foreach (GridViewRow gvr in lvw.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl(box);
            ch.Checked = check;
        }
    }

    private void InitMenuTree()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //读取菜单编码表信息

        TD_M_MENUTDO tdo = new TD_M_MENUTDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdo, "S010006057", "TD_M_MENU_AND_PMENU", null, 0);

        TreeNode root = new TreeNode();

        //根节点设置

        root.Text = "界面根目录";
        root.Value = "000000";
        root.ShowCheckBox = false;
        treMenu.Nodes.Add(root);

        //展开所有子系统节点
        treMenu.ExpandAll();

        //根节点没有点击事件

        root.NavigateUrl = "javascript:void(0);";

        //已创建的子系统节点 
        Hashtable hashTable = new Hashtable();

        //循环显示树形菜单节点
        for (int i = 0; i < data.Rows.Count; i++)
        {
            //设置子系统节点

            TreeNode parentNode = new TreeNode();
            string pNodeCode = data.Rows[i][2].ToString();
            parentNode.Value = pNodeCode;
            parentNode.Text = data.Rows[i][3].ToString();

            //设置页面节点
            TreeNode childNode = new TreeNode();
            childNode.Value = data.Rows[i][0].ToString();
            childNode.Text = data.Rows[i][1].ToString();

            if (data.Rows[i]["REMARK"].ToString().Equals("1"))
            {
                childNode.Text += "<font color='red'>(可代理)</font>";
            }

            //节点没有点击事件
            parentNode.NavigateUrl = "javascript:void(0);";
            childNode.NavigateUrl = "javascript:void(0);";

            if (hashTable.ContainsKey(pNodeCode))
            {
                //如果当前子系统节点已创建,直接在当前节点下增加菜单
                TreeNode node = (TreeNode)hashTable[pNodeCode];
                node.ChildNodes.Add(childNode);
            }
            else
            {
                //如果当前子系统节还未创建,在根节点下增加该子系统节点

                //子系统节点下增加菜单节点
                root.ChildNodes.Add(parentNode);
                parentNode.ChildNodes.Add(childNode);
                parentNode.CollapseAll();

                hashTable.Add(pNodeCode, parentNode);
            }

        }
    }




    private void ShowMenuRolePower()
    {
        //查询当前角色对应菜单信息
        TMTableModule tmTMTableModule = new TMTableModule();

        //读取角色权限对象表信息

        TD_M_ROLEPOWERTDO tdoRolePower = new TD_M_ROLEPOWERTDO();
        tdoRolePower.ROLENO = selRole.SelectedValue;
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoRolePower, null, "TD_M_ROLEPOWER_MENUCODE", null, 0);

        if (data == null || data.Rows.Count == 0) return;

        ArrayList list = new ArrayList();

        //把DataTable数据增加到list中

        DataTabelToList(data, list);

        //遍历树形菜单项信息,设置该角色已有的菜单项为选择状态


        foreach (TreeNode tn in treMenu.Nodes)
        {
            for (int i = 0; i < tn.ChildNodes.Count; i++)
            {
                //取得子系统菜单编码信息

                string subSysMenuNo = tn.ChildNodes[i].Value;
                int count = 0;
                //TreeNode subSysNode = null;
                foreach (TreeNode tns in tn.ChildNodes[i].ChildNodes)
                {
                    if (list.Contains(tns.Value))
                    {
                        ++count;
                        //当该角色已有该菜单项的权限时,设置菜单项为选中 

                        tns.Checked = true;
                        //subSysNode = tns;

                        tn.ChildNodes[i].Checked = true;
                        //子菜单选中后设置父菜单也选择

                    }
                }



                //CheckState.Indeterminate
                //if (count != tn.ChildNodes[i].ChildNodes.Count)
                //{
                //    //subSysNode.Checked = false;

                //    //subSysNode.indeterminate = true;
                //    //subSysNode.

                //   // subSysNode.Checked = false;
                //      //如果该角色已有该子系统所有的子菜单权限,则该子系统也为选

                //}


            }
        }
    }



    private void ClearMenuChecked(TreeNodeCollection tnc)
    {
        //清除所有的菜单选择
        foreach (TreeNode tn in tnc)
        {
            tn.Checked = false;
            if (tn.ChildNodes.Count > 0)
            {
                ClearMenuChecked(tn.ChildNodes);
            }
        }

    }

    private void ShowOperRolePower()
    {
        //显示该角色已有的操作权限
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_ROLEPOWERTDO tdoRolePower = new TD_M_ROLEPOWERTDO();
        tdoRolePower.ROLENO = selRole.SelectedValue;
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoRolePower, null, "TD_M_ROLEPOWER_POWERCODE", null, 0);

        if (data == null || data.Rows.Count == 0) return;
        ArrayList list = new ArrayList();

        //把DataTable数据增加到list中

        DataTabelToList(data, list);

        //循环读取操作权限列表中数据

        for (int i = 0; i < lvwPower.Rows.Count; i++)
        {
            GridViewRow viewRow = lvwPower.Rows[i];

            //取得操作权限编码
            String powerCode = viewRow.Cells[1].Text;

            if (list.Contains(powerCode))
            {
                //该角色已有该操作权限时,设置为选中
                CheckBox ch = (CheckBox)viewRow.FindControl("ItemCheckBoxs");
                ch.Checked = true;

            }
        }

    }


    private void DataTabelToList(DataTable data, ArrayList list)
    {
        for (int t = 0; t < data.Rows.Count; t++)
        {
            list.Add(data.Rows[t][0].ToString());
        }
    }


    private void AddMenuPower()
    {
        //增加菜单权限信息
        ArrayList list = new ArrayList();
        GetAllCheckedNode(treMenu.Nodes, list);

        string[] menus;
        ArrayList meunNoList = new ArrayList();

        //取得所有选择的菜单项,插入角色权限对象表(TD_M_ROLEPOWER)表中
        context.DBOpen("Insert");

        for (int i = 0; i < list.Count; i++)
        {
            menus = list[i].ToString().Split(new char[1] { '/' });
            if (menus.Length > 2)
            {
                if (!meunNoList.Contains(menus[1]))
                {
                    context.ExecuteNonQuery("insert into TD_M_ROLEPOWER(ROLENO,	POWERCODE,	POWERTYPE) " +
                        "values('" + selRole.SelectedValue + "','" + menus[1] + "','1')");

                    meunNoList.Add(menus[1]);

                }
                context.ExecuteNonQuery("insert into TD_M_ROLEPOWER(ROLENO,	POWERCODE,	POWERTYPE) " +
                      "values('" + selRole.SelectedValue + "','" + menus[2] + "','1')");
            }
        }

        context.DBCommit();
    }

    private void AddOperPower()
    {
        //增加操作权限信息
        context.DBOpen("Insert");
        foreach (GridViewRow gvr in lvwPower.Rows)
        {
            //取得操作权限列表中选择的记录行
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBoxs");
            if (cb != null && cb.Checked)
            {
                context.ExecuteNonQuery("insert into TD_M_ROLEPOWER(ROLENO,	POWERCODE,	POWERTYPE) " +
                            "values('" + selRole.SelectedValue + "','" + gvr.Cells[1].Text + "','2')");
            }
        }
        context.DBCommit();
    }


    private void GetAllCheckedNode(TreeNodeCollection tnc, ArrayList list)
    {
        //取得树形菜单中已选择的节点

        foreach (TreeNode tn in tnc)
        {
            if (tn.Checked == true)
            {
                if (tn.ChildNodes.Count == 0)
                {
                    list.Add(tn.ValuePath.ToString());
                }
            }
            if (tn.ChildNodes.Count > 0)
            {
                GetAllCheckedNode(tn.ChildNodes, list);
            }
        }
    }




}
