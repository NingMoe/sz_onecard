package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 订单开通详情
 *
 * @author: John
 */
@Data
public class InterfaceOrderOpenDetail implements Serializable {

    @JsonProperty("detailNo")
    private String detailNo;

    @JsonProperty("fetchNo")
    private String fetchNo;

}
