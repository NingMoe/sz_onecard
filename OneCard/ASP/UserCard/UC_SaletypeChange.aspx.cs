using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using PDO.PersonalBusiness;

/***************************************************************
 * 功能名: 用户卡_更改售卡方式
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/09    liuhe			初次开发
 * 
 ****************************************************************/
public partial class ASP_UserCard_UC_SaletypeChange : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        txtFromCardNo.Attributes["OnBlur"] = "javascript:return Change();";
        txtToCardNo.Attributes["OnBlur"] = "javascript:return Change();";
        setReadOnly(txtCardSum);

        //售卡方式
        selSaleType.Items.Add(new ListItem("01:卡费", "01"));
        selSaleType.Items.Add(new ListItem("02:押金", "02"));
        selSaleType.Items[0].Selected = true;
    }


    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError()) return;

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

        context.SPOpen();
        context.AddField("P_FROMCARDNO").Value = txtFromCardNo.Text;
        context.AddField("P_TOCARDNO").Value = txtToCardNo.Text;
        context.AddField("P_SALETYPE").Value = selSaleType.SelectedValue;

        bool ok = context.ExecuteSP("SP_UC_SaletypeChange");


        if (ok) AddMessage("D002P05000: 更改售卡方式成功");

    }
}
