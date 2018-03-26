package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 接口响应结果码和描述
 *
 * @author: John
 */
@Data
public class InterfaceResult implements Serializable {

    @JsonProperty("respCode")
    private String respCode;

    @JsonProperty("respDesc")
    private String respDesc;

}
