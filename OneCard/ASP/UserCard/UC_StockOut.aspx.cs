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
using PDO.UserCard;
using Common;
using TM;
using TDO.UserManager;
using PDO.PersonalBusiness;

// 用户卡出库处理

public partial class ASP_UserCard_UC_StockOut : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        txtFromCardNo.Attributes["OnBlur"] = "javascript:return Change();";
        txtToCardNo.Attributes["OnBlur"] = "javascript:return Change();";
        setReadOnly(txtCardSum);

        // 选取拥有领用权限的员工，生成列表
        UserCardHelper.selectAssignableStaffs(context, selAssignedStaff, false);

        // 服务周期
        selServiceCycle.Items.Add(new ListItem("00:年度", "00"));
        selServiceCycle.Items.Add(new ListItem("01:季度", "01"));
        selServiceCycle.Items.Add(new ListItem("02:月份", "02"));
        selServiceCycle.Items.Add(new ListItem("03:天数", "03"));
        selServiceCycle.Items[2].Selected = true;

        // 退值（模式）

        selRetValMode.Items.Add(new ListItem("0:不退值", "0"));
        //selRetValMode.Items.Add(new ListItem("有条件退值", "1"));
        selRetValMode.Items.Add(new ListItem("2:无条件退值", "2"));
        selRetValMode.Items[1].Selected = true;

        //add by jiangbb 2012-05-10
        //售卡方式
        selSaleType.Items.Add(new ListItem("01:卡费", "01"));
        selSaleType.Items.Add(new ListItem("02:押金", "02"));
        selSaleType.Items[0].Selected = true;
    }

    // 输入校验处理
    private void SubmitValidate()
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);

        //对卡服务费进行非空、数字检验


        UserCardHelper.validatePrice(context, txtServiceFee, "A002P02009: 卡服务费不能为空", "A002P02010: 卡服务费必须是10.2的格式");
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtFromCardNo.Text;
        bool smkFromCard = TMStorePModule.Excute(context, smkpdo);

        smkpdo.CARDNO = txtToCardNo.Text;
        bool smkToCard = TMStorePModule.Excute(context, smkpdo);
        if (smkFromCard == false || smkToCard == false)
        {
            return;
        }

        SubmitValidate();
        if (context.hasError()) return;

        // 调用出库存储过程
        SP_UC_StockOut_COMMITPDO pdo = new SP_UC_StockOut_COMMITPDO();
        pdo.fromCardNo = txtFromCardNo.Text;                  // 起始卡号
        pdo.toCardNo = txtToCardNo.Text;                      // 结束卡号
        pdo.assignedStaff = selAssignedStaff.SelectedValue;   // 领用员工
        pdo.serviceCycle = selServiceCycle.SelectedValue;     // 服务周期
        pdo.serviceFee = Validation.getPrice(txtServiceFee);  // 每期服务费

        pdo.retValMode = selRetValMode.SelectedValue;         // 退值模式
        
        //add by jiangbb 2012-05-10
        pdo.saleType = selSaleType.SelectedValue;   //售卡方式
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("D002P02000: 出库成功");
            //重新查询保证金账户

            queryDepositAcc();
        }
    }

    protected void selAssignedStaff_Change(object sender, EventArgs e)
    {
        //查询保证金账户

        queryDepositAcc();
    }
    protected void queryDepositAcc()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryStaffIsDeptBal", selAssignedStaff.SelectedValue);
        //如果查询结果存在并且员工所属网点结算单元为代理营业厅

        if (data.Rows.Count != 0 && data.Rows[0]["DEPTTYPE"].ToString().Equals("1"))
        {
            //查询保证金账户

            DataTable dataDeposit = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalUnitDeposit", data.Rows[0]["DBALUNITNO"].ToString());
            if (dataDeposit.Rows.Count == 0)
            {
                //查询结果为空
                context.AddError("代理营业厅网点结算单元没有保证金账户！");
                return;
            }
            else
            {
                labDeposit.Text = dataDeposit.Rows[0]["DEPOSIT"].ToString();
                //获取可领卡价值额度，网点剩余卡价值

                DeptBalunitHelper.SetDeposit(context, data.Rows[0]["DBALUNITNO"].ToString(), labDeposit, labUsablevalue, labStockvalue);
                //labUsablevalue.Text = dataDeposit.Rows[0]["USABLEVALUE"].ToString();
                //labStockvalue.Text = dataDeposit.Rows[0]["STOCKVALUE"].ToString();
                //获取卡价值

                double cardValue = Convert.ToDouble(dataDeposit.Rows[0]["TAGVALUE"]);
                labMaxAvailaCard.Text = ((int)(Convert.ToDouble(labUsablevalue.Text) / cardValue)).ToString();
            }
        }
        else
        {
            //清空
            labDeposit.Text = "";
            labUsablevalue.Text = "";
            labStockvalue.Text = "";
            labMaxAvailaCard.Text = "";
        }
    }
}
