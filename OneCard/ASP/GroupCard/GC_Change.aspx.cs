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
using System.Text;

// 企服卡后台换卡处理

public partial class ASP_GroupCard_GC_Change : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 初始化证件类型


        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);
    }

    // 输入校验
    private void QueryValidate()
    {
        Validation valid = new Validation(context);
        long oldCard = 0, newCard = 0;

        // 对旧卡号进行非空、长度、数字检验

        bool b = valid.notEmpty(txtOldCardNo, "A004P08001: 旧卡卡号不能为空");
        if (b) b = valid.fixedLength(txtOldCardNo, 16, "A004P08002: 旧卡卡号长度必须是16位");
        if (b) oldCard = valid.beNumber(txtOldCardNo, "A004P08003: 旧卡卡号必须为数字");

        // 对新卡号进行非空、长度、数字检验

        b = valid.notEmpty(txtNewCardNo, "A004P08004: 新卡卡号不能为空");
        if (b) b = valid.fixedLength(txtNewCardNo, 16, "A004P08005: 新卡卡号长度必须是16位");
        if (b) newCard = valid.beNumber(txtNewCardNo, "A004P08006: 新卡卡号必须为数字");

        // 旧卡号不等于新卡号

        if (oldCard > 0 && newCard > 0)
        {
            b = valid.check(oldCard != newCard, "A004P08007: 旧卡卡号不能等于新卡卡号");
        }
    }

    // 获取datatable中字段的值，但字段为空时，返回空字符串

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        btnSubmit.Enabled = true;

        QueryValidate();
        if (context.hasError()) return;

        if (context.hasError())
        {
            btnSubmit.Enabled = false;
        }


        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }

        DataTable data = null;

        // （1）查询旧卡及新卡客户资料
        labOldCardNo.Text = txtOldCardNo.Text;
        readCustInfo(txtOldCardNo.Text, labOldName, labOldBirth,
            labOldPaperType, labOldPaperNo, labOldSex, labOldPhone, labOldPost,
            labOldAddr, labEmail, labRemark);

        // 读取客户资料
        labNewCardNo.Text = txtNewCardNo.Text;
        readCustInfo(chkReplace.Checked ? txtOldCardNo.Text : txtNewCardNo.Text, labNewName, labNewBirth,
            selPaperType, labNewPaperNo, selCustSex, labNewPhone, labNewPost,
            labNewAddr, txtEmail, txtRemark);

        hidForPaperNo.Value = labNewPaperNo.Text.Trim();
        hidForPhone.Value = labNewPhone.Text.Trim();
        hidForAddr.Value = labNewAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            labOldPaperNo.Text = CommonHelper.GetPaperNo(labOldPaperNo.Text);
            labOldPhone.Text = CommonHelper.GetCustPhone(labOldPhone.Text);
            labOldAddr.Text = CommonHelper.GetCustAddress(labOldAddr.Text);

            labNewPaperNo.Text = CommonHelper.GetPaperNo(labNewPaperNo.Text);
            labNewPhone.Text = CommonHelper.GetCustPhone(labNewPhone.Text);
            labNewAddr.Text = CommonHelper.GetCustAddress(labNewAddr.Text);
        }

        // （2）查询有效的企服卡对应的集团客户编码
        data = GroupCardHelper.callQuery(context, "CardCorpName", txtOldCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P08010: 查询不到旧卡对应的集团客户编码");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labOldCorp.Text = (string)row[0];
        }

        labNewCorp.Text = "";

        // （3） 查询旧卡的企服卡帐户余额，新卡企服卡帐户余额初始化为0
        data = GroupCardHelper.callQuery(context, "QueryAccInfo", txtOldCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P08011: 查询不到旧卡的企服卡帐户余额");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            string useTag = (string)row[0];
            if (useTag != "1")
            {
                context.AddError("A004P08012: 旧卡企服卡帐户已经失效");
            }
            labOldBalance.Text = "" + ((int)((decimal)row[1]) / 100.00).ToString("n");
            labNewBalance.Text = "0";
        }

        // （4） 查询旧卡和新卡的卡片状态

        data = GroupCardHelper.callQuery(context, "CardState", txtOldCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P08013: 查询不到旧卡的卡片状态");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labOldState.Text = (string)row[0];
        }

        // 查询新卡卡片状态

        data = GroupCardHelper.callQuery(context, "CardState", txtNewCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P08014: 查询不到新卡的卡片状态");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labNewState.Text = (string)row[0];
        }

        //add by jiangbb 2012-10-09  加入判断 旧卡或新卡为市民卡不会修改客户资料 
        if (!context.hasError() && txtNewCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：新卡卡号为市民卡，客户资料不会被修改");
        }

        btnSubmit.Enabled = !context.hasError();
        chkReplace.Enabled = !context.hasError();
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        StringBuilder strBuilder = new StringBuilder();
        // 调用企服卡后台换卡存储过程

        SP_GC_ChangePDO pdo = new SP_GC_ChangePDO();
        pdo.oldCardNo = labOldCardNo.Text;             // 老卡卡号
        pdo.newCardNo = labNewCardNo.Text;             // 新卡卡号
        pdo.replaceInfo = chkReplace.Checked ? "1" : "0";

        if (!chkReplace.Checked)
        {
            custInfoValidate(labNewName, labNewBirth,
            selPaperType, labNewPaperNo, selCustSex, labNewPhone, labNewPost,
              labNewAddr, txtEmail, txtRemark);
            if (context.hasError()) return;

            //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
            string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == labNewPaperNo.Text.Trim() ? hidForPaperNo.Value : labNewPaperNo.Text.Trim();
            string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == labNewPhone.Text.Trim() ? hidForPhone.Value : labNewPhone.Text.Trim();
            string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == labNewAddr.Text.Trim() ? hidForAddr.Value : labNewAddr.Text.Trim();

            //加密 ADD BY JIANGBB 2012-04-19
            pdo.custName = labNewName.Text;
            AESHelp.AESEncrypt(pdo.custName, ref strBuilder);
            pdo.custName = strBuilder.ToString();

            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custPhone, ref strBuilder);
            pdo.custPhone = strBuilder.ToString();

            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custAddr, ref strBuilder);
            pdo.custAddr = strBuilder.ToString();

            pdo.custBirth = labNewBirth.Text;
            pdo.paperType = selPaperType.SelectedValue;

            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
            pdo.paperNo = strBuilder.ToString();

            pdo.custSex = selCustSex.SelectedValue;
            pdo.custPost = labNewPost.Text;
            pdo.custEmail = txtEmail.Text;
            pdo.remark = txtRemark.Text;
        }

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D004P08000: 企服卡换卡成功");

        btnSubmit.Enabled = false;

        if (ok)
        {
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }
    }


    protected void chkReplace_CheckedChanged(object sender, EventArgs e)
    {
        if (chkReplace.Checked)
        {
            if (txtOldCardNo.Text != "")
            {
                readCustInfo(txtOldCardNo.Text, labNewName, labNewBirth,
                    selPaperType, labNewPaperNo, selCustSex, labNewPhone, labNewPost,
                    labNewAddr, txtEmail, txtRemark);
            }

            setReadOnly(labNewName, labNewBirth,
                selPaperType, labNewPaperNo, selCustSex, labNewPhone, labNewPost,
                labNewAddr, txtEmail, txtRemark);
        }
        else
        {
            clearReadOnly(labNewName, labNewBirth,
               selPaperType, labNewPaperNo, selCustSex, labNewPhone, labNewPost,
               labNewAddr, txtEmail, txtRemark);
            txtRemark.CssClass = "inputlong";
        }

        selCustSex.Enabled = !chkReplace.Checked;
        selPaperType.Enabled = !chkReplace.Checked;
    }
}
