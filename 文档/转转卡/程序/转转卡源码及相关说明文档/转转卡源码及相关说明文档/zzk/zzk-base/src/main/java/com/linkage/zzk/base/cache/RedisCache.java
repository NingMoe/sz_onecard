package com.linkage.zzk.base.cache;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.ListOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.SetOperations;
import org.springframework.data.redis.core.ZSetOperations;

import java.util.Date;
import java.util.concurrent.TimeUnit;

/**
 * Redis支持
 *
 * @author: John
 */
public class RedisCache {

    private final Logger log = LoggerFactory.getLogger(getClass());

    private RedisTemplate redisTemplate;

    public RedisCache(RedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public RedisTemplate getRedisTemplate() {
        return redisTemplate;
    }

    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, Object value, String expiration) {
        redisTemplate.opsForValue().set(key, value, CacheTime.parseDuration(expiration), TimeUnit.SECONDS);
    }

    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    public long incr(String key, int by) {
        return redisTemplate.opsForValue().increment(key, by);
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    public void setExpire(String key, String expiration) {
        redisTemplate.expire(key, CacheTime.parseDuration(expiration), TimeUnit.SECONDS);
    }

    public void setExpireAt(String key, Date date) {
        redisTemplate.expireAt(key, date);
    }

    public Long getExpire(String key, TimeUnit timeUnit) {
        return redisTemplate.getExpire(key, timeUnit);
    }

    public ListOperations getListOperations() {
        return redisTemplate.opsForList();
    }

    public SetOperations getSetOperations() {
        return redisTemplate.opsForSet();
    }

    public ZSetOperations getZSetOperations() {
        return redisTemplate.opsForZSet();
    }

}
