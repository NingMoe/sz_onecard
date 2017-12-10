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
using TDO.ResourceManager;
using PDO.EquipmentManagement;
public partial class ASP_EquipmentManagement_EM_PsamPreInput : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void lvwRelation_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearData();

        

        string posno = getDataKeys("POSNO");
        string psamno = getDataKeys("PSAMNO");
        txtPosNo2.Text = posno;
        txtPsamNo2.Text = psamno;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidateForQuery())
            return;



        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_PSAMPREINPUTTDO tdoPsamPosRec = new TD_M_PSAMPREINPUTTDO();
        
        string strSql = "select POSNO,PSAMNO,PREINPUTTIME from TD_M_PSAMPREINPUT ps";

        ArrayList list = new ArrayList();
        
        if (txtPsamNo1.Text.Trim() != "")
        {
            list.Add("ps.psamno like ( '" + GetSearchString(txtPsamNo1.Text.Trim()) + "')");
            //list.Add("ps.SAMNO in ( '" + txtPsamNo1.Text + "','"+ txtPsamNo1.Text + "0000')");
        }
        if (txtPosNo1.Text.Trim() != "")
        {
            list.Add("ps.POSNO like '" + GetSearchString(txtPosNo1.Text.Trim()) + "'");
        }


        string where = DealString.ListToWhereStr(list);
        strSql = strSql + where;

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoPsamPosRec, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwRelation.DataKeyNames = new string[] { "POSNO", "PSAMNO", "PREINPUTTIME" };
        lvwRelation.DataSource = dataView;
        lvwRelation.DataBind();

        lvwRelation.SelectedIndex = -1;
        ClearData();
    }

    private void ClearData()
    {
       
        txtPosNo1.Text = "";
        txtPsamNo1.Text = "";
    }


    private string GetSearchString(string str)
    {
        return str.Trim() + "%";
    }

    protected void btnBuild_Click(object sender, EventArgs e)
    {
        if (!ValidateInput())
            return;


        //预录入建立


        //调用POS入库存储过程
        SP_EM_PSAMPreInputPDO pdo = new SP_EM_PSAMPreInputPDO();
        pdo.posNo = txtPosNo2.Text.Trim();
        pdo.psamNo = txtPsamNo2.Text.Trim();
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("A860400009");
        }

    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!ValidateInput())
            return;


        //预录入建立


        //调用POS入库存储过程
        SP_EM_CancelPSAMPreInputPDO pdo = new SP_EM_CancelPSAMPreInputPDO();
        pdo.posNo = txtPosNo2.Text.Trim();
        pdo.psamNo = txtPsamNo2.Text.Trim();
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("A860400012");
        }
    }
    protected void lvwRelation_Page(object sender, GridViewPageEventArgs e)
    {
        lvwRelation.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void lvwRelation_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件            
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwRelation','Select$" + e.Row.RowIndex + "')");
        }
    }


    private string getDataKeys(string keysname)
    {
        string ret = lvwRelation.DataKeys[lvwRelation.SelectedIndex][keysname].ToString().Trim();
        return Server.HtmlDecode(ret).Trim();
    }



    private bool ValidateInput()
    {
        //POS编号非空、数字、长度判断


        string strEquipNo = txtPosNo2.Text.Trim();
        if (strEquipNo == "")
            context.AddError("A006001135", txtPosNo2);
        else
        {
            if (!Validation.isNum(strEquipNo))
                context.AddError("A006001136", txtPosNo2);
            if (Validation.strLen(strEquipNo) != 6)
                context.AddError("A006001137", txtPosNo2);
        }


        //PSAM卡号判断：非空、长度12、数字
        string strBeginCardNo = txtPsamNo2.Text.Trim();
        if (strBeginCardNo == "")
            context.AddError("A006001002", txtPsamNo2);
        else
        {
            if (Validation.strLen(strBeginCardNo) != 12)
                context.AddError("A006001003", txtPsamNo2);
            if (!Validation.isNum(strBeginCardNo.Substring(2)) || !Validation.isCharNum(strBeginCardNo.Substring(0, 2)))
                context.AddError("A006001004", txtPsamNo2);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }



      //查询输入判断
    private bool ValidateForQuery()
    {
        Validation valid = new Validation(context);

        //PSAM
        string strPsamNo = txtPsamNo1.Text.Trim();
        if (strPsamNo != "")
        {
            //英文或数字            
            if (!Validation.isCharNum(strPsamNo))
            {
                context.AddError("A006500001", txtPsamNo1);
            }
            //小于12位            
            if (Validation.strLen(strPsamNo) > 12)
            {
                context.AddError("A006500002", txtPsamNo1);
            }

        }

        //当POS非空时，进行数字、长度判断        
        string strPosNo = txtPosNo1.Text.Trim();
        if (strPosNo != "")
        {
            if (!Validation.isNum(strPosNo))
            {
                context.AddError("A006500003", txtPosNo1);
            }
            if (Validation.strLen(strPosNo) > 6)
            {
                context.AddError("A006500004", txtPosNo1);
            }
        }

        if (context.hasError())
            return false;
        else
            return true;
    }
}
