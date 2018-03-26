package com.linkage.zzk.h5.service;

import com.linkage.zzk.base.util.Result;
import com.linkage.zzk.h5.domain.ImageSize;
import com.linkage.zzk.h5.domain.User;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author: John
 */
public interface ZzkService {

    /**
     * 查询用户订单信息，并添加到Model中供页面展示
     *
     * @param request
     * @param source 请求来源，0：购物车 1：首页
     * @param paymentType 0:购物车（尚未提交） 1：我的订单（已提交）
     * @param model
     */
    void queryUserOrders(HttpServletRequest request, int source, String paymentType, Model model);

    /**
     * 购卡，保存用户信息
     *
     * @param request
     * @param model
     * @param avatarFile
     * @return
     */
    Result saveAuth(HttpServletRequest request, Model model, MultipartFile avatarFile);

//    /**
//     * 文件上传
//     *
//     * @param file
//     * @return
//     */
//    Result uploadFile(MultipartFile file, ImageSize imageSize);

    /**
     * 文件上传
     *
     * @param metaData
     * @return
     */
    Result uploadFile(String metaData);

    /**
     * 购卡，加入购物车
     *
     * @param request
     * @return
     */
    Result addBuyCard(HttpServletRequest request);

    /**
     * 订单页，初始化用户收货地址
     *
     * @param request
     * @param model
     */
    void setUserAddresses(HttpServletRequest request, Model model);

    /**
     * 设置用户订单信息
     *
     * @param request
     * @param model
     */
    void setUserOrder(HttpServletRequest request, Model model);

    /**
     * 保存新增或修改地址
     *
     * @param request
     * @param model
     * @return
     */
    Result saveAddress(HttpServletRequest request, Model model);

    /**
     * 删除地址
     *
     * @param request
     * @return
     */
    Result deleteAddress(HttpServletRequest request);

    /**
     * 购买兑换券，加入购物车
     *
     * @param request
     * @return
     */
    Result addBuyVoucher(HttpServletRequest request);

    /**
     * 订单详情页，设置订单信息，供页面展示
     *
     * @param request
     * @param model
     */
    void setOrderDetail(HttpServletRequest request, Model model);

    /**
     * 支付宝统一下单
     *
     * @param request
     * @param response
     */
    void alipay(HttpServletRequest request, HttpServletResponse response);

    /**
     * 微信统一下单
     *
     * @param request
     * @param response
     */
    Result tenpay(HttpServletRequest request, HttpServletResponse response, Model model);

    /**
     * 兑换码是否可用查询
     *
     * @param request
     * @return
     */
    Result chargeQuery(HttpServletRequest request);

    /**
     * 编辑地址
     *
     * @param request
     * @param model
     */
    void setEditAddress(HttpServletRequest request, Model model);

    /**
     * 提交订单
     *
     * @param request
     * @param model
     * @return
     */
    Result saveOrder(HttpServletRequest request, Model model);

    /**
     * 支付宝回调
     *
     * @param request
     * @param model
     */
    void alipayReturn(HttpServletRequest request, Model model);

    /**
     * 微信异步通知
     *
     * @param request
     * @param resultXml
     * @return
     */
    String tenpayNotify(HttpServletRequest request, String resultXml);

    /**
     * 支付宝异步通知
     *
     * @param request
     * @param response
     * @return
     */
    String alipayNotify(HttpServletRequest request, HttpServletResponse response);

    /**
     * 删除购物车
     *
     * @param request
     * @param model
     * @return
     */
    Result deleteCart(HttpServletRequest request, Model model);

    /**
     * 设置为默认地址
     *
     * @param request
     * @return
     */
    Result saveAddressDefault(HttpServletRequest request);

    /**
     * 首页进入处理当前登录用户
     *
     * @param request
     * @param response
     */
    void setLoginUser(HttpServletRequest request, HttpServletResponse response);

    /**
     * 购物车数量查询
     *
     * @param request
     * @return
     */
    Result getCartCount(HttpServletRequest request);

    /**
     * 更新照片
     *
     * @param request
     * @param model
     */
    void setAuthUpdate(HttpServletRequest request, Model model);

    /**
     * 保存更新照片
     *
     * @param request
     * @param model
     * @return
     */
    Result saveAuthUpdate(HttpServletRequest request, Model model);

    /**
     * 删除订单
     *
     * @param request
     * @return
     */
    Result deleteOrder(HttpServletRequest request);

    /**
     * 登陆
     *
     * @param request
     * @return
     */
    Result doLogin(HttpServletRequest request, HttpServletResponse response);

    /**
     * 注册
     *
     * @param request
     * @param response
     * @return
     */
    Result doReg(HttpServletRequest request, HttpServletResponse response);

    /**
     * 重置密码
     *
     * @param request
     * @param response
     * @return
     */
    Result resetPassword(HttpServletRequest request, HttpServletResponse response);

    /**
     * 下发验证码
     *
     * @param request
     * @param response
     * @return
     */
    Result sendCode(HttpServletRequest request, HttpServletResponse response);

    /**
     * 设置微信分享需要的参数
     *
     * @param url
     * @param model
     */
    void setShareParams(String url, Model model);
}
