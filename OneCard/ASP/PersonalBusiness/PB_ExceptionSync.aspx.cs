using Common;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataExchange;

public partial class ASP_PersonalBusiness_PB_ExceptionSync : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //GridView绑定为空
        clearGridView();

        //标题
        LabExText.Text = radioExType.SelectedItem.Text + "信息";
        btnSubmit.Enabled = false;
    }

    // 分页    
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataSource = CreateQueryDataSource();
        gvResult.DataBind();
    }

    public void clearGridView()
    {
        //清空列表
        gvResult.DataSource = new DataView();
        gvResult.DataBind();
    }

    //查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //清空列表
        clearGridView();

        //判断查询条件        
        if (!QueryValidation()) return;

        LabExText.Text = radioExType.SelectedItem.Text + "信息";

        if (radioExType.SelectedValue == "0")       //同步未成功
        {
            radioType.SelectedIndex = 2;
            radioType.Items[0].Enabled = true; //作废同步按钮启用
            radioType.Items[1].Enabled = false;//取消作废按钮禁用
            radioType.Items[2].Enabled = true;//重新同步按钮启用            
        }
        else if (radioExType.SelectedValue == "3")   //已作废
        {
            radioType.SelectedIndex = 1;
            radioType.Items[0].Enabled = false; //作废同步按钮禁用
            radioType.Items[1].Enabled = true;//取消作废按钮启用
            radioType.Items[2].Enabled = false;//重新同步按钮禁用            
        }

        if (radioExType.SelectedValue == "5")       //未同步
        {
            radioType.SelectedIndex = 2;
            radioType.Items[0].Enabled = true; //作废同步按钮启用
            radioType.Items[1].Enabled = false;//取消作废按钮禁用
            radioType.Items[2].Enabled = true;//重新同步按钮启用            
        }
        //绑定GridView
        DataView dv = (DataView)CreateQueryDataSource();
        if (dv.Count == 0)
        {
            context.AddError("查询结果为空");
            btnSubmit.Enabled = false;
        }
        else
        {
            gvResult.DataSource = dv;
            gvResult.DataBind();
            btnSubmit.Enabled = true;
        }
    }

    // 查询存储过程    
    public ICollection CreateQueryDataSource()
    {
        StringBuilder strBuilderName = new StringBuilder();
        AESHelp.AESEncrypt(txtName.Text, ref strBuilderName);

        StringBuilder strPaperNo = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text, ref strPaperNo);

        DataTable data = new DataTable();
        DataView dataView = new DataView();
        if (radioExType.SelectedValue == "5")
        {
            data = SPHelper.callQuery("SP_RC_QUERY", context, "QureyExceptionNotSync", ddlTradeType.SelectedValue, strBuilderName.ToString(), ddlPaperType.SelectedValue, strPaperNo.ToString(), radioExType.SelectedValue);
        }
        else
        {
            data = SPHelper.callQuery("SP_RC_QUERY", context, "QureyExceptionSync", ddlTradeType.SelectedValue, strBuilderName.ToString(), ddlPaperType.SelectedValue, strPaperNo.ToString(), radioExType.SelectedValue);
        }
        dataView = new DataView(data);

        if (dataView.Count != 0)
        {
            //解密
            CommonHelper.AESDeEncrypt(dataView, new List<string>(new string[] { "NAME", "PAPER_NO", "OLD_NAME", "OLD_PAPER_NO" }));
        }
        return dataView;
    }

    private bool QueryValidation()
    {
        //姓名
        if (txtName.Text.Trim() != "")
        {
            if (Validation.strLen(txtName.Text.Trim()) > 40)
            {
                context.AddError("姓名字符长度不能超过20位", txtName);
            }
        }

        //证件号码
        if (txtPaperNo.Text.Trim() != "")
        {
            if (Validation.strLen(txtPaperNo.Text.Trim()) > 20)
            {
                context.AddError("证件号码长度不能超过20位", txtPaperNo);
            }
            else if (!Validation.isCharNum(txtPaperNo.Text.Trim()))
            {
                context.AddError("证件号码不为英数", txtPaperNo);
            }
            if (ddlPaperType.SelectedValue == "00" && Validation.strLen(txtPaperNo.Text.Trim()) < 15)
            {
                context.AddError("身份证件号码长度不能少于15位", txtPaperNo);
            }
        }
        return !(context.hasError());
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (radioType.SelectedValue == "0") //重新同步
        {
            ReSync();
        }
        else if (radioType.SelectedValue == "1") //作废同步
        {
            RollbackSync();
        }
        else if (radioType.SelectedValue == "2") //取消作废同步
        {
            CancelRollbackSync();
        }
        btnSubmit.Enabled = false;
        //gvResult.DataSource = CreateQueryDataSource();
        //gvResult.DataBind();
        clearGridView();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[1].Text == "9501")
            {
                e.Row.Cells[1].Text = "单笔申请";
            }
            if (e.Row.Cells[1].Text == "9505")
            {
                e.Row.Cells[1].Text = "换卡申请";
            }
            if (e.Row.Cells[1].Text == "9506")
            {
                e.Row.Cells[1].Text = "信息变更";
            }
            if (e.Row.Cells[1].Text == "9507")
            {
                e.Row.Cells[1].Text = "注销申请";
            }
            if (e.Row.Cells[1].Text == "9508")
            {
                e.Row.Cells[1].Text = "售卡返销";
            }
            if (e.Row.Cells[1].Text == "9510")
            {
                e.Row.Cells[1].Text = "换卡返销";
            }
            if (e.Row.Cells[1].Text == "9511")
            {
                e.Row.Cells[1].Text = "退卡返销";
            }
        }
    }

    //全选信息记录
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        GridView gv = new GridView();
        gv = gvResult;
        foreach (GridViewRow gvr in gv.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    // 重新同步
    protected void ReSync()
    {
        int count = 0;
        for (int i = 0; i < gvResult.Rows.Count; i++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[i].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string tradeid = gvResult.Rows[i].Cells[2].Text.Trim();
                string cardno = gvResult.Rows[i].Cells[3].Text.Trim();
                string syncSysCode = "SZZJG";
                //重新调用接口
                DataTable data = SPHelper.callQuery("SP_RC_QUERY", context, "QureySync", tradeid, cardno, syncSysCode);

                //姓名，证件号码解密
                CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "NAME", "PAPER_NO", "OLD_NAME", "OLD_PAPER_NO" }));
                if (data.Rows.Count > 0)
                {
                    for (int j = 0; j < data.Rows.Count; j++)
                    {
                        //新证件类型转换
                        string npaperType = data.Rows[j]["PAPER_TYPE"].ToString();
                        switch (npaperType)
                        {
                            case "00": data.Rows[j]["PAPER_TYPE"] = "0"; break;//身份证
                            case "01": data.Rows[j]["PAPER_TYPE"] = "8"; break;//学生证
                            case "02": data.Rows[j]["PAPER_TYPE"] = "6"; break;//军官证
                            case "05": data.Rows[j]["PAPER_TYPE"] = "2"; break;//护照
                            case "06": data.Rows[j]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证
                            case "07": data.Rows[j]["PAPER_TYPE"] = "1"; break;//户口簿
                            case "08": data.Rows[j]["PAPER_TYPE"] = "8"; break;//武警证
                            case "09": data.Rows[j]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证
                            case "99": data.Rows[j]["PAPER_TYPE"] = "8"; break;//其它类型证件
                            default: break;

                        }
                        //旧证件类型转换
                        string opaperType = data.Rows[j]["OLD_PAPER_TYPE"].ToString();
                        switch (opaperType)
                        {
                            case "00": data.Rows[j]["OLD_PAPER_TYPE"] = "0"; break;
                            case "01": data.Rows[j]["OLD_PAPER_TYPE"] = "8"; break;
                            case "02": data.Rows[j]["OLD_PAPER_TYPE"] = "6"; break;
                            case "05": data.Rows[j]["OLD_PAPER_TYPE"] = "2"; break;
                            case "06": data.Rows[j]["OLD_PAPER_TYPE"] = "3"; break;
                            case "07": data.Rows[j]["OLD_PAPER_TYPE"] = "1"; break;
                            case "08": data.Rows[j]["OLD_PAPER_TYPE"] = "8"; break;
                            case "09": data.Rows[j]["OLD_PAPER_TYPE"] = "4"; break;
                            case "99": data.Rows[j]["OLD_PAPER_TYPE"] = "8"; break;
                            default: break;
                        }
                    }
                }

                //调用后台接口
                SyncRequest syncRequest;
                bool sync = DataExchangeHelp.ParseFormDataTable(data, tradeid, out syncRequest);
                if (sync == true)
                {
                    SyncRequest syncResponse;
                    string msg;
                    bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse,out msg);
                    if (!succ)
                    {
                        context.AddError("异常信息重新同步失败:" + msg);
                    }
                    else
                    {
                        context.AddMessage(string.Format("异常信息重新同步成功！"));
                        //记录异常同步台账子表
                        RecordReSync(tradeid, cardno, syncSysCode);
                    }
                }
                else
                {
                    context.AddError("调用接口转换错误!");
                }

                //List<SyncRequest> syncRequest;
                //DataExchangeHelp.ParseFormDataTable(data,tradeid,out syncRequest);
                //List<SyncRequest> syncResponse;
                //bool succ = false;
                //if (syncRequest.Count != 0)
                //{
                //    succ = DataExchangeHelp.Sync(syncRequest, out syncResponse);
                //}
                //if (succ)
                //{
                //    context.AddMessage(string.Format("异常信息重新同步成功！"));
                //    //记录异常同步台账子表
                //    RecordReSync(tradeid, cardno, syncSysCode);
                //}
                //else
                //{
                //    context.AddError(string.Format("异常信息重新同步失败！"));
                //}
            }
        }
        if (count == 0)
        {
            context.AddError("没有选中任何行");
        }
    }

    // 作废同步
    protected void RollbackSync()
    {
        for (int i = 0; i < gvResult.Rows.Count; i++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[i].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string tradeid = gvResult.Rows[i].Cells[2].Text.Trim();
                string cardno = gvResult.Rows[i].Cells[3].Text.Trim();
                string syncSysCode = "SZZJG";

                //记录异常同步台账子表
                RecordReSync(tradeid, cardno, syncSysCode);

                bool ok = false;
                // 更新同步台帐子表
                context.DBOpen("StorePro");
                context.AddField("P_TRADEID").Value = tradeid;
                context.AddField("P_CARDNO").Value = cardno;
                context.AddField("P_SYNCSYSCODE").Value = syncSysCode;
                context.AddField("P_STATE").Value = "3";
                ok = context.ExecuteSP("SP_RC_UPDATESYNCSTATE");

                if (ok)
                {
                    context.AddMessage(string.Format("异常同步信息作废成功"));
                }
            }
        }
    }

    // 取消作废同步
    protected void CancelRollbackSync()
    {
        for (int i = 0; i < gvResult.Rows.Count; i++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[i].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string tradeid = gvResult.Rows[i].Cells[2].Text.Trim();
                string cardno = gvResult.Rows[i].Cells[3].Text.Trim();
                string syncSysCode = "SZZJG";

                bool ok = false;
                // 更新同步台帐子表
                context.DBOpen("StorePro");
                context.AddField("P_TRADEID").Value = tradeid;
                context.AddField("P_CARDNO").Value = cardno;
                context.AddField("P_SYNCSYSCODE").Value = syncSysCode;
                context.AddField("P_STATE").Value = "0";
                ok = context.ExecuteSP("SP_RC_UPDATESYNCSTATE");
                if (ok)
                {
                    context.AddMessage(string.Format("异常同步信息取消作废成功"));
                }
            }
        }
    }

    //记录异常同步台账子表
    private void RecordReSync(string tradeid, string cardno, string syncSysCode)
    {
        context.DBOpen("StorePro");
        context.AddField("P_TRADEID").Value = tradeid;
        context.AddField("P_CITIZEN_CARD_NO").Value = cardno;
        context.AddField("P_SYNCSYSCODE").Value = syncSysCode;
        bool ok = false;
        ok = context.ExecuteSP("SP_RC_INSERTRESYNC");
        if (ok)
        {
            context.AddMessage(string.Format("记录异常同步台账子表成功"));
        }
    }
}