package com.linkage.zzk.h5.service.impl;

import com.alipay.api.AlipayConstants;
import com.alipay.api.internal.util.AlipaySignature;
import com.linkage.zzk.base.pay.weixin.WxSignUtil;
import com.linkage.zzk.base.pay.weixin.WxXmlUtil;
import com.linkage.zzk.base.session.CookieSession;
import com.linkage.zzk.base.util.*;
import com.linkage.zzk.h5.common.conf.AppConfig;
import com.linkage.zzk.h5.common.service.InterfaceService;
import com.linkage.zzk.h5.common.utils.OrderNoUtil;
import com.linkage.zzk.h5.common.weixin.Utils;
import com.linkage.zzk.h5.domain.*;
import com.linkage.zzk.h5.service.ZzkService;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.collections4.map.HashedMap;
import org.apache.commons.io.FileUtils;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 转转卡服务实现
 *
 * @author: John
 */
@Service
public class ZzkServiceImpl implements ZzkService {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    private InterfaceService interfaceService;

    /**
     * 首次进入，登录用户信息处理
     *
     * @param request
     * @param response
     */
    @Override
    public void setLoginUser(HttpServletRequest request, HttpServletResponse response) {
        String userId = request.getParameter("userId");
        if (StringUtil.isNotBlank(userId)) { //首次进入
            userId = new Des3(AppConfig.USER_SECRET).decode(userId);
            if (userId != null) {
                request.setAttribute("loginUser", new User(userId));
                CookieSession cookieSession = new CookieSession(request, AppConfig.SESSION_KEY);
                cookieSession.put("userId", userId);
                cookieSession.flush(response);
            }
        }
    }

    /**
     * 查询用户订单信息，并添加到Model中供页面展示
     *
     * @param request
     * @param source 请求来源，0：购物车 1：首页  2：我的订单列表
     * @param paymentType 0:购物车（尚未提交） 1：我的订单（已提交）
     * @param model
     */
    @Override
    public void queryUserOrders(HttpServletRequest request, int source, String paymentType, Model model) {
        User loginUser = (User)request.getAttribute("loginUser");
        try {
            //查询用户订单列表
            Map<String, Object> params = new HashedMap<>();
            params.put("userId", loginUser.getUserId());
            params.put("paymentType", paymentType);
            params.put("detailNo", "");
            params.put("orderNo", "");
            InterfaceOrderQueryResult interfaceOrderQueryResult = interfaceService.orderQuery(params);

            if (interfaceOrderQueryResult != null && "0000".equals(interfaceOrderQueryResult.getRespCode())) {
                List<InterfaceOrderQueryDetail> orderList = interfaceOrderQueryResult.getOrderList();
                if (orderList != null && !orderList.isEmpty()) {

                    //购物车数据
                    List<InterfaceOrderCardDetail> cartOrderCardDetailList = new ArrayList<>();
                    List<InterfaceOrderChargeDetail> cartOrderChargeDetailList = new ArrayList<>();

                    //首页已支付订单数据
                    List<InterfaceOrderCardDetail> indexOrderCardDetailList = new ArrayList<>();

                    for (InterfaceOrderQueryDetail order : orderList) {

                        //卡订单列表
                        List<InterfaceOrderCardDetail> orderCardDetailList = order.getOrderCardList();
                        if (orderCardDetailList != null && !orderCardDetailList.isEmpty()) {

                            for (InterfaceOrderCardDetail orderCardDetail : orderCardDetailList) {
                                //金额转换
                                orderCardDetail.setPackageMoney(
                                        StringUtil.isNotBlank(orderCardDetail.getPackageMoney()) ?
                                                ((Integer.parseInt(orderCardDetail.getPackageMoney()) / 100) + "") : "0");
                                orderCardDetail.setSupplyMoney(
                                        StringUtil.isNotBlank(orderCardDetail.getSupplyMoney()) ?
                                                ((Integer.parseInt(orderCardDetail.getSupplyMoney()) / 100) + "") : "0");

                                //激活有效期处理
                                String activeEndDate = orderCardDetail.getActiveEndTime();
                                if (StringUtil.isNotBlank(activeEndDate)) {
                                    Date activeEndTime = DateUtil.parse(activeEndDate, "yyyyMMddHHmmss");
                                    long currentTime = System.currentTimeMillis();
                                    if (activeEndTime == null || activeEndTime.getTime() <= currentTime) {
                                        orderCardDetail.setActiveEndTime("0");
                                    } else {
                                        orderCardDetail.setActiveEndTime(((activeEndTime.getTime() - currentTime) / 1000) + "");
                                    }
                                }

                                //处理兑换券金额
                                if ("01".equals(orderCardDetail.getDiscountType()) && StringUtil.isNotBlank(orderCardDetail.getChargeNoPrice())) {
                                    orderCardDetail.setChargeNoPrice((Integer.parseInt(orderCardDetail.getChargeNoPrice()) / 100) + "");
                                }

                                //购物车
                                if (source == 0) {
                                    cartOrderCardDetailList.add(orderCardDetail);
                                }

                                //首页订单
                                if (source == 1 && "1".equals(order.getPaymentState()) &&
                                        !(StringUtil.isNotBlank(orderCardDetail.getActiveEndTime()) && "0".equals(orderCardDetail.getActiveEndTime()))) {
                                    orderCardDetail.setOrderNo(order.getOrderNo());
                                    indexOrderCardDetailList.add(orderCardDetail);
                                }
                            }

                            //我的订单列表
                            if (source == 2) {
                                order.setOrderTitle("Z2".equals(orderCardDetailList.get(0).getPackageName()) ? "转转卡尊享卡套餐" : "转转卡优享卡套餐");
                            }
                        }

                        //兑换券订单详情列表
                        List<InterfaceOrderChargeDetail> orderChargeDetailList = order.getOrderChargeList();
                        if (orderChargeDetailList != null && !orderChargeDetailList.isEmpty()) {
                            for (InterfaceOrderChargeDetail orderChargeDetail : orderChargeDetailList) {
                                //处理金额，转换为元
                                orderChargeDetail.setFuncFee(
                                        StringUtil.isNotBlank(orderChargeDetail.getFuncFee()) ?
                                                ((Integer.parseInt(orderChargeDetail.getFuncFee()) / 100) + "") : "0"
                                );
                                if (source == 0) {
                                    cartOrderChargeDetailList.add(orderChargeDetail);
                                }
                            }

                            //订单标题
                            if (source == 2) {
                                order.setOrderTitle("Z2".equals(orderChargeDetailList.get(0).getPackageName()) ? "转转卡尊享卡套餐兑换券" : "转转卡优享卡套餐兑换券");
                            }
                        }

                        //订单标题
                        if (source == 2) {
                            if (StringUtil.isBlank(order.getOrderTitle())) {
                                order.setOrderTitle("转转卡套餐");
                            }
                        }
                        String orderMoney = order.getOrderMoney();
                        if (StringUtil.isNotBlank(orderMoney)) {
                            order.setOrderMoney((Integer.parseInt(orderMoney) / 100) + "");
                        }

                        if (StringUtil.isNotBlank(order.getCreateTime())) {
                            order.setCreateTime(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(
                                    new SimpleDateFormat("yyyyMMddHHmmss").parse(order.getCreateTime())));
                        }

                    }

                    if (source == 0) {
                        model.addAttribute("orderCardDetailList", cartOrderCardDetailList);
                        model.addAttribute("orderChargeDetailList", cartOrderChargeDetailList);
                    }
                    if (source == 1 && !indexOrderCardDetailList.isEmpty()) {
                        model.addAttribute("indexOrderCardDetailList", indexOrderCardDetailList);
                    }

                    model.addAttribute("orderList", orderList);
                }

            }
        } catch (Exception e) {
            logger.error("查询用户订单信息异常", e);
        }
    }

