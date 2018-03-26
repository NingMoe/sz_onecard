jQuery(function($){
  
    //fashclick
    FastClick.attach(document.body);
  
    //ajax demo
    $('.a-form').on('submit', function(event){
        var  $this = $(this);
        event.preventDefault();

        if($this.data('ajax')){ return  false }

        //打开一个加载器
        APP.showLoading();

        $this.data('ajax', true);
        $.ajax({
            url: '../data/response.json',
            dataType: 'json',
            data: $this.serialize()
        }).done(function(data){
            //关闭加载器
            APP.closeLoading();
        }).always(function(){
            $this.data('ajax', null);
        });
    });
  
  
  
});
  
var APP = APP || {};

APP.phoneReg = /^1\d{10}$/;

APP.idReg =  /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/;

APP.weixinReg = /MicroMessenger/i;

APP.showLoading =  function(){
    mobile.modal.modern({
        content: '<div class="loading"><\/div>'
    })
}

APP.closeLoading = function(){
    mobile.modal.close()
}

/**
 * 提示信息
 * @param msg 信息内容
 * @param classname 可选背景色 [danger(红色), success（绿色), warn(黑色)]
 */
APP.flashMessage =  function(msg, classname){
    return new Message({
        message: msg,
        delay: 1500,
        wrapClass: classname ?  classname:  'default'
    })
}

function Message(options){
    var defaults = $.extend({
            width : 200,
            ease : 500,
            // delay : 500,
            wrapClass : "warn"
        }, options),
        self = this;

    this.defaults = defaults;

    this.message = $('<div  class="message message-'+ defaults.wrapClass +'"><div class="message-main">' + defaults.message + '</div></div>');

    $('body').append(this.message);

    //自动关闭窗口
    if(defaults.delay){
        defaults.timer = setTimeout(function(){
            self.close();
        }, defaults.delay);
    }
}

Message.prototype.close = function(){
    var self = this;
    self.message.animate({
        opacity : 0
    }, self.defaults.ease, function(){
        self.message.remove();
    });
};
  
var mobile =  function(){
    //弹出层
    var  modal = {
        mask : function(){
            return $("<div class=\"modal-mask\" \/>");
        }(),
        modal : function(){
            return $("<div class=\"modal-main\" \/>");
        }(),
        eventName : function(){
            //是否是手机浏览器返回对应的事件
            //click事件在手机上点击有阴影
            return navigator.userAgent.indexOf("Mobile") > - 1 ? "touchstart" : "click";
        }(),
        timer : null,
        alert : function(options){
            var  self = this, fw;
            options = $.extend({title: "", button: "确定"}, options);
            self.close();

            fw = self.fixWidth(options.width);

            self.modal.css({
                "width" : fw.width,
                "margin-left": fw.marginLeft
            }).append("<div class=\"modal-header\">" + options.title + "<\/div><div class=\"modal-content\">" + options.content + "<\/div><div class=\"modal-action\">" + options.button + "<\/div>");

            $('body').append(self.mask, self.modal);

            //bind event
            $(".modal-action").one(self.eventName, function(e){
                e.preventDefault();
                self.close();
                if(typeof options.callback === "function"){
                    options.callback.apply(null, options.args);
                }
            });
        },
        confirm : function(options){
            var  self = this, fw;
            options = $.extend({title: "", cancel: "返回", ok: "确定", args: []}, options);
            self.close();

            fw = self.fixWidth(options.width);

            self.modal.css({
                "width" : fw.width,
                "margin-left": fw.marginLeft
            }).addClass(options.wrapClass).append("<div class=\"modal-header\">" + options.title + "<\/div><div class=\"modal-content\">" + options.content + "<\/div><div class=\"modal-action modal-confirm-action\"><span class=\"modal-action-cancel\">" + options.cancel + "<\/span><span class=\"modal-action-ok\">" + options.ok + "<\/span><\/div>");

            $('body').append(self.mask, self.modal);

            //bind event
            $(".modal-action-cancel").one(self.eventName, function(e){
                e.preventDefault();
                self.close();
                if(typeof options.cancelCb === "function"){
                    options.cancelCb.apply(null, options.args);
                }
            });
            //bind event
            $(".modal-action-ok").one(this.eventName, function(e){
                e.preventDefault();
                self.close();
                if(typeof options.callback === "function"){
                    options.callback.apply(null, options.args);
                }
            });
        },
        modern : function(options){
            this.close();
            this.modal.css({
                "width" : "80px",
                "margin-left": "-40px",
            }).append("<div class=\"modal-modern modal-modern-" + options.type + "\">" + options.content + "<\/div>");

            $('body').append(this.mask, this.modal);

        },
        close : function(){
            var self = this;
            //console.log(this.timer);
            self.modal.empty().remove();
            self.mask.empty().remove();
        },
        //定位modal-main的位置
        fixWidth: function(w){
            var fw = {"width": "90%" , "marginLeft": "-45%"};

            if(typeof w === "number"){
                fw.width = w + "px";
                fw.marginLeft = "-" + Math.ceil(w / 2) + "px";
            }

            return fw;
        }
    };


    return {
        modal : modal
    };

}();
  
