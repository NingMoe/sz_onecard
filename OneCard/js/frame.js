function topFrame()
{
	new Ext.Viewport({
	    layout:'border',
	    items:[
	        new Ext.BoxComponent({ 
	            region:'center',
	            el: 'north',
	            height:32
	        })
	     ]
	});
}


function contentFrame(titlename)
{
    var body = document.getElementsByTagName("body")[0].innerHTML;
    document.getElementsByTagName("body")[0].innerHTML =  "<div id='contentcenter'>" + body + "</div>";
	new Ext.Viewport({
	    layout:'border',
	    items:[{
	            region:'center',
	            split:true,
	            collapsible: false,
	            layout:'fit',
	            layoutConfig:{
	                animate:true
	            },
	            items: [{
	                contentEl:'contentcenter',
	                title: titlename,
	                autoScroll:true
	            }]
	        }
	     ]
    });

}

var subsys = [];

var myMenu = [];

function addMenu(titlename)
{
	var ce = 'submenu' + subsys.length;
	document.getElementById('menu').innerHTML += "<DIV class=\"gdtb\"  ID=" + ce + "></DIV>";

	subsys[subsys.length] = {
	    contentEl: ce,
	    title:titlename,
	    border:false,
	    iconCls:'nav'
	};
	myMenu[myMenu.length] = [];
	return myMenu[myMenu.length-1];
}

function addMenuItem(subsysMenu, title, url, target, desc, onclik)
{
	subsysMenu[subsysMenu.length] = ['<img src=js/ThemeXP/home.gif>', title, url, target, desc,onclik];
	return  subsysMenu[subsysMenu.length - 1];
}

function drawMenu()
{
	for(var i = 0; i < myMenu.length; ++i)
	{
		ctDraw ('submenu' + i, myMenu[i], ctThemeXP1, 'ThemeXP', 0, 0);
	}
	new Ext.Viewport({
	    layout:'border',
	    items:[{
	            region:'center',
	            title:'导航菜单',
	            split:true,
	            collapsible: false,
	            margins:'0 0 0 5',
	            layout:'accordion',
	            layoutConfig:{
	                animate:true
	            },
	            items: subsys
	        }
	     ]
});
	
}

