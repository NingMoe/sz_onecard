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
using TDO.UserManager;


public partial class ASP_PrivilegePR_PR_LocalParam : Master.Master
{

    protected void btnLocalParam_Click(object sender, EventArgs e)
    {
        if ("true".Equals(hidWriteFlag.Value))
            AddMessage("写入本地参数成功");

        hidWriteFlag.Value = "false";
    }

}