/**
 * 带关闭按钮的输入框
 * $('.control-group').smartInput();
 */
(function($){
    $.fn.smartInput = function(options){
        var config = $.extend({
            inputSelector: 'input',
            clearSelector: '.control-clear'
        }, options);

        return this.each(function(){
            var $input = $(this).find(config.inputSelector),
                $clear = $(this).find(config.clearSelector),
                timer_;

            $input.on('focus keyup', function(){
                clearTimeout(timer_);
                if(this.value === ''){
                    $clear.hide();
                }else{
                    $clear.show();
                }
            }).on('blur', function(){
                timer_ = setTimeout(function(){
                    $clear.hide()
                }, 50);
            });

            $clear.on('click', function(){
                clearTimeout(timer_);
                $input.val('');
                $(this).hide();
            });
        });
    }
  })(jQuery);

/**
 * 倒计时插件
 * $('.counter').counter();
 */
(function($){
  $.fn.counter = function(options){
      var config = $.extend({
          hourSelector: '.hours',
          minuteSelector: '.minutes',
          secondSelector: '.seconds'
      }, options);

      return this.each(function(){
        update(parseInt($(this).data('seconds')), $(this).find(config.hourSelector), $(this).find(config.minuteSelector), $(this).find(config.secondSelector));
      });

      function update(timestamp, $hour, $minute, $second){
        var next = timestamp;
        $hour.html(Math.floor(timestamp / 3600));
        timestamp = timestamp % 3600;
        $minute.html(Math.floor(timestamp / 60));
        timestamp = timestamp % 60;
        $second.html(timestamp);
        if(next > 0){
          setTimeout(function(){
            update(next-1, $hour, $minute, $second)
          }, 1000);
        }
      }
  }
})(jQuery);
  

/**
 * 选择套餐插件
 * $('.select-box').selectBox();
 */
(function($){
    $.fn.selectBox = function(options){
        var config = $.extend({
            maskSelector: '.select-mask',
            closeCb: null
        }, options);

        return this.each(function(){
            var $target = $($(this).data('target')),
                $val = $(this).find('.select-box-val'),
                $mask = $(config.maskSelector),
                $close = $target.find('.select-main-close');

            /*显示*/
            $(this).on('click', function(){
                $target.addClass('active');
                $mask.show();
            });

            $close.on('click', function(){
                $target.removeClass('active');
                $mask.hide();
                config.closeCb && config.closeCb($val);
            });
            $mask.on('click', function(){
                $close.trigger('click');
            });
        });
    }
})(jQuery);