    /**
     * 暂存用户购卡信息，供提交订单时使用
     *
     * @param request
     * @param model
     * @param avatarFile
     * @return
     */
    @Override
    public Result saveAuth(HttpServletRequest request, Model model, MultipartFile avatarFile) {
        String phone = request.getParameter("phone");
        String name = request.getParameter("name");
        String idCard = request.getParameter("idcard");

        if (StringUtil.isBlank(phone)) {
            return new Result(1, "手机号码不能为空");
        }
        if (StringUtil.isBlank(name)) {
            return new Result(1, "姓名不能为空");
        }
        if (StringUtil.isBlank(idCard)) {
            return new Result(1, "身份证号码不能为空");
        }

        //处理头像文件，先暂存，与加入购物车接口一起提交
        String avatarFilePath = null;
        if (avatarFile != null) {
            avatarFilePath = new FileUtil(AppConfig.FILE_PATH, "avatarTempFiles").upload(avatarFile);
        }

        Map<String, String> authData = new HashedMap<>();
        authData.put("phone", phone);
        authData.put("name", name);
        authData.put("idCard", idCard);
        authData.put("avatarFilePath", avatarFilePath);

        return new Result(0, "成功", authData);
    }

//    /**
//     * 文件上传
//     *
//     * @param file
//     * @return
//     */
//    @Override
//    public Result uploadFile(MultipartFile file, ImageSize imageSize) {
//
//        logger.info(JsonUtil.toJson(imageSize));
//
//        String dbFilePath = new FileUtil(AppConfig.FILE_PATH, "fileUpload").upload(file);
//        if (dbFilePath != null) {
//            //图片裁剪、旋转处理
//            String src = AppConfig.FILE_PATH + dbFilePath;
//            String dest = src + "-thumbnail";
//            boolean success = ImageUtil.size(src, dest,
//                    imageSize.getX(), imageSize.getY(),
//                    imageSize.getScaleX(), imageSize.getScaleY(),
//                    imageSize.getWidth(), imageSize.getHeight(),
//                    imageSize.getRotate(),
//                    "jpg");
//            if (success) {
//                Map<String, String> data = new HashedMap<>();
//                data.put("fullFilePath", dest + ".jpg");
//                data.put("filePath", dbFilePath + "-thumbnail" + ".jpg");
//                return new Result(0, "成功", data);
//            }
//        }
//        return new Result(1, "上传失败");
//    }

    /**
     * 照片上传
     *
     * @param metaData
     * @return
     */
    @Override
    public Result uploadFile(String metaData) {

        logger.info(JsonUtil.toJson(metaData));

        try {
            //存储源图片
            String sourcePath = "/fileUpload" + new SimpleDateFormat("/yyyy/MM/dd").format(new Date()) + "/" + UUID.randomUUID().toString();
            String fullSourcePath = AppConfig.FILE_PATH + sourcePath;
            byte[] bytes = Base64.decodeBase64(metaData.replace("data:image/png;base64,", ""));
            FileUtils.writeByteArrayToFile(new File(fullSourcePath), bytes);

            //计算压缩比(100KB)
//            double quality = (100 * 1024) / (bytes.length / 8);

            //压缩生成目标图片
            String targetPath = sourcePath + "-thumbnail";
            String fullTargetPath = AppConfig.FILE_PATH + targetPath;
            boolean success = ImageUtil.quality(fullSourcePath, fullTargetPath, "jpg", 300, 400, 0.7);

            //返回处理后的图片存储路径
            if (success) {
                Map<String, String> data = new HashedMap<>();
                data.put("fullFilePath", fullTargetPath + ".jpg");
                data.put("filePath", targetPath + ".jpg");
                return new Result(0, "成功", data);
            }

        } catch (Exception e) {
            logger.error("照片上传异常", e);
        }
        return new Result(1, "上传失败");
    }

    /**
     * 购卡，加入购物车
     *
     * @param request
     * @return
     */
    @Override
    public Result addBuyCard(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");
        String packageMoney = request.getParameter("packageMoney"); //套餐金额
        String packageType = request.getParameter("packageType"); //套餐类型，取值：Z1、Z2
        String name = request.getParameter("name"); //姓名
        String phone = request.getParameter("phone"); //电话
        String idCard = request.getParameter("idCard"); //身份证号码
        String avatarPath = request.getParameter("avatarPath"); //头像路径
        String vouchNo = request.getParameter("vouchNo"); //兑换码
        String prepay = request.getParameter("prepay"); //预充值金额
        String orderMoney = request.getParameter("total"); //订单总金额
        String discountType = "";

        //处理订单金额、套餐金额，单位分
        packageMoney = (Integer.parseInt(packageMoney) * 100) + "";
        orderMoney = (Integer.parseInt(orderMoney) * 100) + "";

        //处理兑换码
        if (StringUtil.isNotBlank(vouchNo)) {
            discountType = "01";
        } else {
            discountType = "00";
            vouchNo = "";
        }

        //处理预充值金额，单位分
        if (StringUtil.isNotBlank(prepay)) {
            prepay = (Integer.parseInt(prepay) * 100) + "";
        } else {
            prepay = "";
        }

        //处理上传的头像，照片(BASE64Encoder byte[]后的字符串)
        String photo = "";
        if (StringUtil.isNotBlank(avatarPath)) {
            File file = new File(AppConfig.FILE_PATH + avatarPath);
            if (file.exists()) {
                try {
                    byte[] fileByte = FileUtils.readFileToByteArray(file);
                    photo = Base64.encodeBase64String(fileByte);
                } catch (IOException e) {
                    logger.error("读取上传的照片异常", e);
                }
            }
        }

        Map<String, String> detailParams = new HashedMap<>();
        detailParams.put("orderType", "0");
        detailParams.put("address", "");
        detailParams.put("cardTypeCode", "");
        detailParams.put("cardno", "");
        detailParams.put("chargeNo", vouchNo);
        detailParams.put("custBirth", "");
        detailParams.put("custEmail", "");
        detailParams.put("custName", name);
        detailParams.put("custPhone", phone);
        detailParams.put("custPost", "");
        detailParams.put("custSex", "");
        detailParams.put("detailNo", OrderNoUtil.getCardOrderNo());
        detailParams.put("discountType", discountType);
        detailParams.put("packageMoney", packageMoney);
        detailParams.put("packageType", packageType);
        detailParams.put("paperNo", idCard);
        detailParams.put("paperType", "00");
        detailParams.put("photo", photo);
        detailParams.put("preSupplyMoney", prepay);
        detailParams.put("remark", "");

        List<Map<String, String>> detailReqList = new ArrayList<>();
        detailReqList.add(detailParams);

        Map<String, Object> params = new HashedMap<>();
        params.put("tradeType", "0");
        params.put("address", "");
        params.put("custName", "");
        params.put("custPhone", "");
        params.put("custPost", "");
        params.put("fetchType", "");
        params.put("orderId", "");
        params.put("orderMoney", orderMoney);
        params.put("payCanal", "");
        params.put("payTradeId", "");
        params.put("postAge", "");
        params.put("remark", "");
        params.put("userId", loginUser.getUserId());
        params.put("detailReqList", detailReqList);

        InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
        if (orderResult != null && "0000".equals(orderResult.getRespCode())) {
            return new Result(0, "成功加入购物车");
        }
        return new Result(1, "加入购物车失败");
    }

