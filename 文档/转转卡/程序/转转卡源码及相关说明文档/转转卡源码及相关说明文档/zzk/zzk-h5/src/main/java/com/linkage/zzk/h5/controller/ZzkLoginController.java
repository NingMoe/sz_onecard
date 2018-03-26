package com.linkage.zzk.h5.controller;

import com.linkage.zzk.base.session.CookieSession;
import com.linkage.zzk.base.util.Result;
import com.linkage.zzk.base.util.StringUtil;
import com.linkage.zzk.h5.service.ZzkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author: John
 */
@Controller
@RequestMapping("/zzk")
public class ZzkLoginController {

    @Autowired
    private ZzkService zzkService;

    /**
     * 登陆页面
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/login")
    public String login(HttpServletRequest request, HttpServletResponse response) {
        String redirectUrl = request.getParameter("redirectUrl");
        if (StringUtil.isNotBlank(redirectUrl)) {
            CookieSession session = new CookieSession(request);
            session.put("redirectUrl", redirectUrl);
            session.flush(response);
        }
        return "zzk/login";
    }

    /**
     * 登陆
     *
     * @param request
     * @param response
     * @return
     */
    @RequestMapping(value = "/doLogin", method = RequestMethod.POST)
    public @ResponseBody Result doLogin(HttpServletRequest request, HttpServletResponse response) {
        return zzkService.doLogin(request, response);
    }

    /**
     * 注册页面
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/reg")
    public String reg(HttpServletRequest request, HttpServletResponse response) {
        String redirectUrl = request.getParameter("redirectUrl");
        if (StringUtil.isNotBlank(redirectUrl)) {
            CookieSession session = new CookieSession(request);
            session.put("redirectUrl", redirectUrl);
            session.flush(response);
        }
        return "zzk/reg";
    }

    /**
     * 注册
     *
     * @param request
     * @param response
     * @return
     */
    @RequestMapping(value = "/doReg", method = RequestMethod.POST)
    public @ResponseBody Result doReg(HttpServletRequest request, HttpServletResponse response) {
        return zzkService.doReg(request, response);
    }

    /**
     * 忘记密码页面
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/forget")
    public String forget(HttpServletRequest request, HttpServletResponse response) {
        String redirectUrl = request.getParameter("redirectUrl");
        if (StringUtil.isNotBlank(redirectUrl)) {
            CookieSession session = new CookieSession(request);
            session.put("redirectUrl", redirectUrl);
            session.flush(response);
        }
        return "zzk/forget";
    }

    /**
     * 重置密码
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/resetPassword")
    public @ResponseBody Result resetPassword(HttpServletRequest request, HttpServletResponse response) {
        return zzkService.resetPassword(request, response);
    }

    /**
     * 下发验证码
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/sendCode")
    public @ResponseBody Result sendCode(HttpServletRequest request, HttpServletResponse response) {
        return zzkService.sendCode(request, response);
    }

}
