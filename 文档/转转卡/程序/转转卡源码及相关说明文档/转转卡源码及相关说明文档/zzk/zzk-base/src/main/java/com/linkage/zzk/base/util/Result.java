package com.linkage.zzk.base.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.Serializable;

/**
 * 结果封装
 *
 * @author : John
 */
public class Result implements Serializable {

    private int ret;

    private String msg;

    private Object data;

    public Result() {

    }

    public Result(int ret, String msg) {
        this.ret = ret;
        this.msg = msg;
    }

    public Result(int ret, String msg, Object data) {
        this.ret = ret;
        this.msg = msg;
        this.data = data;
    }

    public int getRet() {
        return ret;
    }

    public void setRet(int ret) {
        this.ret = ret;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

	public String toJson() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return null;
        }
    }

}
