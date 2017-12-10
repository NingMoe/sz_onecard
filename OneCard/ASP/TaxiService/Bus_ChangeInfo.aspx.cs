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
using TDO.BalanceChannel;
using Common;
using TDO.BusinessCode;
using PDO.TaxiService;

public partial class ASP_TaxiService_Bus_ChangeInfo : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // 性别
            ASHelper.initSexList(selStaffSex);

            //离职标志
            TSHelper.initDismissionTag(selDimissionTag);

            TMTableModule tmTMTableModule = new TMTableModule();
         
            // 证件类型编码表
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            TD_M_PAPERTYPETDO[] ddoTD_M_PAPERTYPEOutArr = (TD_M_PAPERTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), "S003100113", "", null);
            ControlDeal.SelectBoxFill(selPaperType.Items, ddoTD_M_PAPERTYPEOutArr, "PAPERTYPENAME", "PAPERTYPECODE", true);

            //更新按钮不可用
            btnUpdate.Enabled = false;
        }


    }
  

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //清楚界面信息
        ClearDriverInfo();

        //验证工号
        if (IsStaffNoInvalid()) return;

        //查询司机信息
        //查询司机信息

        //查询司机信息
        String sql = "SELECT staff.CARNO, " +
                     "staff.STAFFNAME,staff.STAFFSEX,staff.STAFFPHONE," +
                     "staff.STAFFMOBILE,staff.STAFFPAPERTYPECODE," +
                     "staff.STAFFPAPERNO,staff.STAFFPOST,staff.DIMISSIONTAG," +
                     "staff.STAFFADDR,staff.STAFFEMAIL," +
                     "staff.POSID," +
                     "staff.COLLECTCARDNO, staff.STAFFNO, " +
                     "staff.UPDATESTAFFNO, staff.UPDATETIME " +
                     "FROM TD_M_CALLINGSTAFF staff ";

        ArrayList list = new ArrayList();
     
        list.Add(" staff.CALLINGNO = '01' ");
        list.Add("staff.STAFFNO ='" + txtDriverStaffNo.Text.Trim() + "'");
        sql += DealString.ListToWhereStr(list);

        QueryDriverInfo(sql);

       
    }

    private void QueryDriverInfo(string sql)
    {
        //查询司机信息
        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003103007");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;

            //显示车号
            txtCarNo.Text = getCellValue(row[0]).Trim();

            //显示姓名, 性别, 联系电话, 车载电话
            txtStaffName.Text = getCellValue(row[1]);
            selStaffSex.SelectedValue = getCellValue(row[2]);
            txtContactPhone.Text = getCellValue(row[3]);
            txtCarPhone.Text = getCellValue(row[4]);

            //显示证件类型, 证件号码
            selPaperType.SelectedValue = getCellValue(row[5]);
            txtPaperNo.Text = getCellValue(row[6]);

            //显示邮政编码
            txtPostCode.Text = getCellValue(row[7]);

            //显示离职标志
            selDimissionTag.SelectedValue = getCellValue(row[8]);

            //显示联系地址, 电子邮件
            txtContactAddr.Text = getCellValue(row[9]);
            txtEmailAddr.Text = getCellValue(row[10]);

            //显示POSID, 采集卡号
            txtPosID.Text = getCellValue(row[11]);
            txtCardNo.Text = getCellValue(row[12]);

            //司机工号
            hidDriverStafffNo.Value = getCellValue(row[13]);



            //查询单位名称,部门名称, 更新员工
            QueryNameByCode(getCellValue(row[14]).Trim());

            //查询更新时间
            if(row[15].ToString() !="" ) 
              txtUpdTime.Text = ((DateTime)row[15]).ToString("yyyy-MM-dd HH:mm:ss");

            //启用更新按钮
           btnUpdate.Enabled = true;

        }

    }


    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }


    private void QueryNameByCode(string strStaffNo)
    {
        TMTableModule tm = new TMTableModule();
        DataTable data = null;


        ////查询单位名称
        //if (strUnitNo != "")
        //{
        //    string unitSql = "select CORP from td_m_corp where CORPNO ='" + strUnitNo + "'";

        //    data = tm.selByPKDataTable(context, unitSql, 0);
        //    if (data == null || data.Rows.Count == 0) // 无记录
        //    {
        //        txtUnitName.Text = strUnitNo;
        //    }
        //    else
        //    {
        //        Object[] row = data.Rows[0].ItemArray;
        //        txtUnitName.Text = getCellValue(row[0]);
        //    }
        //}

        ////查询部门名称
        //if (strDeptNo != "")
        //{
        //    string deptSql = "select DEPART from td_m_depart where DEPARTNO ='" + strDeptNo + "'";

        //    data = tm.selByPKDataTable(context, deptSql, 0);
        //    if (data == null || data.Rows.Count == 0) // 无记录
        //    {
        //        txtDeptName.Text = strDeptNo;
        //    }
        //    else
        //    {
        //        Object[] row = data.Rows[0].ItemArray;
        //        txtDeptName.Text = getCellValue(row[0]);
        //    }
        //}


        //查询更新员工代码对应的姓名
        if (strStaffNo != "")
        {
            string staffSql = "select STAFFNAME from td_m_insidestaff where STAFFNO ='" + strStaffNo + "'";

            data = tm.selByPKDataTable(context, staffSql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                txtUpdStaff.Text = strStaffNo;
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                txtUpdStaff.Text = getCellValue(row[0]);
            }
        }

    }

    private Boolean IsStaffNoInvalid()
    {
        //对司机工号进行非空、长度、数字检验
        if (Validation.isEmpty(txtDriverStaffNo))
            context.AddError("A003100001", txtDriverStaffNo);

        else if (Validation.strLen(txtDriverStaffNo.Text) != 6)
            context.AddError("A003100003", txtDriverStaffNo);

        else if (!Validation.isNum(txtDriverStaffNo.Text))
            context.AddError("A003100002", txtDriverStaffNo);

        return context.hasError();
    }


    private void ClearDriverInfo()
    {
        txtStaffName.Text = "";
        selStaffSex.SelectedValue = "";
        txtContactPhone.Text = "";
        txtCarPhone.Text = "";
        txtPaperNo.Text = "";
        txtPostCode.Text = "";
        txtContactAddr.Text = "";
        txtEmailAddr.Text = "";
        txtPosID.Text = "";
        txtCarNo.Text = "";
        txtCardNo.Text = "";
        txtUpdStaff.Text = "";
        txtUpdTime.Text = "";

        selDimissionTag.SelectedValue = "";
        selPaperType.SelectedValue = "";

    }

    //更新司机信息
    protected void Update_Click(object sender, EventArgs e)
    {
       if( UpdateValidFalse()) return;

       SP_Bus_ChangeInfoPDO pdo = new SP_Bus_ChangeInfoPDO();
       pdo.CALLINGSTAFFNO = txtDriverStaffNo.Text.Trim();
       pdo.CARDNO         = txtCardNo.Text.Trim();
       pdo.CARNO          = txtCarNo.Text.Trim();
       pdo.STAFFNAME      = txtStaffName.Text.Trim();
       pdo.STAFFSEX       = selStaffSex.SelectedValue;
       pdo.STAFFPHONE     = txtContactPhone.Text.Trim();
       pdo.STAFFMOBILE    = txtCarPhone.Text.Trim();
       pdo.STAFFPAPERTYPECODE = selPaperType.SelectedValue;
       pdo.STAFFPAPERNO = txtPaperNo.Text.Trim();
       pdo.STAFFPOST    = txtPostCode.Text.Trim(); 
       pdo.STAFFADDR    = txtContactAddr.Text.Trim();
       pdo.STAFFEMAIL   = txtEmailAddr.Text.Trim();
       pdo.POSID        = txtPosID.Text.Trim();
       pdo.DIMISSIONTAG = selDimissionTag.Text.Trim();

       bool ok = TMStorePModule.Excute(context, pdo);
       if (ok)
       {
           AddMessage("M003110102");
           ClearDriverInfo();

           btnUpdate.Enabled = false;
       }
    }

    private bool UpdateValidFalse()
    {
        //是否查询了司机信息
        if (hidDriverStafffNo.Value == "")
        {
            context.AddError("A003110001", txtDriverStaffNo);
            return true;
        }

        //查询的工号不能修改更新
        if (hidDriverStafffNo.Value != txtDriverStaffNo.Text.Trim())
        {
            context.AddError("A003103046", txtDriverStaffNo);
            return true;
        }

        //员工姓名
        if (!Validation.isEmpty(txtStaffName))
        {

            if (Validation.strLen(txtStaffName.Text) > 20)
                context.AddError("A003100039", txtStaffName);
        }

        //IC卡号
        if (!Validation.isEmpty(txtCardNo))
        {
            if (Validation.strLen(txtCardNo.Text.Trim()) != 16)
                context.AddError("A003102004", txtCardNo);

            else if (!Validation.isNum(txtCardNo.Text.Trim()))
                context.AddError("A003102003", txtCardNo);
        }

        //车号
        if (!Validation.isEmpty(txtCarNo))
        {
            if (Validation.strLen(txtCarNo.Text.Trim()) != 5)
                context.AddError("A003100037", txtCarNo);
            else if (!Validation.isCharNum(txtCarNo.Text.Trim()))
                context.AddError("A003100049", txtCarNo);
        }

        // 联系电话
        if (!Validation.isEmpty(txtContactPhone))
        {
            if (Validation.strLen(txtContactPhone.Text) > 20)
                context.AddError("A003100040", txtContactPhone);
        }

        // 车载电话
        if (!Validation.isEmpty(txtCarPhone))
        {
            if (Validation.strLen(txtCarPhone.Text) > 15)
                context.AddError("A003100041", txtCarPhone);
        }

        // 证件号码
        if (!Validation.isEmpty(txtPaperNo))
        {
            if (Validation.strLen(txtPaperNo.Text) > 20)
                context.AddError("A003100042", txtPaperNo);
            else if (!Validation.isCharNum(txtPaperNo.Text.Trim()))
                context.AddError("A003100020", txtPaperNo);
        }

        // POS编号
        if (!Validation.isEmpty(txtPosID))
        {
            if (Validation.strLen(txtPosID.Text.Trim()) != 6)
                context.AddError("A003100403", txtPosID);
            else if (!Validation.isNum(txtPosID.Text.Trim()))
                context.AddError("A003100402", txtPosID);
        }

        // 电子邮件
        new Validation(context).isEMail(txtEmailAddr);

        // 联系地址
        if (!Validation.isEmpty(txtContactAddr))
        {
            if (Validation.strLen(txtContactAddr.Text) > 50)
                context.AddError("A003100045", txtContactAddr);
        }

        // 邮政编码
        if (!Validation.isEmpty(txtPostCode))
        {
            if (Validation.strLen(txtPostCode.Text) != 6)
                context.AddError("A003100027", txtPostCode);
            else if (!Validation.isNum(txtPostCode.Text))
                context.AddError("A003100026", txtPostCode);
        }

        return context.hasError();
    }

}
