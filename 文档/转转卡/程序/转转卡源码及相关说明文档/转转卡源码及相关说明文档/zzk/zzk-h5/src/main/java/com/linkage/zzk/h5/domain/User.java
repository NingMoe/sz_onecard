package com.linkage.zzk.h5.domain;

import lombok.Data;

import java.io.Serializable;

/**
 * @author: John
 */
@Data
public class User implements Serializable {

    private String userId;

    private String openId;

    public User() {

    }

    public User(String userId) {
        this.userId = userId;
    }

    public User(String userId, String openId) {
        this.userId = userId;
        this.openId = openId;
    }

}
