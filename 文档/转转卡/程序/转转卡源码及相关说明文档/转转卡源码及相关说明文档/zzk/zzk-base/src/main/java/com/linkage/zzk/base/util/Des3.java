package com.linkage.zzk.base.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESedeKeySpec;
import javax.crypto.spec.IvParameterSpec;
import java.security.Key;

/**
 * 3DES加密工具
 *
 * @author : John
 */
public class Des3 {

	private final Logger logger = LoggerFactory.getLogger(getClass());

	private String secretKey = "njxeqgjypxfuomlianchuang"; //密钥

	private final  String iv = "01234567"; //向量

	private final String encoding = "utf-8"; //编码

	public Des3(String secretKey) {
		this.secretKey = secretKey;
	}

	/**
	 * 加密
	 *
	 * @param plainText
	 * @return
	 */
	public String encode(String plainText) {
		try {
			DESedeKeySpec spec = new DESedeKeySpec(secretKey.getBytes());
			SecretKeyFactory keyfactory = SecretKeyFactory.getInstance("desede");
			Key deskey = keyfactory.generateSecret(spec);

			Cipher cipher = Cipher.getInstance("desede/CBC/PKCS5Padding");
			IvParameterSpec ips = new IvParameterSpec(iv.getBytes());
			cipher.init(Cipher.ENCRYPT_MODE, deskey, ips);
			byte[] encryptData = cipher.doFinal(plainText.getBytes(encoding));
			return Base64.encode(encryptData);
		} catch (Exception e) {
			logger.error("加密异常", e);
			return null;
		}

	}

	/**
	 * 解密
	 *
	 * @param encryptText
	 * @return
	 */
	public String decode(String encryptText) {
		try {
			DESedeKeySpec spec = new DESedeKeySpec(secretKey.getBytes());
			SecretKeyFactory keyfactory = SecretKeyFactory.getInstance("desede");
			Key deskey = keyfactory.generateSecret(spec);

			Cipher cipher = Cipher.getInstance("desede/CBC/PKCS5Padding");
			IvParameterSpec ips = new IvParameterSpec(iv.getBytes());
			cipher.init(Cipher.DECRYPT_MODE, deskey, ips);

			byte[] decryptData = cipher.doFinal(Base64.decode(encryptText));
			return new String(decryptData, encoding);
		} catch (Exception e) {
			logger.error("解密异常", e);
			return null;
		}
	}

}