;(function($){
	
	/*
	 * param:
	 * jo : jquery对象
	 * message : 提示信息
	 * jot : jquery对象, 相对定位的元素
	 */
	function numberErr(jo, msg){
		//存储原颜色值
		jo.stop(true, true).html(msg).show(50).delay(1000).hide(50);
	}
	
	
	$.fn.jnumber = function(options){
		//var defaults = $.extend({}, options);
 		
		return this.each(function(){
			var _ = $(this),
				_plus,
				_reduce,
				_info,
				_max = _.data('maxnum'),
				_min = _.data('minum'),
				_step = _.data('stepnum') || 1,
				_num  = _.val() ? _.val() : _min;
			//确保input的值是min-max之间的有效值
			if(isNaN(_num)){
					_num = _min;
					_.val(_num);
			}
			_num = Math.min(_max, _num);
				
				
			_.before('<span class="jnumber-reduce">-</span>');
			_.after('<span class="jnumber-info" style="display:none;"></span>');
			_.after('<span class="jnumber-plus">+</span>');
			_plus = _.siblings('.jnumber-plus');
			_reduce = _.siblings('.jnumber-reduce');
            _info = _.siblings('.jnumber-info');
            
            
            _num == _min && _reduce.addClass('disabled');
            _num == _max && _plus.addClass('disabled');
			
			_plus.on('click', function(){
                var _temp = _num + _step;
                if($(this).hasClass('disabled')){return false;}
				if( _temp > _max ){ 
					_plus.addClass('disabled'); 
					numberErr(_info, "超出最大值!", _);return false;
				}
				_num = _temp;
				_.val(_num);
				
				if(_temp == _max){ 
					_plus.addClass('disabled'); 
				}
				
				_reduce.removeClass('disabled');
			});
			
			_reduce.on('click', function(){
                var _temp = _num - _step;
                if($(this).hasClass('disabled')){return false;}
				if( _temp < _min ){ 
					_reduce.addClass('disabled'); 
					numberErr(_info, "超出最小值!", _);return false;
				}
				_num = _temp;
				_.val(_num);
				
				if(_temp == _min ){ 
					_reduce.addClass('disabled'); 
				}
							
				_plus.removeClass('disabled');
			});
			
			_.on("keyup", function(){
				var _temp = _.val();
				if(isNaN(_temp)){
					_temp = _min;
					_.val(_temp);
				}
				
				if(_temp > _max){
                    _.val(_max);
                    _plus.addClass('disabled'); 
                    _reduce.removeClass('disabled'); 
					numberErr(_info, "超出最大值!", _); 
				}
				if(_temp < _min){
                    _.val(_min);
                    _plus.removeClass('disabled'); 
                    _reduce.addClass('disabled'); 
					numberErr(_info, "超出最小值!", _); 
				}
                _num = parseInt(_.val());

			});
			
		});
	};
})(jQuery);

/**
 * 弹出框的构造函数
 * var  p1 = new Popup($('.popup'), {
 *  showBefore|closeAfter: function(pop, p)
 * })
 * @param {*} jo 
 * @param {*} options 
 */
function Popup(jo, options){
    this.cfg = $.extend({
        maskSelector: '.popup-mask',
        maskClose: false,
        showBefore: null,
        closeAfter: null
    }, options);

    this.$popup = jo;
    this.$mask = $(this.cfg.maskSelector);

    if(this.cfg.maskClose){
        this.$mask.on('click', $.proxy(this.hide, this));
    }

    jo.find('.popup-cancel').on('click', $.proxy(this.hide, this));
}
 
Popup.prototype.show = function(){
    this.cfg.showBefore && this.cfg.showBefore(this.$popup, this);
    this.$popup.addClass('active');
    this.$mask.show();
}

Popup.prototype.hide = function(){
    this.$popup.removeClass('active');
    this.$mask.hide();
    this.cfg.closeAfter && this.cfg.closeAfter(this.$popup, this);
}

Popup.prototype.updateContent = function(html){
    this.$popup.find('.popup-content').html(html);
    return this;
}

/**
 * 购物车
 * vouchers.store = {packageId： {num: 1, active: true}}
 */
var vouchers = { 
    store: { } 
};

//初始化
vouchers.init = function(){
    var voucherStore = localStorage.getItem('vouchers');
    if(voucherStore){
        vouchers.store = JSON.parse(voucherStore)
    }
}

vouchers.deactive = function(){
    //获取购物车里面商品的ID
    for(var prop in this.store){
        if(!this.store.hasOwnProperty(prop)){continue}
        this.store[prop].active = false;
    }
}

vouchers.update = function(){
    localStorage.setItem('vouchers', JSON.stringify(vouchers.store));
}

vouchers.add = function(cardId, cardNum, extra){
    this.deactive();
    extra = extra || {};
    this.store[cardId] = $.extend(extra, {
        num : cardNum,
        active: true
    });
    this.update();
}

vouchers.remove = function(cardId){
    delete this.store[cardId]; 
    this.update();
}


vouchers.storeSorted = function(){
    var result = [];
    //获取购物车里面商品的ID
    for(var prop in this.store){
        if(!this.store.hasOwnProperty(prop)){continue}
        if(this.store[prop].active){
            result.unshift(prop)
        }else{
            result.push(prop)
        }
    }
    return result;
}