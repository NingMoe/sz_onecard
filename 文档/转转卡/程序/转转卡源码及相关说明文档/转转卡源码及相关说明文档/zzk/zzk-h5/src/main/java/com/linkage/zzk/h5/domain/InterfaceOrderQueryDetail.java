package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * @author: John
 */
@Data
public class InterfaceOrderQueryDetail implements Serializable {

    @JsonIgnore
    private String orderTitle;

    @JsonProperty("orderNo")
    private String orderNo;

    @JsonProperty("paymentState")
    private String paymentState; //0未支付 1已支付

    @JsonProperty("rejectType")
    private String rejectType; //0正常 1驳回

    @JsonProperty("orderState")
    private String orderState; //0处理中，1 已制卡，2已配送

    @JsonProperty("orderMoney")
    private String orderMoney;

    @JsonProperty("postAge")
    private String postage; //邮费，单位分

    @JsonProperty("fetchType")
    private String fetchType; //00快递，01自取

    @JsonProperty("receiveCustName")
    private String receiveCustName;

    @JsonProperty("receiveAddress")
    private String receiveAddress;

    @JsonProperty("receiveCustPhone")
    private String receiveCustPhone;

    @JsonProperty("trackingNo")
    private String trackingNo;

    @JsonProperty("logisticsCompany")
    private String logisticsCompany;

    @JsonProperty("createTime")
    private String createTime;

    @JsonProperty("remark")
    private String remark;

    @JsonProperty("orderCardList")
    private List<InterfaceOrderCardDetail> orderCardList;

    @JsonProperty("orderChargeList")
    private List<InterfaceOrderChargeDetail> orderChargeList;

}
