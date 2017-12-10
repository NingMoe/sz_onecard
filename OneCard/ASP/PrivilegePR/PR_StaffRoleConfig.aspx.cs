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
using TDO.UserManager;
using TM;
using Common;
using System.Text;

public partial class ASP_PrivilegePR_PR_StaffRoleConfig : Master.Master
{

    private Boolean StaffRoleConfigValidation()
    {
        //对部门名称进行非空检验

        String strselDEPARTNAME = selDEPARTNAME.Text.Trim();

        if (strselDEPARTNAME == "")
            context.AddError("A010005051", selDEPARTNAME);

        //对员工姓名进行非空检验

        String strselSTAFFNAME = selSTAFFNAME.Text.Trim();

        if (strselSTAFFNAME == "")
            context.AddError("A010005052", selSTAFFNAME);

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            UserCardHelper.selectDepts(context, selDEPARTNAME, true);

            UserCardHelper.selectStaffs(context, selSTAFFNAME, selDEPARTNAME, true);

            //指定角色GridView DataKeyNames
            //lvwStaffRoleConfig.DataKeyNames = new string[] { "ROLENO,ROLENAME" };
            lvwStaffRoleConfig.DataSource = CreateStaffRoleQueryDataSource();
            lvwStaffRoleConfig.DataBind();
        }
    }

    public ICollection CreateStaffRoleQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从角色编码表(TD_M_ROLE)中读取数据
        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_ROLEIn, null, "", null, 0);

        DataView dataView = new DataView(data);
        return dataView;
    }

    protected void selDEPARTNAME_SelectedIndexChanged(object sender, EventArgs e)
    {
        UserCardHelper.selectStaffs(context, selSTAFFNAME, selDEPARTNAME, true);
    }

    protected void selSTAFFNAME_SelectedIndexChanged(object sender, EventArgs e)
    {
        findCheckedRole();
    }

    private void findCheckedRole()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //选择员工姓名
        TD_M_INSIDESTAFFROLETDO tdoTD_M_INSIDESTAFFROLEIn = new TD_M_INSIDESTAFFROLETDO();
        tdoTD_M_INSIDESTAFFROLEIn.STAFFNO = selSTAFFNAME.SelectedValue;

        //根据选择的员工，查询出该员工在内部员工与角色对应表(TD_M_INSIDESTAFFROLE)中已有的角色信息，用勾在界面上显示出来

        TD_M_INSIDESTAFFROLETDO[] tdoTD_M_INSIDESTAFFROLEOutArr = (TD_M_INSIDESTAFFROLETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFROLEIn, typeof(TD_M_INSIDESTAFFROLETDO), null, "TD_M_INSIDESTAFFROLENO", null);
        if (tdoTD_M_INSIDESTAFFROLEOutArr != null)
        {
            for (int i = 0; i < lvwStaffRoleConfig.Rows.Count; i++)
            {
                GridViewRow viewRow = lvwStaffRoleConfig.Rows[i];
                String roleNo = viewRow.Cells[1].Text;

                CheckBox ch = (CheckBox)viewRow.FindControl("ItemCheckBox");

                if (tdoTD_M_INSIDESTAFFROLEOutArr.Length == 0)
                    ch.Checked = false;

                for (int index = 0; index < tdoTD_M_INSIDESTAFFROLEOutArr.Length; index++)
                {
                    if (roleNo == tdoTD_M_INSIDESTAFFROLEOutArr[index].ROLENO)
                    {
                        ch.Checked = true;
                        break;
                    }

                    if (index == tdoTD_M_INSIDESTAFFROLEOutArr.Length - 1)
                        ch.Checked = false;
                }
            }
        }

    }


    public String getDataKeys(string keysname)
    {
        return lvwStaffRoleConfig.DataKeys[lvwStaffRoleConfig.SelectedIndex][keysname].ToString();
    }
    
    protected void btnStaffRoleConfig_Click(object sender, EventArgs e)
    {

        //对员工与角色对应关系表进行检验
        if (!StaffRoleConfigValidation())
            return;

        string staffno = selSTAFFNAME.SelectedValue;

        //先清空员工与角色对应关系表中的信息
        context.DBOpen("Delete");
        context.ExecuteNonQuery("DELETE FROM TD_M_INSIDESTAFFROLE where STAFFNO='" + staffno + "'");

        //向员工与角色对应关系表中插入一条记录
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFROLETDO tdoTD_M_INSIDESTAFFROLEIn = new TD_M_INSIDESTAFFROLETDO();
        tdoTD_M_INSIDESTAFFROLEIn.STAFFNO = selSTAFFNAME.SelectedValue;
        
        int count = 0;
        foreach (GridViewRow viewRow in lvwStaffRoleConfig.Rows)
        {
            CheckBox ch = (CheckBox)viewRow.FindControl("ItemCheckBox");
            if (ch != null && ch.Checked)
            {
                ++count;
                
                string roleno = viewRow.Cells[1].Text;
                context.ExecuteNonQuery("insert into TD_M_INSIDESTAFFROLE(STAFFNO,ROLENO,UPDATESTAFFNO,UPDATETIME) " + 
                        " values('" + staffno + "','" + roleno + "','" + context.s_UserID + "', sysdate )");
            }
        }
        
        context.DBCommit();

        AddMessage("M010005114");

    }
  
}
