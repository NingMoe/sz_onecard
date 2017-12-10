
function dialog(boxTitle)
{
	var boxTitleBgImg = "";
	var blankBgImg = "Images/blank.gif";
	var shadowPx = 6;
	var boxWidth = 300;
	var boxHeight = 240;
	var divBg = '\
		<div id="dialogBoxBg"></div>\
	';
	var divShadow = '\
		<div id="dialogBoxShadow"></div>\
	';
	
	var divTitle = '\
		<div id="dialogBoxTitle" style="font-weight:bold;" onmousedown="new dialog().moveStart(event, \'dialogBox\')">\
			<span style="float:left;">' + boxTitle + '</span>\
		</div>\
	';
	var divContent = '\
	<div id="dialogBoxContent">\
		<img id="dialogBoxMsgImg" src="" style="float:left;" />\
		<div id="dialogBoxMsg" style="float:right; line-height:20px; text-align:left;"></div>\
	</div>\
	';
	var divButton = '\
	<div id="divBoxBotton" style="text-align:center;">\
		<input id="buttonOk" type="button" value=" 确定 "  onclick="new dialog().close();" /> \
		 <input id="buttonCancel" type="button" value=" 取消 " onclick="new dialog().close();" />\
	</div>\
	';
	var divBox = '\
		<div id="dialogBox">\
			' + divTitle + '\
			' + divContent + '\
			' + divButton + '\
		</div>\
	';
	
	function $(_sId)
	{
		return window.document.getElementById(_sId);
	}
	
	//显示对话框
	this.showBox = function(_sMsg, _sImg, _sOk, _sCancel)
	{
		this.init();
		$('dialogBoxMsg').innerHTML = _sMsg;
		$('dialogBoxMsgImg') ? $('dialogBoxMsgImg').src = '../../Images/' + _sImg + '.gif' : function(){};
		_sOk && _sOk != "" ? this.button('buttonOk', _sOk) : $('buttonOk').style.display = 'none';
		_sCancel && _sCancel != "" ? this.button('buttonCancel', _sCancel) : $('buttonCancel').style.display = 'none';
		if ($('buttonOk').style.display != 'none') $('buttonOk').focus();
	}
	
	//对话框设置
	this.boxSet = function()
	{
		var obj = $('dialogBox');
		
		obj['style']['background']	= "#C7D6E9";
		obj['style']['z-index']	= 10;
		obj['style']['border']	= "1px solid #336699";
		obj['style']['width'] = boxWidth + "px";
		obj['style']['height'] = boxHeight + "px";
		obj['style']['display']	= "";
	}
	
	//对话框标题栏设置
	this.titleSet = function()
	{
		var obj = $('dialogBoxTitle');
		
		obj['style']['color'] = "#15428B";
		obj['style']['background']	= "#C4D3E8";
		obj['style']['height'] = "14px";
		obj['style']['padding'] = "6px 8px";
		obj['style']['cursor'] = "move";
		obj['style']['display'] = "";
	}
		
		
	//对话框标题栏的确定按钮设置
	this.okSet = function()
	{
		var obj = $('buttonOk');
		
		obj['style']['cursor'] = "hand";
		obj['style']['width']	= "75px";
		obj['style']['padding'] = "2px 0px 0px 0px";
		obj['style']['font'] = "normal 12px 宋体,Verdana";
		obj['style']['color'] = "#001037";
		obj['style']['border'] = "1px solid #003C74";
		obj['style']['background'] = "#F7FCFF url(images/bg_btn.gif)";
	}
		
	//对话框标题栏的取消按钮设置
	this.cancelSet = function()
	{
		var obj = $('buttonCancel');
		
		obj['style']['cursor'] = "hand";
		obj['style']['width']	= "75px";
		obj['style']['padding'] = "2px 0px 0px 0px";
		obj['style']['font'] = "normal 12px 宋体,Verdana";
		obj['style']['color'] = "#001037";
		obj['style']['border'] = "1px solid #003C74";
		obj['style']['background'] = "#F7FCFF url(images/bg_btn.gif)";
	}
		
	//对话框内容设置
	this.contentSet = function()
	{
		var obj = $('dialogBoxContent');
		
		obj['style']['width']	= boxWidth + "px";
		obj['style']['height'] = (boxHeight - 80) + "px";
		obj['style']['display'] = "";
	}
	
	//对话框信息图片设置
	this.msgImgSet = function()
	{
		var obj = $('dialogBoxMsgImg');
		
		obj['style']['position'] = "relative";
		obj['style']['left'] = "10px";
		obj['style']['top'] = "15px";
		obj['style']['display'] = "";
	}
	
	//对话框信息设置
	this.msgSet = function()
	{
		var obj = $('dialogBoxMsg');
		
		obj['style']['left'] = "5px";
		obj['style']['font'] = "normal 16px 宋体,Verdana";
		obj['style']['width'] = (boxWidth - 60) + "px";
		obj['style']['padding']	= "12px 0px 0px 0px";
		obj['style']['display'] = "";
	}
	
	//对话框阴影设置
	this.shadowSet = function()
	{
		var obj = $('dialogBoxShadow');
		var objDialog = $('dialogBox');
		
		obj['style']['position'] = "absolute";
		obj['style']['background']	= "#000000";
		obj['style']['z-index']	= 9;
		obj['style']['opacity']	= "0.2";
		obj['style']['filter'] = "alpha(opacity=30)";
		obj['style']['top'] = objDialog.offsetTop + shadowPx +"px";
		obj['style']['left'] = objDialog.offsetLeft + shadowPx + "px";
		obj['style']['width'] = boxWidth + "px";
		obj['style']['height'] = boxHeight + "px";
		obj['style']['display'] = "";
	}
	
	//大背景设置
	this.bgSet = function()
	{
		var obj = $('dialogBoxBg');
		
		obj['style']['position'] = "absolute";
		obj['style']['background']	= "#000000 url(" + blankBgImg + ")";
		obj['style']['z-index']	= 8;
		obj['style']['top'] = "0px";
		obj['style']['left'] = "0px";
		obj['style']['width'] = "100%";
		obj['style']['height'] = window.document.body.scrollHeight + "px";
		obj['style']['height'] = "100%";
		obj['style']['display'] = "";
		obj['style']['filter'] = "alpha(opacity=30)";
	}
	
	//初始化对话框
	this.init = function()
	{
		$('dialogCase') ? $('dialogCase').parentNode.removeChild($('dialogCase')) : function(){};
		var oDiv = window.document.createElement('span');
		oDiv.id = "dialogCase";
		oDiv.innerHTML = divBg + divShadow + divBox;
		window.document.body.appendChild(oDiv);
		
		this.boxSet();
		this.titleSet();
		this.okSet();
		this.cancelSet();
		this.contentSet();
		this.msgImgSet();
		this.msgSet();
		
		this.middle('dialogBox');
		
		this.shadowSet();
		this.bgSet();
	}
	
	//关闭对话框
	this.close = function()
	{
		$('dialogBoxBg')['style']['display'] = 'none';
		$('dialogBox')['style']['display'] = 'none';
		$('dialogBoxTitle')['style']['display'] = 'none';
		$('dialogBoxContent')['style']['display'] = 'none';
		$('dialogBoxMsgImg')['style']['display'] = 'none';
		$('dialogBoxMsg')['style']['display'] = 'none';
		$('divBoxBotton')['style']['display'] = 'none';
		$('dialogBoxShadow')['style']['display'] = 'none';
	}
	
	//按钮的动作
	this.button = function(_sId, _sFuc)
	{
		if($(_sId))
		{
			$(_sId).style.display = '';
			if($(_sId).addEventListener)
			{
				if($(_sId).act)
				{
					$(_sId).removeEventListener('click', $(_sId).act, false);
				}
				$(_sId).act = _sFuc;
				$(_sId).addEventListener('click', _sFuc, false);
			}
			else
			{
				if($(_sId).act){$(_sId).detachEvent('onclick', $(_sId).act);}
				$(_sId).act = _sFuc;
				$(_sId).attachEvent('onclick', _sFuc);
			}
		}
	}
	
	//对话框居中
	this.middle = function(_sId)
	{
		var sClientWidth = window.document.body.clientWidth;
		var sClientHeight = window.document.body.clientHeight;
		var sScrollTop = window.document.documentElement.scrollTop;
		
		var obj = $(_sId);
		var left = (sClientWidth / 2) - (obj.offsetWidth / 2) - (shadowPx / 2) + "px";
		var top = sScrollTop + 180 + "px";//注意

		obj['style']['display'] = '';
		obj['style']['position'] = "absolute";
		obj['style']['left'] = left;
		obj['style']['top'] = top;
	}
	
	//移动对话框
	this.moveStart = function (event, _sId)
	{
		var oObj = $(_sId);
		oObj.onmousemove = mousemove;
		oObj.onmouseup = mouseup;
		oObj.setCapture ? oObj.setCapture() : function(){};
		oEvent = window.event ? window.event : event;
		var dragData = {x : oEvent.clientX, y : oEvent.clientY};
		var backData = {x : parseInt(oObj.style.top), y : parseInt(oObj.style.left)};
		function mousemove()
		{
			var oEvent = window.event ? window.event : event;
			var iLeft = oEvent.clientX - dragData["x"] + parseInt(oObj.style.left);
			var iTop = oEvent.clientY - dragData["y"] + parseInt(oObj.style.top);
			oObj.style.left = iLeft + "px";
			oObj.style.top = iTop + "px";
			$('dialogBoxShadow').style.left = iLeft + shadowPx + "px";
			$('dialogBoxShadow').style.top = iTop + shadowPx + "px";
			dragData = {x: oEvent.clientX, y: oEvent.clientY};
			
		}
		function mouseup()
		{
			var oEvent = window.event ? window.event : event;
			oObj.onmousemove = null;
			oObj.onmouseup = null;
			if(oEvent.clientX < 1 || oEvent.clientY < 1 || oEvent.clientX > window.document.body.clientWidth || oEvent.clientY > window.document.body.clientHeight)
			{
				oObj.style.left = backData.y + "px";
				oObj.style.top = backData.x + "px";
				$('dialogBoxShadow').style.left = backData.y + shadowPx + "px";
				$('dialogBoxShadow').style.top = backData.x + shadowPx + "px";
			}
			oObj.releaseCapture ? oObj.releaseCapture() : function(){};
		}
	}
}

function MyExtMsg(alertTitle, alertMsg, okFunc)
{
	var dg = new dialog(alertTitle ? alertTitle : "");
	
	dg.showBox(alertMsg, 100, okFunc ? okFunc : function(){});
	return false;
}

function MyExtAlert(alertTitle, alertMsg, okFunc)
{
	var dg = new dialog(alertTitle ? alertTitle : "");
	
	dg.showBox(alertMsg, 102, okFunc ? okFunc : function(){});
	return false;
}

function MyExtConfirm(cfmTitle, cfmMsg, cfmCallback)
{
	var dg = new dialog(cfmTitle ? cfmTitle : "");
	
	dg.showBox(cfmMsg, 101, function(){cfmCallback('yes');}, function(){cfmCallback('no');});
	return false;
}


function MyExtShow(cfmTitle, cfmMsg)
{
	var dg = new dialog(cfmTitle ? cfmTitle : "");
	
	dg.showBox(cfmMsg, 100);

	return false;
}

function MyExtHide()
{
    new dialog().close();

	return false;
}
