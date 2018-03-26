package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 地址详情
 *
 * @author: John
 */
@Data
public class InterfaceAddressDetail implements Serializable {

    @JsonProperty("addresID")
    private String addressId;

    @JsonProperty("custName")
    private String custName;

    @JsonProperty("custAddress")
    private String address;

    @JsonProperty("custPhone")
    private String custPhone;

    @JsonProperty("location")
    private String location;

    @JsonProperty("isDefault")
    private String isDefault;

}
