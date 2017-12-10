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
using PDO.GroupCard;
using PDO.PersonalBusiness;
using System.Collections.Generic;

public partial class ASP_GroupCard_GC_AccPassReset : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
    }
    

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        
        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            // （1）查询卡资料
            String sql = "SELECT CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO," +
                         " CUSTADDR,CUSTPOST, CUSTPHONE,CUSTEMAIL  " +
                         " FROM  TF_F_CUSTOMERREC " +
                         " WHERE CARDNO = '" + txtCardno.Text + "'";
            TMTableModule tm = new TMTableModule();
            DataTable data = null;
            data = tm.selByPKDataTable(context, sql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                context.AddError("A001107112");//无法查询卡片资料
            }
            else
            {
                //add by jiangbb 解密
                CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

                Object[] row = data.Rows[0].ItemArray;
                labOldName.Text = getCellValue(row[0]);
                labOldSex.Text = getCellValue(row[1]);
                labOldBirth.Text = getCellValue(row[2]);
                labOldPaperType.Text = getCellValue(row[3]);
                labOldPaperNo.Text = getCellValue(row[4]);
                labOldAddr.Text = getCellValue(row[5]);
                labOldPost.Text = getCellValue(row[6]);
                labOldPhone.Text = getCellValue(row[7]);
                txtEmail.Text = getCellValue(row[8]);
            }

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                labOldPaperNo.Text = CommonHelper.GetPaperNo(labOldPaperNo.Text);
                labOldPhone.Text = CommonHelper.GetCustPhone(labOldPhone.Text);
                labOldAddr.Text = CommonHelper.GetCustAddress(labOldAddr.Text);
            }

            // （2）查询有效的企服卡对应的集团客户编码
            sql = " SELECT c.CORPNAME                          " +
                " FROM   TD_GROUP_CARD t, TD_GROUP_CUSTOMER c" +
                " WHERE  t.USETAG = '1'                      " +
                " AND    t.CORPNO = c.CORPCODE               " +
                " AND    t.CARDNO = '" + txtCardno.Text + "'";
            data = tm.selByPKDataTable(context, sql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                context.AddError("A004111013");//无法查询到企服卡对应的集团客户
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                labOldCorp.Text = (string)row[0];
            }

            // （3） 查询卡的企服卡帐户余额

            sql = "SELECT OFFERMONEY FROM TF_F_CARDOFFERACC WHERE CARDNO = '" + txtCardno.Text + "'";
            data = tm.selByPKDataTable(context, sql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                context.AddError("A001107107");//无法查询企服卡帐户余额
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                labOldBalance.Text = (Convert.ToDouble(row[0]) / 100).ToString("0.00");
                //labOldBalance.Text = ((double)row[0] / 100.00).ToString("0.00");
            }

            // （4） 查询卡片状态

            sql = " SELECT b.RESSTATE                       " +
                " FROM TL_R_ICUSER        a,              " +
                "      TD_M_RESOURCESTATE b               " +
                " WHERE a.RESSTATECODE    = b.RESSTATECODE" +
                " AND   a.CARDNO = '" + txtCardno.Text + "'";
            data = tm.selByPKDataTable(context, sql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                context.AddError("A001001101");//无法查询卡片状态
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                labOldState.Text = (string)row[0];
            }

            if (context.hasError())
            {
                return;
            }

            btnSubmit.Enabled = true;
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SP_GC_AccPassResetPDO pdo = new SP_GC_AccPassResetPDO();
        pdo.cardNo = txtCardno.Text;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("M004111100");

        btnSubmit.Enabled = false;

        if (ok)
        {
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }
    }
}
