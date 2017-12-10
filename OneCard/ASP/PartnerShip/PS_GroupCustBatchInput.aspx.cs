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

using System.IO;
using System.Text;
using TM;
using TDO.PartnerShip;
using TDO.CardManager;
using TDO.UserManager;
using PDO.PartnerShip;
using Common;



public partial class ASP_PartnerShip_PS_GroupCustBatchInput : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //设置集团客户信息列表表头
            lvwGroupCustImp.DataSource = new DataTable();
            lvwGroupCustImp.DataBind();
           
            //设置保存按钮不可用
            btnSave.Enabled = false;
        }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        //导入文件

        if (!FileUpload1.HasFile)
        {
            context.AddError("A008110001");
            return;
        }

        int len = FileUpload1.FileBytes.Length;

        if (len <= 0)
        {
            context.AddError("A008110007");
            return;
        }

        if (len > 5 * 1024 * 1024) // 5M
        {
            context.AddError("A008110010");
            return;
        }

        // 首先清空临时表
        clearTempTable();

        context.DBOpen("Insert");

        //读取文件
        Stream stream = FileUpload1.FileContent;
        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
        string strLine = "";
        int lineCount = 0;
        int tempTableSeq = 0;
        String[] fields = null;

        //集团客户编码列表
        ArrayList groupCode = new ArrayList();

        //集团客户名称列表
        ArrayList groupcust = new ArrayList();
        
        //循环读取文件所有记录行
        while ((strLine = reader.ReadLine()) != null)
        {
            ++lineCount;

            strLine = strLine.Trim();

            if (strLine.IndexOf("'") != -1)
            {
                context.AddError("第" + lineCount + "行包含非法字符'");
                continue;
            }

            if (strLine.Length > 316)
            {
                //写文件
                context.AddError("第" + lineCount + "行长度为" + strLine.Length + ", 根据格式定义不能超过347位");
                continue;
            }

            // "42, 12, 19" new Char[] {',', ' '} {"42", "", "12", "", "19"} 
            fields = strLine.Split(new char[1] { ',' });

            // 字段数目为2到8时都合法

            if (fields.Length < 2 || fields.Length > 8)
            {
                context.AddError("第" + lineCount + "行字段数目为" + fields.Length + ", 根据格式定义必须为2个,最多8个");
                continue;
            }


            //一行记录中的集团客户编码,集团客户名称,联系人,联系电话,
            //联系地址,客服经理编码,电子邮件,备注校验
            
            string corpcode = fields[0].Trim();
            if (corpcode == "")
            {
                context.AddError("第" + lineCount + "行集团客户编码长度为空");
            }
            else if (Validation.strLen(corpcode) != 4)
            {
                context.AddError("第" + lineCount + "行集团客户编码长度不是4位");
            }
            else if (!Validation.isCharNum(corpcode))
            {
                context.AddError("第" + lineCount + "行集团客户编码包含英数字以外的字符");
            }

            groupCode.Add(corpcode);
            checkCorp(corpcode, groupCode, lineCount, "客户编码");
          
            //集团客户名称长度校验
            string corpname = fields[1].Trim();
            if ( corpname=="" )
            {
                context.AddError("第" + lineCount + "行集团客户名称长度为空");
            }
            else if (Validation.strLen(corpname) > 50)
            {
                context.AddError("第" + lineCount + "行集团客户名称长度超过50位");
            }
           

            //判断集团客户名称是否重复(文件中,数据库中)
            groupcust.Add(corpname);

            checkCorp(corpname, groupcust, lineCount, "客户名称");

            string linkman = "";
            if (fields.Length > 2)
            {
                linkman = fields[2].Trim();

                //联系人长度的校验
                if (linkman != "" && Validation.strLen(linkman) > 10)
                {
                    context.AddError("第" + lineCount + "行联系人长度超过10位");
                }
            }

          
        
            //联系电话的校验

            string corpphone = "";

            if (fields.Length > 3)
            {
                corpphone = fields[3].Trim();

                if (corpphone != "" && Validation.strLen(corpphone) > 40)
                {
                    context.AddError("第" + lineCount + "行联系电话长度超过40位");
                }
            }

            //联系地址的校验
            string corpadd = "";

            if(fields.Length > 4)    
            {
                corpadd = fields[4].Trim();
                if (corpadd != "" && Validation.strLen(corpadd) > 100)
                {
                    context.AddError("第" + lineCount + "行联系地址长度超过100位");
                }
            }
             
            //客户经理编码的校验
            string sermanagercode = "";

            if (fields.Length > 5)
            {
                sermanagercode = fields[5].Trim();

                if ( sermanagercode != "" && (Validation.strLen(sermanagercode) != 6 || !Validation.isNum(sermanagercode)) )
                {
                    context.AddError("第" + lineCount + "行客户经理编码不是6位数字");
                }
            }

            //电子邮件
            string corpemail = "";

            if (fields.Length > 6)
            {
                corpemail = fields[6].Trim();

                if (corpemail != "")
                {
                    if (Validation.strLen(corpemail) > 30)
                    {
                        context.AddError("第" + lineCount + "行电子邮件长度超过30位");
                    }
                    else
                    {
                        bool retbool = Validation.reg1.IsMatch(corpemail);
                        if (!retbool)
                            context.AddError("第" + lineCount + "行电子邮件无效");
                    }
                }
            }
          

            string remark = "";
            
            //备注的校验
            if (fields.Length > 7 )
            {
               remark = fields[7].Trim();

               if (remark != "" && Validation.strLen(remark) > 100)
               {
                   context.AddError("第" + lineCount + "行备注长度超过100位");
               }
            }
            
            if (!context.hasError())
            {
                //记录插入数据库
                context.ExecuteNonQuery("insert into TMP_GROUP_CUSTOMERIMP values("
                   + (tempTableSeq++) + ",'" + corpcode + "','"
                   + corpname + "', '" + linkman + "','" + corpphone + "','" + corpadd
                   + "','" + sermanagercode + "','" + corpemail + "','" + remark 
                   + "','" + Session.SessionID + "')");
            }
        } 

        if (!context.hasError())
        {
            context.DBCommit();
            createGridViewData();
            AddMessage("M008110111");
        }

        else
        {
            context.RollBack();
            lvwGroupCustImp.DataSource = new DataTable();
            lvwGroupCustImp.DataBind();
            //clearTempTable();
        }
    }

    //public void lvwPaging_Page(Object sender, GridViewPageEventArgs e)
    //{
    //    lvwGroupCustImp.PageIndex = e.NewPageIndex;
    //    createGridViewData();
    //}



    private void createGridViewData()
    {
        //查询临时表TD_GROUP_CUSTOMERIMP中数据

        string sql = "SELECT CORPCODE, CORPNAME, LINKMAN, CORPPHONE, SERMANAGERCODE, CORPEMAIL, CORPADD, REMARK " +
                     "FROM TMP_GROUP_CUSTOMERIMP where SessionId = '" + Session.SessionID + "'";

        TMTableModule tm = new TMTableModule();
        DataTable data = tm.selByPKDataTable(context, sql, 1000);

        lvwGroupCustImp.DataSource = data;
        lvwGroupCustImp.DataBind();

        btnSave.Enabled = true;


    }

    private void checkCorp(string corpname,ArrayList groupcust,int lineCount,string groupInfo)
    {
        //检查本文件中集团客户名称是否有重复
        int count = 0;
        foreach (string i in groupcust)
        {
            if (corpname == i)
            {
                ++count;
            }
        }

        if (count>=2)
        {
            context.AddError("第" + lineCount + "行集团" +groupInfo  + "在本文件中重复");
        }
    }


   


    protected void btnSave_Click(object sender, EventArgs e)
    {
        //保存文件
        SP_PS_GroupCustBatchInputPDO pdo = new SP_PS_GroupCustBatchInputPDO();
        pdo.sessionId = Session.SessionID; 
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M008110112");
           
        }
        clearTempTable();

        lvwGroupCustImp.DataSource = new DataTable();
        lvwGroupCustImp.DataBind();


    }


    private void clearTempTable()
    {
        //删除临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery(" delete from TMP_GROUP_CUSTOMERIMP " +
                              " where SessionId = '" + Session.SessionID + "'");

        context.DBCommit();
    }




}
