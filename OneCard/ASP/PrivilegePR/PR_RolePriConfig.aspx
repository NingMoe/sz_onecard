<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_RolePriConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_RolePriConfig" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<title>系统设置-角色权限配置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">系统设置-&gt;角色权限配置</div>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" 
                  ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
 
          <!-- #include file="../../ErrorMsg.inc" --> 
          
          <div class="con">
             <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td width="13%"><div align="right">角色名称:</div></td>
                   <td width="87%">
                    <asp:DropDownList ID="selRole" runat="server" CssClass="inputmid" 
                        OnSelectedIndexChanged="selRole_Changed" AutoPostBack="true">
                    </asp:DropDownList>
                   </td>
                  </tr>
               </table>
             </div>
            </div>
            <div class="basicinfohf" >
             <div class="base">菜单项</div>
             <div class="kuang5" >
              <div class="gdtb1" style="height:380px">
              
               <asp:TreeView ID="treMenu" runat="server" ShowLines="True" 
                     ShowCheckBoxes="all" Target = "_self"     >
              </asp:TreeView>
             
            
              </div>      
             </div>
            </div>
            <div class="pipinfohf" >
             <div class="info">操作权限类别</div>
             
             <div class="kuang5" >
             <div class="gdtb1" style="height:380px;">
             
                <asp:GridView ID="lvwPower" runat="server"
                    Width = "95%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="false"
                    PageSize="2"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnRowDataBound="lvw_RowDataBound"
                    >
                       <Columns>
                           <asp:TemplateField>
                            <HeaderTemplate>
                              <asp:CheckBox ID="CheckBox2" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAllPower"  />
                            </HeaderTemplate>
                            <ItemTemplate>
                              <asp:CheckBox ID="ItemCheckBoxs" runat="server"/>
                            </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:BoundField DataField="POWERCODE" HeaderText="操作权限编号"/>
                            <asp:BoundField DataField="POWERNAME" HeaderText="操作权限名称"/>
        
                       </Columns>
                                  
                        <EmptyDataTemplate>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                              <tr class="tabbt">
                                    <td><input type="checkbox" name="checkbox9" id="checkbox12" /></td>
                                    <td>操作权限编号</td>
                                    <td>操作权限名称</td>
                              </tr>
                              </table>
                        </EmptyDataTemplate>
                 </asp:GridView>
             </div>
         
             </div>
            </div>
            <div class="btns">
              <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <asp:Button ID="btnSubmit" runat="server" Text="确定" CssClass="button1" OnClick="btnSubmit_Click" />
                  </td>
                </tr>
              </table>
            
              <label></label>
              <label></label>
            </div>
            <div class="footall"></div>
         
          </ContentTemplate>
        </asp:UpdatePanel>
   
    </form>
</body>
</html>

<script language="javascript" type="text/javascript">  
 function selMenuCode()
 {   
    var o = window.event.srcElement;
    if (o.tagName == "INPUT" && o.type == "checkbox")  //点击treeview的checkbox时触发
    {
       var d=o.id;   //获得当前checkbox的id;
       var e= d.replace("CheckBox","Nodes");//通过查看脚本信息,获得包含所有子节点div的id
       var div= window.document.getElementById(e);//获得div对象
       if(div != null)  //如果不为空则表示,存在子节点
       {
           var check=div.getElementsByTagName("INPUT");//获得div中所有的以input开始的标记
           for(i=0;i<check.length;i++)    
           {
                if(check[i].type=="checkbox") //如果是checkbox
                {
                  check[i].checked=o.checked; //子节点的状态和父节点的状态相同,即达到全选
                }
           }

      }
      else  //点子节点的时候,使父节点的状态改变,即不为全选
      {
          var divid = o.parentElement.parentElement.parentElement.parentElement.parentElement; //子节点所在的div

          var id= divid.id.replace("Nodes","CheckBox"); //获得根节点的id

          var checkbox=divid.getElementsByTagName("INPUT"); //获取所有子节点数
          var s = 0;
          for(i=0; i<checkbox.length; i++)    
           {
              if(checkbox[i].checked)  //判断有多少子节点被选中
              {
                 s++;   
              }
           }
  
          var node =  window.document.getElementById(id);
          if( node == null) return;
          
          
         // if(s==0){             //所有的子节点都没选择时
         //   node.checked = false;
         //   node.indeterminate = false; //父节点灰状态   
         // }
          
         if(s==checkbox.length)  //如果全部选中 或者 选择的是另外一个根节点的子节点 ，
          {  
             // node.indeterminate = false;                     
             node.checked=true; //    则开始的根节点的状态仍然为选中状态
            
          }
          else
          {  //选择部分字节点时,父节点为灰状态                  
              node.checked=false;  //否则为没选中状态     
             //node.indeterminate = true; 
          }
  
      }    

    } 

  }


function TreeView_ToggleNode(data, index, node, lineType, children) 
{
    //只打开一个节点,关闭其他兄弟节点
    var img = node.childNodes[0];
    var newExpandState;
    try {
        //***折叠兄弟节点(Collapse Brothers)-----
        CollapseBrothers(data,children);
        //---------------------------------------
            
        if (children.style.display == "none") 
        {
            children.style.display = "block";
            newExpandState = "e";
            if ((typeof(img) != "undefined") && (img != null)) 
            {
                if (lineType == "l") 
                {
                    img.src = data.images[15];
                }
                else if (lineType == "t") 
                {
                    img.src = data.images[12];
                }
                else if (lineType == "-") 
                {
                    img.src = data.images[18];
                }
                else 
                {
                    img.src = data.images[5];
                }
                img.alt = data.collapseToolTip.replace(/\{0\}/, TreeView_GetNodeText(node));
            }
        }
        else 
        {
            children.style.display = "none";
            newExpandState = "c";
            if ((typeof(img) != "undefined") && (img != null)) 
            {
                if (lineType == "l") 
                {
                    img.src = data.images[14];
                }
                else if (lineType == "t") 
                {
                    img.src = data.images[11];
                }
                else if (lineType == "-") 
                {
                    img.src = data.images[17];
                }
                else 
                {
                    img.src = data.images[4];
                }
                img.alt = data.expandToolTip.replace(/\{0\}/, TreeView_GetNodeText(node));
            }
        }
    }
    catch(e) {}
    data.expandState.value =  data.expandState.value.substring(0, index) + newExpandState + data.expandState.value.slice(index + 1);
}

//折叠兄弟节点(Collapse Brothers)
function CollapseBrothers(data,childContainer)
{
    var parent = childContainer.parentNode;   
    for(i=0; i< parent.childNodes.length; i++)
    {
        if(parent.childNodes[i].tagName.toLowerCase() =="div")
        {
            if(parent.childNodes[i].id != childContainer.id)
            {
                parent.childNodes[i].style.display = "none"
            }
        }
        else if(parent.childNodes[i].tagName.toLowerCase() =="table")
        {
            var treeLinks = parent.childNodes[i].getElementsByTagName("a");            
            if(treeLinks.length > 2)
            {
                var j=0;
                if(treeLinks[j].firstChild.tagName)
                {
                    if(treeLinks[j].firstChild.tagName.toLowerCase() == "img")
                    {
                        var img = treeLinks[j].firstChild;
                        if(i==0) 
                            img.src = data.images[8];
                        else if(i==parent.childNodes.length-2) 
                            img.src = data.images[14];
                        else 
                            img.src = data.images[11];
                    }
                }    
            }
        }        
    }
}



</script>
