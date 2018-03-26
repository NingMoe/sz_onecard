package com.linkage.zzk.h5.common.weixin;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * @author John
 */
@Data
public class AccessToken implements Serializable {

    @JsonProperty("access_token")
    private String accessToken;

    @JsonProperty("expires_in")
    private String expiresIn;

    @JsonIgnore
    private long createTime;

    public boolean isExpires() {
        return ((System.currentTimeMillis() - createTime) / 1000) > 7200;
    }

}
