package com.onecard.tourcard.http.aspect;

import com.onecard.tourcard.dto.base.BaseRequest;

import com.onecard.tourcard.service.aspect.CheckChannelIdService;
import com.onecard.tourcard.util.common.Bean2MapUtil;
import com.onecard.tourcard.util.common.exception.ValidException;
import com.onecard.tourcard.util.constants.MessageConstant;
import com.onecard.tourcard.util.security.SignUtil;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.beans.IntrospectionException;
import java.lang.reflect.InvocationTargetException;
import java.util.Map;
import java.util.TreeMap;

/**
 * token校验
 * 说明：
 * 1.将报文中的所有参数加token进行字典排序
 * 2.排序后拼接成一个字符串进行sha1(MD5值)加密生成signature
 * 3.电子市民卡后台用相同的方式得到token
 * 4.通过比对token，判断请求是否合法
 */

@Aspect
@Order(2)
@Component
public class TokenAspect {

    Logger logger = LoggerFactory.getLogger(TokenAspect.class);

    @Autowired
    CheckChannelIdService checkChannelIdService;

    @Value("${isCheckToken}")
    protected String isCheckToken;

    @PostConstruct
    public void init() {
        //TODO
    }

    @Before("execution(* com.onecard.tourcard.service.mobile.*.*(..))")
    public void tokenHandle(JoinPoint joinPoint) throws IllegalAccessException, IntrospectionException, InvocationTargetException {
        logger.debug("开始验证token...");
        if (isCheckToken.equals("false")) {
            return;
        }
        Object[] obj = joinPoint.getArgs();
        for (Object o : obj) {
            if (o instanceof BaseRequest) {
                //TODO
                //将service放在扫描包之外
                checkToken((BaseRequest) o);
            } else {
                return;
            }
        }
    }

    /**
     * 签名验证
     * @param request
     * @throws IllegalAccessException
     * @throws IntrospectionException
     * @throws InvocationTargetException
     */
    private void checkToken(BaseRequest request) throws IllegalAccessException, IntrospectionException, InvocationTargetException {
        TreeMap<String, String>  beanmap = Bean2MapUtil.convertBeanToMap(request);
        Map<String, String> domainKey = checkChannelIdService.getChannelId(request);
        /**
         * 根据报文的chanelId获取对应渠道的私钥
         **/
        String apiKeyDB = domainKey.get("apiKey");
        logger.info("request token  :"+ request.getToken());
        logger.info("apiKeyDB" + apiKeyDB);
        boolean ret = SignUtil.checkSignature(apiKeyDB, beanmap);
        if (!ret) {
            throw new ValidException(MessageConstant.Token_ERROR, "Token校验失败!");
        }
        logger.info("Token校验成功!");
    }
}

