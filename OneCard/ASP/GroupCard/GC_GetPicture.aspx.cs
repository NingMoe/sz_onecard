using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using Master;
using System.Data;

public partial class ASP_GroupCard_GC_GetPicture : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
         String PaperNo = "";
         String ImgType = "";
         String OrderNo = "";
         if (Request.QueryString["CompanyNo"] != null && Request.QueryString["CompanyNo"].ToString() != "")
        {
            PaperNo = Request.QueryString["CompanyNo"].ToString();
        }
         if (Request.QueryString["ImgType"] != null && Request.QueryString["ImgType"].ToString() != "")
         {
             ImgType = Request.QueryString["ImgType"].ToString();
         }
         if (Request.QueryString["OrderNo"] != null && Request.QueryString["OrderNo"].ToString() != "")
         {
             OrderNo = Request.QueryString["OrderNo"].ToString();
         }

         byte[] buffer = ReadPicture(context, PaperNo, ImgType, OrderNo);

        if (buffer == null)
        {
            String path = System.Web.HttpContext.Current.Request.PhysicalApplicationPath + "/Images/cardface.jpg";
            Stream stream = new FileStream(path, System.IO.FileMode.Open, System.IO.FileAccess.Read, FileShare.ReadWrite);
            StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
            byte[] file = new byte[stream.Length];

            using (MemoryStream memstream = new MemoryStream())
            {
                buffer = new byte[stream.Length];
                int bytesRead = default(int);
                while ((bytesRead = reader.BaseStream.Read(buffer, 0, buffer.Length)) > 0)
                    memstream.Write(buffer, 0, bytesRead);
                file = memstream.ToArray();
                ResourceManageHelper.RespondPicture(file, Response);
                stream.Close();
                Response.End();
            }
        }
        else
        {
            ResourceManageHelper.RespondPicture(buffer, Response);
            Response.End();
        }
           
    }
    private byte[] ReadPicture(CmnContext context, string CompanyNo, string ImgType,string OrderNo)
    {
        if (OrderNo=="")//单位订单
        {
            if (ImgType.Equals("compapermsg"))//获取单位证件信息
            {
                string selectSql = "Select COMPANYPAPERMSG From TD_M_BUYCARDCOMINFO Where COMPANYNO=:CompanyNo";
                context.DBOpen("Select");
                context.AddField(":CompanyNo").Value = CompanyNo;
                DataTable dt = context.ExecuteReader(selectSql);
                context.DBCommit();
                if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["COMPANYPAPERMSG"].ToString() != "")
                {
                    return (byte[])dt.Rows[0].ItemArray[0];
                }
            }
            if (ImgType.Equals("commanagermsg"))//获取单位经办人信息
            {
                string selectSql = "Select MANAGERMSG From TD_M_BUYCARDCOMINFO Where COMPANYNO=:CompanyNo";
                context.DBOpen("Select");
                context.AddField(":CompanyNo").Value = CompanyNo;
                DataTable dt = context.ExecuteReader(selectSql);
                context.DBCommit();
                if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["MANAGERMSG"].ToString() != "")
                {
                    return (byte[])dt.Rows[0].ItemArray[0];
                }
            }
        }
        else//个人订单
        {
            string selectSql = "Select MANAGERMSG From TD_M_BUYCARDPERINFO t,TF_F_PERBUYCARDREG a where t.papertype=a.papertype and t.paperno=a.paperno and a.remark=:OrderNo";
            context.DBOpen("Select");
            context.AddField(":OrderNo").Value = OrderNo;
            DataTable dt = context.ExecuteReader(selectSql);
            context.DBCommit();
            if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["MANAGERMSG"].ToString() != "")
            {
                return (byte[])dt.Rows[0].ItemArray[0];
            }
        }
        
       

        return null;
    }
    
}