    /**
     * 查询设置用户地址列表
     *
     * @param request
     * @param model
     */
    @Override
    public void setUserAddresses(HttpServletRequest request, Model model) {

        User loginUser = (User)request.getAttribute("loginUser");

        Map<String, Object> params = new HashedMap<>();
        params.put("address", "");
        params.put("addressID", "");
        params.put("isDefault", "");
        params.put("location", "");
        params.put("name", "");
        params.put("phone", "");
        params.put("type", "03");
        params.put("userId", loginUser.getUserId());

        InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
        if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
            List<InterfaceAddressDetail> addressList = addressManageResult.getAddressList();
            if (addressList != null && !addressList.isEmpty()) {
                model.addAttribute("addressList", addressList);
            }
        }

    }

    /**
     * 购物车生成订单时，订单默认地址等相关信息处理
     *
     * @param request
     * @param model
     */
    @Override
    public void setUserOrder(HttpServletRequest request, Model model) {

        //处理订单的收货地址，顺序为：选中的地址，默认地址，没有默认地址取第一个
        User loginUser = (User)request.getAttribute("loginUser");
        List<InterfaceAddressDetail> addressList = null;
        Map<String, Object> params = new HashedMap<>();
        params.put("address", "");
        params.put("addressID", "");
        params.put("isDefault", "");
        params.put("location", "");
        params.put("name", "");
        params.put("phone", "");
        params.put("type", "03");
        params.put("userId", loginUser.getUserId());

        InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
        if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
             addressList = addressManageResult.getAddressList();
        }

        String addressId = request.getParameter("addressId");
        if (addressId != null) {
            if (addressList != null && !addressList.isEmpty()) {
                for (InterfaceAddressDetail addressDetail : addressList) {
                    if (addressId.equals(addressDetail.getAddressId())) {
                        model.addAttribute("selectedAddress", addressDetail);
                        break;
                    }
                }
            }
        } else {
            if (addressList != null && !addressList.isEmpty()) {
                for (InterfaceAddressDetail addressDetail : addressList) {
                    if ("1".equals(addressDetail.getIsDefault())) {
                        model.addAttribute("selectedAddress", addressDetail);
                        break;
                    }
                }
                if (!model.containsAttribute("selectedAddress")) {
                    model.addAttribute("selectedAddress", addressList.get(0));
                }
            }
        }
    }

    /**
     * 购买兑换券，加入购物车
     *
     * @param request
     * @return
     */
    @Override
    public Result addBuyVoucher(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");
        String packageMoney = request.getParameter("packageMoney"); //套餐金额
        String packageType = request.getParameter("packageType"); //套餐类型，取值：Z1、Z2
        String packageNum = request.getParameter("packageNum"); //兑换券数量

        //处理订单金额和套餐金额，单位分
        int orderMoney = Integer.parseInt(packageMoney) * Integer.parseInt(packageNum) * 100;
        packageMoney = (Integer.parseInt(packageMoney) * 100) + "";

        List<Map<String, String>> detailReqList = new ArrayList<>();
        for (int i = 0; i < Integer.parseInt(packageNum); i++) {
            Map<String, String> detailParams = new HashedMap<>();
            detailParams.put("address", "");
            detailParams.put("cardTypeCode", "");
            detailParams.put("cardno", "");
            detailParams.put("chargeNo", "");
            detailParams.put("custBirth", "");
            detailParams.put("custEmail", "");
            detailParams.put("custName", "");
            detailParams.put("custPhone", "");
            detailParams.put("custPost", "");
            detailParams.put("custSex", "");
            detailParams.put("orderType", "1");
            detailParams.put("detailNo", OrderNoUtil.getDHJOrderNo());
            detailParams.put("discountType", "");
            detailParams.put("packageMoney", packageMoney);
            detailParams.put("packageType", packageType);
            detailParams.put("paperNo", "");
            detailParams.put("paperType", "");
            detailParams.put("photo", ""); //照片(BASE64Encoder byte[]后的字符串)
            detailParams.put("preSupplyMoney", "");
            detailParams.put("remark", "");
            detailReqList.add(detailParams);
        }

        Map<String, Object> params = new HashedMap<>();
        params.put("address", "");
        params.put("custName", "");
        params.put("custPhone", "");
        params.put("custPost", "");
        params.put("fetchType", "");
        params.put("orderId", "");
        params.put("orderMoney", orderMoney + "");
        params.put("payCanal", "");
        params.put("payTradeId", "");
        params.put("postAge", "");
        params.put("remark", "");
        params.put("tradeType", "0");
        params.put("userId", loginUser.getUserId());
        params.put("detailReqList", detailReqList);

        InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
        if (orderResult != null && "0000".equals(orderResult.getRespCode())) {
            return new Result(0, "成功加入购物车");
        }
        return new Result(1, "失败");
    }

    /**
     * 删除购物车
     *
     * @param request
     * @param model
     * @return
     */
    @Override
    public Result deleteCart(HttpServletRequest request, Model model) {

        User loginUser = (User)request.getAttribute("loginUser");

        String detailIds = request.getParameter("detailIds");
        String orderTypes = request.getParameter("orderTypes");
        String[] detailNoArr = detailIds.split(",");
        String[] orderTypesArr = orderTypes.split(",");
        List<Map<String, String>> detailReqList = new ArrayList<>();
        for (int i = 0; i < detailNoArr.length; i++) {
            Map<String, String> detailParams = new HashedMap<>();
            detailParams.put("orderType", orderTypesArr[i]);
            detailParams.put("address", "");
            detailParams.put("cardTypeCode", "");
            detailParams.put("cardno", "");
            detailParams.put("chargeNo", "");
            detailParams.put("custBirth", "");
            detailParams.put("custEmail", "");
            detailParams.put("custName", "");
            detailParams.put("custPhone", "");
            detailParams.put("custPost", "");
            detailParams.put("custSex", "");
            detailParams.put("detailNo", detailNoArr[i]);
            detailParams.put("discountType", "");
            detailParams.put("packageMoney", "");
            detailParams.put("packageType", "");
            detailParams.put("paperNo", "");
            detailParams.put("paperType", "");
            detailParams.put("photo", "");
            detailParams.put("preSupplyMoney", "");
            detailParams.put("remark", "");
            detailReqList.add(detailParams);
        }

        Map<String, Object> params = new HashedMap<>();
        params.put("tradeType", "3");
        params.put("address", "");
        params.put("custName", "");
        params.put("custPhone", "");
        params.put("custPost", "");
        params.put("fetchType", "");
        params.put("orderId", "");
        params.put("orderMoney", "");
        params.put("payCanal", "");
        params.put("payTradeId", "");
        params.put("postAge", "");
        params.put("remark", "");
        params.put("userId", loginUser.getUserId());
        params.put("detailReqList", detailReqList);

        InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
        if (orderResult != null && "0000".equals(orderResult.getRespCode())) {
            return new Result(0, "删除成功");
        }
        return new Result(1, "删除失败");
    }

    /**
     * 获取购物车数量
     *
     * @param request
     * @return
     */
    @Override
    public Result getCartCount(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");
        try {
            //查询用户订单列表
            Map<String, Object> params = new HashedMap<>();
            params.put("userId", loginUser.getUserId());
            params.put("paymentType", "0");
            params.put("detailNo", "");
            params.put("orderNo", "");
            InterfaceOrderQueryResult interfaceOrderQueryResult = interfaceService.orderQuery(params);

            if (interfaceOrderQueryResult != null && "0000".equals(interfaceOrderQueryResult.getRespCode())) {
                List<InterfaceOrderQueryDetail> orderList = interfaceOrderQueryResult.getOrderList();
                if (orderList != null && !orderList.isEmpty()) {
                    int count = 0;
                    for (InterfaceOrderQueryDetail order : orderList) {
                        List<InterfaceOrderCardDetail> orderCardDetailList = order.getOrderCardList();
                        if (orderCardDetailList != null && !orderCardDetailList.isEmpty()) {
                            count += orderCardDetailList.size();
                        }
                        List<InterfaceOrderChargeDetail> orderChargeDetailList = order.getOrderChargeList();
                        if (orderChargeDetailList != null && !orderChargeDetailList.isEmpty()) {
                            count += orderChargeDetailList.size();
                        }
                    }
                    return new Result(0, "成功", count);
                }
            }
        } catch (Exception e) {
            logger.error("查询购物车数量异常", e);
        }
        return new Result(1, "购物车为空");
    }

    /**
     * 我的订单，订单详情，页面信息处理
     *
     * @param request
     * @param model
     */
    @Override
    public void setOrderDetail(HttpServletRequest request, Model model) {
        User loginUser = (User)request.getAttribute("loginUser");
        try {
            String orderNo = request.getParameter("orderNo");
            model.addAttribute("orderNo", orderNo);

            //查询用户订单信息
            Map<String, Object> params = new HashedMap<>();
            params.put("userId", loginUser.getUserId());
            params.put("paymentType", "1");
            params.put("orderNo", orderNo);
            params.put("detailNo", "");

            InterfaceOrderQueryResult interfaceOrderQueryResult = interfaceService.orderQuery(params);

            //用户订单信息处理
            if (interfaceOrderQueryResult != null && "0000".equals(interfaceOrderQueryResult.getRespCode())) {

                String payOrderSubject = "";

                List<InterfaceOrderQueryDetail> orderList = interfaceOrderQueryResult.getOrderList();
                if (orderList != null && !orderList.isEmpty()) {
                    InterfaceOrderQueryDetail order = orderList.get(0); //订单详情

                    List<FetchCode> fetchCodeList = new ArrayList<>(); //取件码

                    //卡订单详情列表
                    List<InterfaceOrderCardDetail> orderCardDetailList = order.getOrderCardList();
                    if (orderCardDetailList != null && !orderCardDetailList.isEmpty()) {
                        for (InterfaceOrderCardDetail orderCardDetail : orderCardDetailList) {
                            //处理金额，转换为元
                            orderCardDetail.setPackageMoney(
                                    StringUtil.isNotBlank(orderCardDetail.getPackageMoney()) ?
                                            ((Integer.parseInt(orderCardDetail.getPackageMoney()) / 100) + "") : "0");
                            orderCardDetail.setSupplyMoney(
                                    StringUtil.isNotBlank(orderCardDetail.getSupplyMoney()) ?
                                            ((Integer.parseInt(orderCardDetail.getSupplyMoney()) / 100) + "") : "0");

                            //激活有效期处理
                            String activeEndDate = orderCardDetail.getActiveEndTime();
                            if (StringUtil.isNotBlank(activeEndDate)) {
                                Date activeTime = DateUtil.parse(activeEndDate, "yyyyMMddHHmmss");
                                orderCardDetail.setActiveEndTime(((activeTime.getTime() - System.currentTimeMillis()) / 1000) + "");
                            }

                            if (StringUtil.isNotBlank(orderCardDetail.getFetchCode())) {
                                fetchCodeList.add(new FetchCode(orderCardDetail.getCustName(), orderCardDetail.getFetchCode()));
                            }

                            //处理兑换券金额
                            if ("01".equals(orderCardDetail.getDiscountType()) && StringUtil.isNotBlank(orderCardDetail.getChargeNoPrice())) {
                                orderCardDetail.setChargeNoPrice((Integer.parseInt(orderCardDetail.getChargeNoPrice()) / 100) + "");
                            }

                            //支付订单标题
                            if (StringUtil.isBlank(payOrderSubject)) {
                                payOrderSubject = "Z2".equals(orderCardDetail.getPackageName()) ? "转转卡尊享卡套餐" : "转转卡优享卡套餐";
                            }

                        }
                    }

                    //兑换券订单详情列表
                    List<InterfaceOrderChargeDetail> orderChargeDetailList = order.getOrderChargeList();
                    if (orderChargeDetailList != null && !orderChargeDetailList.isEmpty()) {

                        for (InterfaceOrderChargeDetail orderChargeDetail : orderChargeDetailList) {
                            //处理金额，转换为元
                            orderChargeDetail.setFuncFee(
                                    StringUtil.isNotBlank(orderChargeDetail.getFuncFee()) ?
                                            ((Integer.parseInt(orderChargeDetail.getFuncFee()) / 100) + "") : "0");

                            //支付订单标题
                            if (StringUtil.isBlank(payOrderSubject)) {
                                payOrderSubject = "Z2".equals(orderChargeDetail.getPackageName()) ? "转转卡尊享卡套餐兑换券" : "转转卡优享卡套餐兑换券";
                            }
                        }
                    }

//                    if ("00".equals(order.getFetchType())) { //快递费
//                        order.setOrderMoney((Integer.parseInt(order.getOrderMoney()) / 100 + 5) + "");
//                    } else {
//                        order.setOrderMoney(Integer.parseInt(order.getOrderMoney()) / 100 + "");
//                    }

                    order.setOrderMoney(Integer.parseInt(order.getOrderMoney()) / 100 + "");

                    model.addAttribute("payOrderSubject", payOrderSubject);
                    model.addAttribute("order", order);
                    model.addAttribute("fetchCodeList", fetchCodeList);
                }
            }
        } catch (Exception e) {
            logger.error("查询用户订单信息异常", e);
        }
    }

    /**
     * 查询兑换码是否有效
     *
     * @param request
     * @return
     */
    @Override
    public Result chargeQuery(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");

        String sp = request.getParameter("sp");
        String packageMoney = "200";
        if ("Z2".equals(sp)) {
            packageMoney = "288";
        }

        String cardNo = request.getParameter("id");
        if (StringUtil.isBlank(cardNo)) {
            return new Result(1, "请输入兑换码");
        }
        if (cardNo.trim().length() != 16) {
            return new Result(1, "兑换码输入错误，请重新输入！");
        }
        Map<String, Object> params = new HashedMap<>();
        params.put("cardNo", cardNo);
        params.put("userId", loginUser.getUserId());
        InterfaceCodeQueryResult codeQueryResult = interfaceService.codeQuery(params);
        if (codeQueryResult != null && "0000".equals(codeQueryResult.getRespCode())) {
            if ("0".equals(codeQueryResult.getUseTag())) {
                Map<String, String> data = new HashedMap<>();
                data.put("price", (Integer.parseInt(codeQueryResult.getValue()) / 100) + "");
                data.put("endDate", codeQueryResult.getEndDate());
                if (!packageMoney.equals(data.get("price"))) {
                    return new Result(1, "兑换券类型不匹配！");
                }
                return new Result(0, "兑换码验证成功！", data);
            } else {
                return new Result(1, "兑换码不存在或已被使用！");
            }

        } else if (codeQueryResult != null && "redeem_time_error".equals(codeQueryResult.getRespCode())) {
            return new Result(2, "您的兑换码输入次数过多，请稍后再试！");
        }

        return new Result(1, "验证失败，请重试！");
    }

    /**
     * 保存新增或修改的地址
     *
     * @param request
     * @param model
     * @return
     */
    @Override
    public Result saveAddress(HttpServletRequest request, Model model) {

        User loginUser = (User)request.getAttribute("loginUser");

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String location = request.getParameter("city");
        String address = request.getParameter("detail");
        String addressId = request.getParameter("addressId");
        String isDefault = request.getParameter("isDefault");

        //判断是编辑还是新建
        String type = "00";
        if (StringUtil.isNotBlank(addressId)) {
            type = "01";
        }

        Map<String, Object> params = new HashedMap<>();
        params.put("address", address);
        params.put("addressID", addressId == null ? "" : addressId);
        params.put("isDefault", "1".equals(isDefault) ? "1" : "0");
        params.put("location", location);
        params.put("name", name);
        params.put("phone", phone);
        params.put("type", type);
        params.put("userId", loginUser.getUserId());

        InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
        if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
            return new Result(0, "保存成功");
        }
        return new Result(1, "保存失败");
    }

    /**
     * 删除地址
     *
     * @param request
     * @return
     */
    @Override
    public Result deleteAddress(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");
        String addressId = request.getParameter("addressId");

        Map<String, Object> params = new HashedMap<>();
        params.put("address", "");
        params.put("addressID", addressId);
        params.put("isDefault", "");
        params.put("location", "");
        params.put("name", "");
        params.put("phone", "");
        params.put("type", "02");
        params.put("userId", loginUser.getUserId());

        InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
        if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
            return new Result(0, "删除成功");
        }
        return new Result(1, "删除失败");
    }

    /**
     * 编辑地址，页面信息处理
     *
     * @param request
     * @param model
     */
    @Override
    public void setEditAddress(HttpServletRequest request, Model model) {

        User loginUser = (User)request.getAttribute("loginUser");

        String addressId = request.getParameter("id");
        if (StringUtil.isNotBlank(addressId)) {

            //查询地址列表
            List<InterfaceAddressDetail> addressList = null;
            Map<String, Object> params = new HashedMap<>();
            params.put("address", "");
            params.put("addressID", "");
            params.put("isDefault", "");
            params.put("location", "");
            params.put("name", "");
            params.put("phone", "");
            params.put("type", "03");
            params.put("userId", loginUser.getUserId());
            InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
            if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
                addressList = addressManageResult.getAddressList();
            }

            if (addressList != null) {
                for (InterfaceAddressDetail addressDetail : addressList) {
                    if (addressId.equals(addressDetail.getAddressId())) {
                        model.addAttribute("address",addressDetail);
                        break;
                    }
                }
            }
        }
    }

    /**
     * 设置默认地址
     *
     * @param request
     * @return
     */
    @Override
    public Result saveAddressDefault(HttpServletRequest request) {
        User loginUser = (User)request.getAttribute("loginUser");
        String addressId = request.getParameter("addressId");
        String custName = request.getParameter("custName");
        String custPhone = request.getParameter("custPhone");
        String address = request.getParameter("address");
        String location = request.getParameter("location");

        Map<String, Object> params = new HashedMap<>();
        params.put("address", address);
        params.put("addressID", addressId);
        params.put("isDefault", "1");
        params.put("location", location);
        params.put("name", custName);
        params.put("phone", custPhone);
        params.put("type", "01");
        params.put("userId", loginUser.getUserId());

        InterfaceAddressManageResult addressManageResult = interfaceService.addressManage(params);
        if (addressManageResult != null && "0000".equals(addressManageResult.getRespCode())) {
            return new Result(0, "设置成功");
        }
        return new Result(1, "设置失败");
    }

    /**
     * 提交订单
     *
     * @param request
     * @param model
     * @return
     */
    @Override
    public Result saveOrder(HttpServletRequest request, Model model) {

        User loginUser = (User)request.getAttribute("loginUser");
        String orders = request.getParameter("orders");
        String orderMoney = request.getParameter("orderMoney");
        String delivery = request.getParameter("delivery");
        String deliveryMoney = request.getParameter("deliveryMoney");
        String custname = request.getParameter("custname");
        String custphone = request.getParameter("custphone");
        String address = request.getParameter("address");
        String custlocation = request.getParameter("custlocation");
        String remark = request.getParameter("remark");

        //拼上地市信息
        if (custlocation != null) {
            address = custlocation.replaceAll(",", "") + address;
        }

//        [{"id":"DHQ-20171226134125863-9988801803","pid":"DHQ-20171226134125863-9988801803","num":1,"ordertype":1,"title":"转转卡优享卡套餐兑换券","totalprice":200,"prepay":0,"price":200,"custname":"","custtel":""}]

        String payOrderSubject = "";

        List<Map<String, String>> detailReqList = new ArrayList<>();

        List<Map> orderList = JsonUtil.fromJsonForList(orders, Map.class);
        for (int i = 0; i < orderList.size(); i++) {
            Map order = orderList.get(i);
            String detailNo = order.get("id") == null ? "" : order.get("id") + "";
            String pid = order.get("pid") == null ? "" : order.get("pid") + "";
            String orderType = order.get("ordertype") == null ? "" : order.get("ordertype") + "";
            String packageName = order.get("packagename") == null ? "" : order.get("packagename") + "";
            String num = order.get("num") == null ? "" : order.get("num") + "";
            String title = order.get("title") == null ? "" : order.get("title") + "";
            String totalprice = order.get("totalprice") == null ? "0" : order.get("totalprice") + "";
            String prepay = order.get("prepay") == null ? "0" : order.get("prepay") + "";
            String price = order.get("price") == null ? "0" : order.get("price") + "";
            String scustname = order.get("custname") == null ? "" : order.get("custname") + "";
            String scusttel = order.get("custtel") == null ? "" : order.get("custtel") + "";
            String paperno = order.get("paperno") == null ? "" : order.get("paperno") + "";
            String discounttype = order.get("discounttype") == null ? "" : order.get("discounttype") + "";
            String chargeno = order.get("chargeno") == null ? "" : order.get("chargeno") + "";
            String chargenoprice = order.get("chargenoprice") == null ? "0" : order.get("chargenoprice") + "";

            if (StringUtil.isBlank(payOrderSubject) && StringUtil.isNotBlank(title)) {
                payOrderSubject = title;
            }

            Map<String, String> detailParams = new HashedMap<>();
            detailParams.put("address", "");
            detailParams.put("cardTypeCode", "");
            detailParams.put("cardno", "");
            detailParams.put("discountType", discounttype);
//            detailParams.put("discountMoney", chargenoprice);
            detailParams.put("chargeNo", chargeno);
            detailParams.put("custBirth", "");
            detailParams.put("custEmail", "");
            detailParams.put("custName", scustname); //scustname
            detailParams.put("custPhone", scusttel); //scusttel
            detailParams.put("custPost", "");
            detailParams.put("custSex", "");
            detailParams.put("orderType", orderType); //orderType
            detailParams.put("detailNo", detailNo);
            detailParams.put("packageMoney", (Integer.parseInt(price) * 100) + ""); //price
            detailParams.put("packageType", packageName);
            detailParams.put("paperNo", paperno);
            detailParams.put("paperType", "");
            detailParams.put("photo", ""); //照片(BASE64Encoder byte[]后的字符串)
            detailParams.put("preSupplyMoney", (Integer.parseInt(prepay) * 100) + ""); //prepay
            detailParams.put("remark", "");
            detailReqList.add(detailParams);
        }

        Map<String, Object> params = new HashedMap<>();
        params.put("address", address);
        params.put("custName", custname);
        params.put("custPhone", custphone);
        params.put("custPost", "");
        params.put("fetchType", "kd".equals(delivery) ? "00" : "01");
        params.put("orderId", OrderNoUtil.getOrderNo());
        params.put("orderMoney", Integer.parseInt(orderMoney) * 100 + "");
        params.put("payCanal", "");
        params.put("payTradeId", "");
        params.put("postAge", "kd".equals(delivery) ? (Integer.parseInt(deliveryMoney) * 100 + "") : "");
        params.put("remark", remark);
        params.put("tradeType", "1");
        params.put("userId", loginUser.getUserId());
        params.put("detailReqList", detailReqList);

        InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
        if (orderResult != null) {
            if ("0000".equals(orderResult.getRespCode())) {
                //兑换码抵扣，订单金额为0，直接更新订单支付状态
                if (Integer.parseInt(orderMoney) == 0) {
                    Map<String, Object> params2 = new HashedMap<>();
                    params2.put("orderMoney", "0");
                    params2.put("orderNo", orderResult.getOrderTrade());
                    params2.put("payCanal", "04"); //01支付宝 02微信 04兑换码无其他金额
                    params2.put("payTradeId", "");
                    InterfaceResult interfaceResult = interfaceService.orderPaymentConfirm(params2);
                    if (interfaceResult != null && "0000".equals(interfaceResult.getRespCode())) {
                        return new Result(2, "保存订单成功，更新支付状态");
                    }

                    //支付
                } else {
                    Map<String, String> data = new HashMap<>();
                    data.put("payOrderNo", orderResult.getOrderTrade());
                    data.put("payOrderMoney", orderMoney);
                    data.put("payOrderSubject", payOrderSubject);
                    return new Result(0, "保存订单成功，前往支付", data);
                }

            } else if ("orderinfo_error".equals(orderResult.getRespCode())) {
                return new Result(3, "子订单已提交，不能重复提交，刷新购物车");
            }

        }
        return new Result(1, "保存订单失败，请重试");
    }

    /**
     * 支付宝收银台信息处理
     *
     * @param request
     * @param response
     */
    @Override
    public void alipay(HttpServletRequest request, HttpServletResponse response) {
        try {
            //商户订单号、订单金额、订单标题
            String payOrderNo = request.getParameter("payOrderNo");
            String payOrderMoney = request.getParameter("payOrderMoney");
            String payOrderSubject = request.getParameter("payOrderSubject");

//            payOrderMoney = "0.01";

            //支付参数
            Map<String, String> params = new HashedMap<>();
            params.put("service", AppConfig.ALIPAY_ORDER_METHOD);
            params.put("partner", AppConfig.ALIPAY_APPID);
            params.put("_input_charset", "UTF-8");
            params.put("notify_url", AppConfig.ALIPAY_NOTIFY_URL);
            params.put("return_url", AppConfig.ALIPAY_RETURN_URL);
            params.put("out_trade_no", payOrderNo);
            params.put("subject", payOrderSubject);
            params.put("total_fee", payOrderMoney);
            params.put("seller_id", AppConfig.ALIPAY_APPID);
            params.put("payment_type", "1");
            params.put("app_pay", "Y");
            params.put("show_url", AppConfig.ALIPAY_RETURN_URL);

            //计算签名
            String sign = AlipaySignature.rsaSign(params, AppConfig.ALIPAY_PRIVATE_KEY, AlipayConstants.CHARSET_UTF8);
            params.put("sign", sign);
            params.put("sign_type", AlipayConstants.SIGN_TYPE_RSA);

            //构建支付提交表单
            String form = FormUtils.buildForm(AppConfig.ALIPAY_URL, "get", params);
            response.setContentType("text/html;charset=" + AlipayConstants.CHARSET_UTF8);
            response.getWriter().write(form);
            response.getWriter().flush();
            response.getWriter().close();
        } catch (Exception e) {
            logger.error("支付宝支付异常", e);
        }
    }

    /**
     * 支付宝回调处理
     *
     * @param request
     * @param model
     */
    @Override
    public void alipayReturn(HttpServletRequest request, Model model) {
        try {
            Map requestParams = request.getParameterMap();
            Map<String, String> alipayParams = new HashMap<>();
            for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
                String name = (String) iter.next();
                String[] values = (String[]) requestParams.get(name);
                String valueStr = "";
                for (int i = 0; i < values.length; i++) {
                    valueStr = (i == values.length - 1) ? valueStr + values[i] : valueStr + values[i] + ",";
                }
//                valueStr = new String(valueStr.getBytes("ISO-8859-1"), "UTF-8");
                alipayParams.put(name, valueStr);
            }

            logger.info("支付宝同步回调参数：" + JsonUtil.toJson(alipayParams));

            boolean verifyResult = AlipaySignature.rsaCheckV1(alipayParams, AppConfig.ALIPAY_PUBLIC_KEY, AlipayConstants.CHARSET_UTF8, AlipayConstants.SIGN_TYPE_RSA);

            logger.info("支付宝同步回调验签：verifyResult=" + verifyResult);

            if (verifyResult) {

                String isSuccess = alipayParams.get("is_success"); //请求状态
                String tradeStatus = alipayParams.get("trade_status"); //交易状态

                if ("T".equals(isSuccess) && ("TRADE_FINISHED".equals(tradeStatus) || "TRADE_SUCCESS".equals(tradeStatus))) {

//                    String out_trade_no = alipayParams.get("out_trade_no");
//                    String trade_no = alipayParams.get("trade_no");
//                    String total_fee = alipayParams.get("total_fee");
//                    String seller_id = alipayParams.get("seller_id");
//
//                    try {
//                        //更新接口订单支付状态
//                        Map<String, Object> params = new HashedMap<>();
//                        params.put("orderMoney", ((int)(Float.parseFloat(total_fee) * 100)) + "");
//                        params.put("orderNo", out_trade_no);
//                        params.put("payCanal", "01"); //01支付宝 02微信
//                        params.put("payTradeId", trade_no);
//                        params.put("userId", "");
//                        InterfaceResult interfaceResult = interfaceService.orderPaymentConfirm(params);
//                        if (interfaceResult != null && "0000".equals(interfaceResult.getRespCode())) {
//                            model.addAttribute("ret", 0);
//                            model.addAttribute("msg", "支付成功");
//                        }
//                    } catch (Exception e) {
//                        logger.error("支付宝支付成功，同步回调更新订单支付状态异常", e);
//                    }

                    model.addAttribute("ret", 0);
                    model.addAttribute("msg", "支付成功");
                    return;
                }
            }
        } catch (Exception e) {
            logger.error("支付宝回调处理异常", e);
        }
        model.addAttribute("ret", 1);
        model.addAttribute("msg", "支付回调处理失败");
    }

    /**
     * 支付宝异步通知处理
     *
     * @param request
     * @param response
     * @return
     */
    @Override
    public String alipayNotify(HttpServletRequest request, HttpServletResponse response) {

        try {
            Map requestParams = request.getParameterMap();
            Map<String, String> alipayParams = new HashMap<>();
            for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
                String name = (String) iter.next();
                String[] values = (String[]) requestParams.get(name);
                String valueStr = "";
                for (int i = 0; i < values.length; i++) {
                    valueStr = (i == values.length - 1) ? valueStr + values[i] : valueStr + values[i] + ",";
                }
//                valueStr = new String(valueStr.getBytes("ISO-8859-1"), "UTF-8");
                alipayParams.put(name, valueStr);
            }

            logger.info("支付宝异步通知参数：" + JsonUtil.toJson(alipayParams));

            boolean verifyResult = AlipaySignature.rsaCheckV1(alipayParams, AppConfig.ALIPAY_PUBLIC_KEY, AlipayConstants.CHARSET_UTF8, AlipayConstants.SIGN_TYPE_RSA);

            logger.info("支付宝异步通知验签：verifyResult=" + verifyResult);

            if (verifyResult) {
                String tradeStatus = alipayParams.get("trade_status");

                logger.info("支付宝异步通知：trade_status=" + tradeStatus);

                if ("TRADE_SUCCESS".equals(tradeStatus) || "TRADE_FINISHED".equals(tradeStatus)) {

                    String out_trade_no = alipayParams.get("out_trade_no");
                    String trade_no = alipayParams.get("trade_no");
                    String total_fee = alipayParams.get("total_fee");

                    try {
                        //通知接口订单支付成功
                        Map<String, Object> params = new HashedMap<>();
                        params.put("orderMoney", ((int)(Float.parseFloat(total_fee) * 100)) + "");
                        params.put("orderNo", out_trade_no);
                        params.put("payCanal", "01"); //01支付宝 02微信
                        params.put("payTradeId", trade_no); //微信支付交易流水号
                        params.put("userId", "");
                        InterfaceResult interfaceResult = interfaceService.orderPaymentConfirm(params);
                        if (interfaceResult != null && "0000".equals(interfaceResult.getRespCode())) {
                            return "SUCCESS";
                        }
                    } catch (Exception e) {
                        logger.error("支付宝支付成功，异步通知更新订单支付状态异常", e);
                    }
                }
            }

        } catch (Exception e) {
            logger.error("支付宝异步通知处理异常", e);
        }
        return "FAIL";
    }

    /**
     * 微信收银台信息处理
     *
     * @param request
     * @param response
     */
    @Override
    public Result tenpay(HttpServletRequest request, HttpServletResponse response, Model model) {

        //商户订单号、订单金额、订单标题
        String payOrderNo = request.getParameter("payOrderNo");
        String payOrderMoney = request.getParameter("payOrderMoney");
        String payOrderSubject = request.getParameter("payOrderSubject");
        String openId = request.getParameter("openId");

        logger.info(payOrderSubject);

//        payOrderMoney = "0.01";

        try {
            //JSAPI支付
            Map<String, String> param = new HashMap<String, String>();
            param.put("sub_appid", AppConfig.TEN_APPID);
            param.put("sub_mch_id", AppConfig.TEN_MCH_ID);
//            param.put("device_info", "");
            param.put("nonce_str", Utils.getRandStr(18));
            param.put("body", payOrderSubject);
//            param.put("detail", "");
//            param.put("attach", "");
            param.put("out_trade_no", payOrderNo);
            param.put("fee_type", "CNY");
            param.put("total_fee", ((int)(Float.parseFloat(payOrderMoney) * 100)) + "");
            param.put("spbill_create_ip", AppConfig.TEN_OUTIP);
//            param.put("time_start", "");
//            param.put("time_expire", "");
//            param.put("goods_tag", "");
            param.put("notify_url", AppConfig.TEN_NOTIFY_URL);
            param.put("trade_type", "JSAPI");
//            param.put("product_id", "");
//            param.put("limit_pay", "");
            param.put("sub_openid", openId); //微信公众平台进入时获取到的openId
            param.put("sign", Utils.sign(param, "rpHB9adi3bMjuSIU"));

            String url = "http://open.wtbiz.cn/Api/WxPay/unified.html";
            String signParam = Utils.map2Json(param);

            logger.info("请求地址：" + url);
            logger.info("请求参数：" + signParam);

            String result = Utils.sendPost(url, signParam);

            logger.info("响应内容：" + result);

            //获取支付签名
            Map<String, String> arr = Utils.json2Map(result);
            Map<String,String> payParam = new HashMap<String, String>();
            payParam.put("appId", arr.get("appid"));
            payParam.put("timeStamp", System.currentTimeMillis() /1000 + "");
            payParam.put("nonceStr", Utils.getRandStr(16));
            payParam.put("package", "prepay_id=" + arr.get("prepay_id"));
            payParam.put("signType", "MD5");
            payParam.put("sign", Utils.sign(payParam, "rpHB9adi3bMjuSIU"));
            String paySign = Utils.sendPost("http://open.wtbiz.cn/Api/WxPay/paySign.html", Utils.map2Json(payParam));
            payParam.put("paySign", paySign);
            payParam.put("prepay_id", arr.get("prepay_id"));

            logger.info("页面支付参数：");
            //微信JSAPI支付参数
            for (String key : payParam.keySet()) {
                logger.info(key + "=" + payParam.get(key));
                model.addAttribute(key, payParam.get(key));
            }

            return new Result(0, "微信预支付成功", payParam);
        } catch (Exception e) {
            logger.error("微信支付异常", e);
        }
        model.addAttribute("ret", 1);
        model.addAttribute("msg", "微信支付失败");
        return new Result(1, "微信预支付失败");

//        try {
//            Map<String, String> wxparams = new HashMap<>();
//            wxparams.put("appid", AppConfig.TEN_APPID);
//            wxparams.put("mch_id", AppConfig.TEN_MCH_ID);
//            wxparams.put("nonce_str", RandomUtil.randomChars(32));
//            wxparams.put("body", "转转卡");
//            wxparams.put("out_trade_no", payOrderNo);
//            wxparams.put("total_fee", (Integer.parseInt(payOrderMoney) * 100) + "");
//            wxparams.put("spbill_create_ip", AppConfig.TEN_OUTIP);
//            wxparams.put("notify_url", AppConfig.TEN_NOTIFY_URL);
//            wxparams.put("trade_type", "MWEB");
//            wxparams.put("scene_info", "{\"h5_info\": {\"type\":\"Wap\",\"wap_url\": \"" + AppConfig.TEN_WAPURL + "\",\"wap_name\": \"转转卡\"}}");
//            wxparams.put("sign", WxSignUtil.getSign(wxparams, AppConfig.TEN_APIKEY));
//
//            String responseStr = new HttpClientUtil().post(AppConfig.TEN_UNIFIEDORDER_URL, WxXmlUtil.getXml(wxparams));
//
//            logger.info("微信统一下单响应内容：" + new String(responseStr.getBytes("ISO-8859-1"), "UTF-8"));
//
//            Map<String, String> wxResponseMap = new HashMap<>();
//            Document document = DocumentHelper.parseText(responseStr);
//            Iterator iterator = document.getRootElement().elementIterator();
//            while (iterator.hasNext()) {
//                Element element = (Element)iterator.next();
//                wxResponseMap.put(element.getName(), element.getText());
//            }
//
//            if ("SUCCESS".equals(wxResponseMap.get("return_code"))
//                    && "SUCCESS".equals(wxResponseMap.get("result_code"))) {
//
//                String prepay_id = wxResponseMap.get("prepay_id");
//                String mWebUrl = wxResponseMap.get("mweb_url");
//
//                //拉起微信客户端支付，微信官方不推荐在APP中使用H5支付，建议后面还是要走APP支付
//                response.sendRedirect(mWebUrl);
//            }
//
//        } catch (Exception e) {
//            logger.error("微信统一下单异常", e);
//        }

    }

    /**
     * 微信异步通知处理
     *
     * @param request
     * @param resultXml
     * @return
     */
    @Override
    public String tenpayNotify(HttpServletRequest request, String resultXml) {

        logger.info("微信异步通知内容：" + resultXml);

        Map<String, String> responseResult = new HashMap<>();
        try {

            //获取参数
            Map<String, String> wxResponseMap = new HashMap<>();
            Document document = DocumentHelper.parseText(resultXml);
            Iterator iterator = document.getRootElement().elementIterator();
            while (iterator.hasNext()) {
                Element element = (Element)iterator.next();
                wxResponseMap.put(element.getName(), element.getText());
            }

            //校验签名
            final String sign = wxResponseMap.get("sign");
            wxResponseMap.remove("sign");
            wxResponseMap.put("sign", WxSignUtil.getSign(wxResponseMap, "rpHB9adi3bMjuSIU"));
            String sign2 = Utils.sendPost("http://open.wtbiz.cn/Api/WxPay/validateData.html", Utils.map2Json(wxResponseMap));
            logger.info("微信返回签名：sign=" + sign);
            logger.info("验证生成签名：sign2=" + sign2);
            if (!sign.equals(sign2)) {
                responseResult.put("return_code", "FAIL");
                responseResult.put("return_msg", "通知校验失败");
                return WxXmlUtil.getXml(responseResult);
            }

            //处理业务
            String returnCode = wxResponseMap.get("return_code");
            if ("SUCCESS".equals(returnCode)) {

                String resultCode = wxResponseMap.get("result_code");
                if ("SUCCESS".equals(resultCode)) {

                    String out_trade_no = wxResponseMap.get("out_trade_no");
                    String transaction_id = wxResponseMap.get("transaction_id");
                    String total_fee = wxResponseMap.get("total_fee");

                    //通知接口订单支付成功
                    Map<String, Object> params = new HashedMap<>();
                    params.put("orderMoney", total_fee);
                    params.put("orderNo", out_trade_no);
                    params.put("payCanal", "02"); //01支付宝 02微信
                    params.put("payTradeId", transaction_id); //微信支付交易流水号
                    params.put("userId", "");
                    InterfaceResult interfaceResult = interfaceService.orderPaymentConfirm(params);
                    if (interfaceResult != null && "0000".equals(interfaceResult.getRespCode())) {
                        responseResult.put("return_code", "SUCCESS");
                        return WxXmlUtil.getXml(responseResult);
                    }

                }
            }
        } catch (Exception e) {
            logger.error("微信支付异步通知处理异常", e);
        }
        responseResult.put("return_code", "FAIL");
        responseResult.put("return_msg", "通知处理失败");
        return WxXmlUtil.getXml(responseResult);
    }

    /**
     * 驳回后更新照片信息页面处理
     *
     * @param request
     * @param model
     */
    @Override
    public void setAuthUpdate(HttpServletRequest request, Model model) {
        model.addAttribute("orderNo", request.getParameter("orderNo"));
        model.addAttribute("detailNo", request.getParameter("detailNo"));
        model.addAttribute("custName", request.getParameter("custName"));
        model.addAttribute("custPhone", request.getParameter("custPhone"));
        model.addAttribute("paperNo", request.getParameter("paperNo"));
    }

    /**
     * 保存更新照片
     *
     * @param request
     * @param model
     * @return
     */
    @Override
    public Result saveAuthUpdate(HttpServletRequest request, Model model) {
        User loginUser = (User)request.getAttribute("loginUser");
        String orderNo = request.getParameter("orderNo"); //订单号
        String detailNo = request.getParameter("detailNo"); //子订单号
        String custName = request.getParameter("custName"); //姓名
        String custPhone = request.getParameter("custPhone"); //电话
        String paperNo = request.getParameter("paperNo"); //证件号码
        String avatarPath = request.getParameter("avatarPath"); //头像路径

        //处理上传的头像，照片(BASE64Encoder byte[]后的字符串)
        String photo = "";
        if (StringUtil.isNotBlank(avatarPath)) {
            File file = new File(AppConfig.FILE_PATH + avatarPath);
            if (file.exists()) {
                try {
                    byte[] fileByte = FileUtils.readFileToByteArray(file);
                    photo = Base64.encodeBase64String(fileByte);
                } catch (IOException e) {
                    logger.error("读取上传的照片异常", e);
                }
            }
        }

        Map<String, String> detailParams = new HashedMap<>();
        detailParams.put("orderType", "0");
        detailParams.put("address", "");
        detailParams.put("cardTypeCode", "");
        detailParams.put("cardno", "");
        detailParams.put("chargeNo", "");
        detailParams.put("custBirth", "");
        detailParams.put("custEmail", "");
        detailParams.put("custName", "");
        detailParams.put("custPhone", "");
        detailParams.put("custPost", "");
        detailParams.put("custSex", "");
        detailParams.put("detailNo", detailNo);
        detailParams.put("discountType", "");
        detailParams.put("packageMoney", "");
        detailParams.put("packageType", "");
        detailParams.put("paperNo", "");
        detailParams.put("paperType", "");
        detailParams.put("photo", photo);
        detailParams.put("preSupplyMoney", "");
        detailParams.put("remark", "");

        List<Map<String, String>> detailReqList = new ArrayList<>();
        detailReqList.add(detailParams);

        Map<String, Object> params = new HashedMap<>();
        params.put("tradeType", "2");
        params.put("address", "");
        params.put("custName", "");
        params.put("custPhone", "");
        params.put("custPost", "");
        params.put("fetchType", "");
        params.put("orderId", orderNo);
        params.put("orderMoney", "");
        params.put("payCanal", "");
        params.put("payTradeId", "");
        params.put("postAge", "");
        params.put("remark", "");
        params.put("userId", loginUser.getUserId());
        params.put("detailReqList", detailReqList);

        InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
        if (orderResult != null && "0000".equals(orderResult.getRespCode())) {
            return new Result(0, "更新照片成功");
        }
        return new Result(1, "更新照片失败");
    }

    /**
     * 删除订单
     *
     * @param request
     * @return
     */
    @Override
    public Result deleteOrder(HttpServletRequest request) {

        User loginUser = (User)request.getAttribute("loginUser");

        String orderIds = request.getParameter("orderIds");
        if (StringUtil.isNotBlank(orderIds)) {
            for (String orderId : orderIds.split(",")) {
                Map<String, String> detailParams = new HashedMap<>();
                detailParams.put("orderType", "0");
                detailParams.put("address", "");
                detailParams.put("cardTypeCode", "");
                detailParams.put("cardno", "");
                detailParams.put("chargeNo", "");
                detailParams.put("custBirth", "");
                detailParams.put("custEmail", "");
                detailParams.put("custName", "");
                detailParams.put("custPhone", "");
                detailParams.put("custPost", "");
                detailParams.put("custSex", "");
                detailParams.put("detailNo", "");
                detailParams.put("discountType", "");
                detailParams.put("packageMoney", "");
                detailParams.put("packageType", "");
                detailParams.put("paperNo", "");
                detailParams.put("paperType", "");
                detailParams.put("photo", "");
                detailParams.put("preSupplyMoney", "");
                detailParams.put("remark", "");

                List<Map<String, String>> detailReqList = new ArrayList<>();
                detailReqList.add(detailParams);

                Map<String, Object> params = new HashedMap<>();
                params.put("tradeType", "4");
                params.put("address", "");
                params.put("custName", "");
                params.put("custPhone", "");
                params.put("custPost", "");
                params.put("fetchType", "");
                params.put("orderId", orderId);
                params.put("orderMoney", "");
                params.put("payCanal", "");
                params.put("payTradeId", "");
                params.put("postAge", "");
                params.put("remark", "");
                params.put("userId", loginUser.getUserId());
                params.put("detailReqList", detailReqList);

                InterfaceOrderOpenResult orderResult = interfaceService.orderOpening(params);
            }
        }
        return new Result(0, "删除成功");
    }

    /**
     * 登陆
     *
     * @param request
     * @param response
     * @return
     */
    @Override
    public Result doLogin(HttpServletRequest request, HttpServletResponse response) {
        String userName = request.getParameter("username");
        String password = request.getParameter("password");

        if (StringUtil.isBlank(userName)) {
            return new Result(1, "用户名不能为空");
        }
        if (StringUtil.isBlank(password)) {
            return new Result(1, "密码不能为空");
        }

        //TODO 调用登陆接口登录，返回用户信息
        String userId = "1";

        if (true) {
            //处理跳转地址和登录用户
            CookieSession session = new CookieSession(request);
            String redirectUrl = session.get("redirectUrl");
            session.remove("redirectUrl");
            session.put("userId", userId);
            session.flush(response);
            return new Result(0, "登陆成功", redirectUrl);
        }
        return new Result(1, "登陆失败");
    }

    /**
     * 注册
     *
     * @param request
     * @param response
     * @return
     */
    @Override
    public Result doReg(HttpServletRequest request, HttpServletResponse response) {
        String loginName = request.getParameter("loginName");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");
        String phone = request.getParameter("phone");

        CookieSession session = new CookieSession(request);
        String redirectUrl = session.get("redirectUrl");
        String openId = session.get("openId");

        //TODO 调用注册接口

        return new Result(0, "注册成功", redirectUrl);
    }

    /**
     * 重置密码
     *
     * @param request
     * @param response
     * @return
     */
    @Override
    public Result resetPassword(HttpServletRequest request, HttpServletResponse response) {

        String code = request.getParameter("code");
        if (StringUtil.isBlank(code)) {
            return new Result(1, "验证码不能为空");
        }

        String code2 = (String)request.getSession(true).getAttribute("code");
        if (!code.equals(code2)) {
            return new Result(1, "验证码错误");
        }

        //TODO 调用重置接口

        CookieSession session = new CookieSession(request);
        String redirectUrl = session.get("redirectUrl");

        return new Result(0, "重置密码成功", redirectUrl);
    }

    /**
     * 下发验证码
     *
     * @param request
     * @param response
     * @return
     */
    @Override
    public Result sendCode(HttpServletRequest request, HttpServletResponse response) {

        String code = RandomUtil.random(4);
        request.getSession(true).setAttribute("code", code); //多台部署，可以考虑放入缓存或做session同步

        String codeContent = "你的验证码为：" + code;

        //TODO 调用接口下发验证码

        return new Result(0, "发送成功");
    }

    /**
     * 设置微信分享需要的参数
     *
     * @param url
     * @param model
     */
    @Override
    public void setShareParams(String url, Model model) {

        String timestamp = System.currentTimeMillis() / 1000 + "";
        String nonceStr = Utils.getRandStr(16);

        Map<String, String> signParams = new HashMap<>();
        signParams.put("timestamp", timestamp);
        signParams.put("jsapi_ticket", AppConfig.apiTicket.getTicket());
        signParams.put("noncestr", nonceStr);
        signParams.put("url", url);

        List<String> keyList = new ArrayList<>();
        for (String key : signParams.keySet()) {
            keyList.add(key);
        }

        Collections.sort(keyList);

        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < keyList.size(); i++) {
            String key = keyList.get(i);
            sb.append(i == 0 ? key + "=" + signParams.get(key) : "&" + key + "=" + signParams.get(key));
        }

        logger.info("分享待签名字符串：" + sb.toString());

        String signature = DigestUtil.sha1(sb.toString());

        logger.info("分享签名：" + signature);

        model.addAttribute("appId", AppConfig.WEIXIN_MP_APPID);
        model.addAttribute("timestamp", timestamp);
        model.addAttribute("nonceStr", nonceStr);
        model.addAttribute("signature", signature);

        model.addAttribute("title", "苏州通-转转卡，景点交通伴手礼一卡全包！");
        model.addAttribute("link", AppConfig.DOMAIN_URL2 + "/zzk/wx/index");
        model.addAttribute("imgUrl", AppConfig.DOMAIN_URL2 + "/zzk/resource/zzk/temp/zxk.jpg");
        model.addAttribute("desc", "苏州市旅游局，苏州市民卡有限公司共同发行的旅游一卡通。");
    }

}
