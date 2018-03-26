package com.linkage.zzk.h5.controller;

import com.linkage.zzk.base.util.Result;
import com.linkage.zzk.h5.common.conf.AppConfig;
import com.linkage.zzk.h5.domain.User;
import com.linkage.zzk.h5.service.ZzkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 转转卡
 *
 * @author: John
 */
@Controller
@RequestMapping("/zzk")
public class ZzkController {

    @Autowired
    private ZzkService zzkService;

    /**
     * 首页，转转卡客户端嵌入地址
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/index")
    public String index(HttpServletRequest request, HttpServletResponse response, Model model) {

        //处理用户信息
        zzkService.setLoginUser(request, response);

        User loginUser = (User)request.getAttribute("loginUser");
        if (loginUser == null) {
            return "zzk/download";
        }
        zzkService.queryUserOrders(request, 1, "1", model);

        //设置微信分享需要的参数
        zzkService.setShareParams(AppConfig.DOMAIN_URL2 + "/zzk/index", model);

        return "zzk/index";
    }

    /**
     * 选择套餐页面，尊享卡、优享卡
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/packages")
    public String packages(HttpServletRequest request, Model model) {
        return "/zzk/packages";
    }

    /**
     * 选择办理类型页面，购卡、兑换券
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/function-selection")
    public String functionSelection(HttpServletRequest request, Model model) {
        model.addAttribute("sp", request.getParameter("sp"));
        return "/zzk/function-selection";
    }

    /**
     * 身份确认页面，录入用户信息
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/auth")
    public String auth(HttpServletRequest request, Model model) {
        model.addAttribute("sp", request.getParameter("sp"));
        return "/zzk/auth";
    }

    /**
     * 身份确认页面-更新
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/auth-update")
    public String authUpdate(HttpServletRequest request, Model model) {
        zzkService.setAuthUpdate(request, model);
        return "/zzk/auth-update";
    }

    /**
     * 身份确认页面-保存更新照片
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/saveAuthUpdate")
    public @ResponseBody Result saveAuthUpdate(HttpServletRequest request, Model model) {
        return zzkService.saveAuthUpdate(request, model);
    }

    /**
     * 加入购物车页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/buy-card")
    public String buyCard(HttpServletRequest request, Model model) {
        User loginUser = (User)request.getAttribute("loginUser");
        model.addAttribute("sp", request.getParameter("sp"));
        model.addAttribute("phone", request.getParameter("phone"));
        model.addAttribute("name", request.getParameter("name"));
        model.addAttribute("idCard", request.getParameter("idcard"));
        model.addAttribute("avatarPath", request.getParameter("avatarPath"));
        return "/zzk/buy-card";
    }

    /**
     * 提交加入购物车-卡
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/addBuyCard")
    public @ResponseBody Result addBuyCard(HttpServletRequest request) {
        return zzkService.addBuyCard(request);
    }

    /**
     * 查询兑换券是否可用
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/chargeQuery")
    public @ResponseBody Result chargeQuery(HttpServletRequest request) {
        return zzkService.chargeQuery(request);
    }

    /**
     * 购买兑换券页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/buy-voucher")
    public String buyVoucher(HttpServletRequest request, Model model) {
        model.addAttribute("sp", request.getParameter("sp"));
        return "/zzk/buy-voucher";
    }

    /**
     * 提交加入购物车-兑换券
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/addBuyVoucher")
    public @ResponseBody Result addBuyVoucher(HttpServletRequest request, Model model) {
        return zzkService.addBuyVoucher(request);
    }

    /**
     * 购物车列表页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/cart")
    public String cart(HttpServletRequest request, HttpServletResponse response, Model model) {
        response.addHeader("Cache-Control", "no-cache");
        zzkService.queryUserOrders(request, 0, "0", model);
        return "/zzk/cart";
    }

    /**
     * 购物车列表删除
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/deleteCart")
    public @ResponseBody Result deleteCart(HttpServletRequest request, Model model) {
        return zzkService.deleteCart(request, model);
    }

    /**
     * 订够页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/order")
    public String order(HttpServletRequest request, Model model) {
        zzkService.setUserOrder(request, model);
        return "/zzk/order";
    }

    /**
     * 保存订单
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/saveOrder")
    public @ResponseBody Result saveOrder(HttpServletRequest request, Model model) {
        return zzkService.saveOrder(request, model);
    }

    /**
     * 支付方式选择页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/pay")
    public String pay(HttpServletRequest request, Model model) {
        User loginUser = (User)request.getAttribute("loginUser");
        model.addAttribute("payOrderNo", request.getParameter("payOrderNo"));
        model.addAttribute("payOrderMoney", request.getParameter("payOrderMoney"));
        model.addAttribute("payOrderSubject", request.getParameter("payOrderSubject"));
        model.addAttribute("openId", loginUser.getOpenId());
        return "/zzk/pay";
    }

    /**
     * 支付结果页
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/pay-result")
    public String payResult(HttpServletRequest request, Model model) {
        model.addAttribute("ret", request.getParameter("ret"));
        model.addAttribute("msg", request.getParameter("msg"));
        return "/zzk/pay-result";
    }

    /**
     * 支付宝收银台页面
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/alipay")
    public void alipay(HttpServletRequest request, HttpServletResponse response) {
        zzkService.alipay(request, response);
    }

    /**
     * 支付宝回调页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/alipay-return")
    public String alipayReturn(HttpServletRequest request, Model model) {
        zzkService.alipayReturn(request, model);
        return "/zzk/pay-result";
    }

    /**
     * 支付宝支付结果异步通知
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/alipay-notify", method = RequestMethod.POST)
    public @ResponseBody String alipayNotify(HttpServletRequest request, HttpServletResponse response) {
        return zzkService.alipayNotify(request, response);
    }

    /**
     * 微信支付收银台页面
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/tenpay")
    public String tenpay(HttpServletRequest request, HttpServletResponse response, Model model) {
        Result result = zzkService.tenpay(request, response, model);
        if (result.getRet() == 0) {
            return "/zzk/tenpay";
        } else {
            return "/zzk/pay-result";
        }
    }

    /**
     * 微信支付回调页面，用户主动触发查单操作
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/tenpay-return")
    public String tenpayReturn(HttpServletRequest request, Model model) {
        return "/zzk/pay-result";
    }

    /**
     * 微信支付结果异步通知
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/tenpay-notify", method = RequestMethod.POST)
    public @ResponseBody String tenpayNotify(HttpServletRequest request, @RequestBody String resultXml) {
        return zzkService.tenpayNotify(request, resultXml);
    }

    /**
     * 地址管理页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/addresses")
    public String addresses(HttpServletRequest request, Model model) {
        zzkService.setUserAddresses(request, model);
        return "/zzk/addresses";
    }

    /**
     * 地址管理，添加地址页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/address")
    public String address(HttpServletRequest request, Model model) {
        zzkService.setEditAddress(request, model);
        return "/zzk/address";
    }

    /**
     * 地址管理，提交删除地址
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/deleteAddress")
    public @ResponseBody Result deleteAddress(HttpServletRequest request, Model model) {
        return zzkService.deleteAddress(request);
    }

    /**
     * 地址管理，设置为默认
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/saveAddressDefault")
    public @ResponseBody Result saveAddressDefault(HttpServletRequest request, Model model) {
        return zzkService.saveAddressDefault(request);
    }

    /**
     * 地址管理，提交保存地址
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/saveAddress")
    public @ResponseBody Result saveAddress(HttpServletRequest request, Model model) {
        return zzkService.saveAddress(request, model);
    }

    /**
     * 我的订单列表页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/my-orders")
    public String myOrderList(HttpServletRequest request, Model model) {
        zzkService.queryUserOrders(request, 2, "1", model);
        return "/zzk/my-orders";
    }

    /**
     * 订单详情页面
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/order-detail")
    public String orderDetail(HttpServletRequest request, Model model) {
        zzkService.setOrderDetail(request, model);
        return "/zzk/order-detail";
    }

    /**
     * 取卡地址页面，静态
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/selfpick")
    public String selfPick(HttpServletRequest request, Model model) {
        return "/zzk/selfpick";
    }

    /**
     * 可去景点页面，静态
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/jingd")
    public String jingd(HttpServletRequest request, Model model) {
        return "/zzk/jingd";
    }

    /**
     * 介绍页面，静态
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/intro")
    public String intro(HttpServletRequest request, Model model) {
        return "/zzk/intro";
    }

//    /**
//     * 图片上传，裁剪旋转接口
//     *
//     * @return
//     */
//    @RequestMapping(value = "/uploadFile", method = RequestMethod.POST)
//    public @ResponseBody Result uploadFile(MultipartHttpServletRequest request) {
//        MultipartFile file = request.getFile("file");
//        String metaData = request.getParameter("metadata");
//        ImageSize imageSize = JsonUtil.fromJson(metaData, ImageSize.class);
//        return zzkService.uploadFile(file, imageSize);
//    }

    /**
     * 图片上传，裁剪旋转接口
     *
     * @return
     */
    @RequestMapping(value = "/uploadFile", method = RequestMethod.POST)
    public @ResponseBody Result uploadFile(HttpServletRequest request) {
        String metaData = request.getParameter("metadata");
        return zzkService.uploadFile(metaData);
    }

    /**
     * 获取购物车数量
     *
     * @return
     */
    @RequestMapping(value = "/getCartCount")
    public @ResponseBody Result getCartCount(HttpServletRequest request) {
        return zzkService.getCartCount(request);
    }

    /**
     * 删除未支付订单
     *
     * @param request
     * @param model
     * @return
     */
    @RequestMapping(value = "/deleteOrder")
    public @ResponseBody Result deleteOrder(HttpServletRequest request, Model model) {
        return zzkService.deleteOrder(request);
    }

}
