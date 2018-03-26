package com.linkage.zzk.h5.common.weixin;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * @author: John
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserAccessToken {

    @JsonProperty("access_token")
    private String accessToken;

    @JsonProperty("expires_in")
    private int expiresIn;

    @JsonProperty("refresh_token")
    private String refreshToken;

    @JsonProperty("openid")
    private String openId;

    @JsonProperty("scope")
    private String scope;

}
