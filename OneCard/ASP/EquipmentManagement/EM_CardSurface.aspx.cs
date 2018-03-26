//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate>2012-07-27</createDate>
//<description>卡片类型维护</description>
//---------------------------------------------------------------- 
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using TDO.CardManager;
using TM.EquipmentManagement;
using Common;
using System.Collections;

public partial class ASP_EquipmentManagement_EM_CardSurface : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);

            //初始化卡面类型
            UserCardHelper.selectCardFace(context, selCardFaceType, true);
            //初始化税率
            UserCardHelper.selectCardTax(context, ddlTax, true);
        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        DataTable dt = ResourceManageHelper.callQuery(context, "CARDFACE", selCardType.SelectedValue,
            selCardFaceType.SelectedValue, selCardPle.SelectedValue);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        ResourceManageHelper.resetData(gvResult, dt);

        gvResult.SelectedIndex = -1;

        txtCode.Text = "";
        txtName.Text = "";
        txtNote.Text = "";
        selUseTag.SelectedIndex = 0;
        //ddlTax.SelectedIndex = 0;
        txtGoods.Text = "";
        Img.Src = "../../Images/cardface.jpg";
    }


    /// <summary>
    /// 获取图片二进制流文件
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
        int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
        if (index == -1)
        {
            context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png|gif");
            return null;
        }

        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M");
            return null;
        }

        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;
    }

    /// <summary>
    /// 更新图片
    /// </summary>
    /// <param name="p_outcardsamplecode">卡样编码</param>
    /// <param name="buff">图片二进制流文件</param>
    private void UpdateCardSample(string p_outcardsamplecode, byte[] buff)
    {
        context.DBOpen("BatchDML");
        context.AddField(":cardsamplecode", "String").Value = p_outcardsamplecode;
        context.AddField(":BLOB", "BLOB").Value = buff;
        string sql = "UPDATE TD_M_CARDSAMPLE SET CARDSAMPLE = :BLOB WHERE CARDSAMPLECODE = :cardsamplecode";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

    /// <summary>
    /// 添加卡面及卡样
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        if (!ValidateInputData())   //校验卡片类型编码、卡面类型名称
            return;
       
        

        //判断卡面类型编码是否已存在

        TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACETDOIn = new TD_M_CARDSURFACETDO();
        TD_M_CARDSURFACETM tmTD_M_CARDSURFACETM = new TD_M_CARDSURFACETM();
        ddoTD_M_CARDSURFACETDOIn.CARDSURFACECODE = txtCode.Text.Trim();

        if (!tmTD_M_CARDSURFACETM.chkCardSurface(context, ddoTD_M_CARDSURFACETDOIn))
        {
            context.AddError("A006114010", txtCode);
            return;
        }        

        context.SPOpen();
        context.AddField("p_cardsurfacecode").Value = txtCode.Text.Trim();
        context.AddField("p_cardsurfacename").Value = txtName.Text.Trim();
        context.AddField("p_cardsurfacenote").Value = txtNote.Text.Trim();
        context.AddField("p_usetag").Value = selUseTag.SelectedValue;
        context.AddField("p_cardtax").Value = ddlTax.SelectedValue;
        context.AddField("p_goodsno").Value = txtGoods.Text.Trim();
        if (FileUpload1.FileName != "") //上传文件路径不为空，同时添加卡样
            context.AddField("p_hascardsample").Value = "1";
        else //不添加卡样
            context.AddField("p_hascardsample").Value = "0";
        context.AddField("p_outcardsamplecode", "String", "output", "6", null);
        bool ok = context.ExecuteSP("SP_EM_CARDFACEADD");
        if (ok)
        {
            string p_outcardsamplecode = context.GetFieldValue("p_outcardsamplecode").ToString();

            if (FileUpload1.FileName != "")     //上传文件路径不为空
            {
                UpdateCardSample(p_outcardsamplecode, GetPicture(FileUpload1));    //更新卡样编码表卡样
            }

            AddMessage("添加卡面编码成功");

            btnQuery_Click(sender, e);
            gvResult_SelectedIndexChanged(sender, e);
        }
    }

    //删除
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (ResourceManageHelper.ReadPicture(context, gvResult.SelectedRow.Cells[3].Text.ToString()) == null)
        {
            context.AddError("A094780003");
            return;
        }
        context.SPOpen();
        context.AddField("p_cardsurfacecode").Value = gvResult.SelectedRow.Cells[1].Text.Split(':')[0].ToString();
        bool ok = context.ExecuteSP("SP_EM_CARDFACEDELETE");
        if (ok)
        {
            AddMessage("删除卡样成功");
            btnQuery_Click(sender, e);
        }

    }

    //修改操作
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("A094780001");
            return;
        }
        if (!ValidateInputData())   //校验卡片类型编码、卡面类型名称
            return;

        if (txtCode.Text.Trim() != gvResult.SelectedRow.Cells[1].Text.Split(':')[0].ToString())
        {
            context.AddError("A006114021", txtCode);
            return;
        }
        byte[] oldByte = ResourceManageHelper.ReadPicture(context, gvResult.SelectedRow.Cells[3].Text.ToString());
        byte[] newByte = FileUpload1.FileName == "" ? null : GetPicture(FileUpload1);
        if (context.hasError())
        {
            return;
        }
        context.SPOpen();
        context.AddField("p_cardsurfacecode").Value = txtCode.Text.Trim();
        context.AddField("p_cardsurfacename").Value = txtName.Text.Trim();
        context.AddField("p_cardsurfacenote").Value = txtNote.Text.Trim();
        context.AddField("p_usetag").Value = selUseTag.SelectedValue;
        context.AddField("p_cardtax").Value = ddlTax.SelectedValue;
        context.AddField("p_goodsno").Value = txtGoods.Text.Trim();
        string p_exchange = string.Empty;
        if (oldByte == newByte)     //旧卡样与新卡样文件相同
        {
            p_exchange = "1";

        }
        else if (oldByte == null && newByte != null)    //旧卡样为空，新卡样
        {
            p_exchange = "2";
        }
        else if (oldByte != null && newByte == null)    //有旧卡样
        {
            p_exchange = "3";
        }
        else            //新旧卡样不同
        {
            p_exchange = "4";
        }
        context.AddField("p_exchange").Value = p_exchange;
        context.AddField("p_outcardsamplecode", "String", "output", "6", null);
        bool ok = context.ExecuteSP("SP_EM_CARDFACEMODIFY");

        if (ok)
        {
            if (p_exchange == "4" || p_exchange == "2")
            {
                string p_outcardsamplecode = context.GetFieldValue("p_outcardsamplecode").ToString();

                UpdateCardSample(p_outcardsamplecode, newByte);    //更新卡样编码表卡样
            }

            AddMessage("修改卡面信息成功");
            btnQuery_Click(sender, e);
            gvResult_SelectedIndexChanged(sender, e);
        }
    }
    protected void selCardType_change(object sender, EventArgs e)
    {
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if(e.Row.Cells[7].Text==":")
            {
                e.Row.Cells[7].Text = "";
            }
            
        }
    }

    //分页
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.SelectedIndex = -1;
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            txtCode.Text = row.Cells[1].Text.Split(':')[0].ToString();
            txtName.Text = row.Cells[1].Text.Split(':')[1].ToString();
            txtNote.Text = row.Cells[2].Text.ToString() == "&nbsp;" ? "" : row.Cells[2].Text.ToString();
            selUseTag.SelectedValue = row.Cells[4].Text.ToString() == "无效" ? "0" : "1";
            DateTime d = new DateTime();

            Img.Src = "../ResourceManage/RM_GetPicture.aspx?CardSampleCode=" + row.Cells[3].Text.ToString() + "&d=" + d.ToString();
            ddlTax.SelectedValue = row.Cells[7].Text.Trim() == "" ? "" : row.Cells[7].Text.Trim().Substring(0, 8);
            txtGoods.Text = row.Cells[8].Text.ToString() == "&nbsp;" ? "" : row.Cells[8].Text.ToString();
        }
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    //输入判断处理
    private bool ValidateInputData()
    {
        //卡面编码非空、数字、长度判断

        string strCode = txtCode.Text.Trim();
        if (strCode == "")
        {
            context.AddError("A006114001", txtCode);
        }
        else
        {
            if (!Validation.isNum(strCode))
            {
                context.AddError("A006114002", txtCode);
            }
            if (Validation.strLen(strCode) != 4)
            {
                context.AddError("A006114003", txtCode);
            }

        }

        //卡面编码名称非空、长度判断

        string strName = txtName.Text.Trim();
        if (strName == "")
        {
            context.AddError("A006114004", txtName);
        }
        else if (Validation.strLen(strName) > 40)
        {
            context.AddError("A006114005", txtName);
        }

        //卡面编码说明非空时，长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "")
        {
            if (Validation.strLen(strNote) > 150)
            {
                context.AddError("A006114006", txtNote);
            }
        }

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
        {
            context.AddError("A006114007", selUseTag);
        }

        if (context.hasError())
            return false;
        else
            return true;

    }


}