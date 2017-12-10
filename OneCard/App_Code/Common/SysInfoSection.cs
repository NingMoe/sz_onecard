namespace SSO
{

    using System;
    using System.Configuration;

    /***************************************************************
     * 功能名:  子系统配置文件类
     * 更改日期      姓名           摘要 
     * ----------    -----------    --------------------------------
     * 2012/2/2    董翔			    初次开发  
     ****************************************************************/
    public class SysInfosSection : ConfigurationSection
    {
        // 子系统集合.
        [ConfigurationProperty("SysInfos")]
        public SysinfoCollection Sysinfos
        {
            get
            {
                SysinfoCollection sysinfoCollection =
                    (SysinfoCollection)base["SysInfos"];
                return sysinfoCollection;
            }
            set
            { this["Sysinfo"] = value; }
        }
    }

    public class SysinfoCollection : ConfigurationElementCollection
    {
        // 子系统集合
        protected override
                ConfigurationElement CreateNewElement()
        {
            return new SysinfoElement();
        }

        protected override Object
               GetElementKey(ConfigurationElement element)
        {
            return ((SysinfoElement)element).SysName;
        }

        public SysinfoElement this[int index]
        {
            get
            {
                return (SysinfoElement)BaseGet(index);
            }
            set
            {
                if (BaseGet(index) != null)
                {
                    BaseRemoveAt(index);
                }
                BaseAdd(index, value);
            }
        }
    }

    //子系统
    public class SysinfoElement : ConfigurationElement
    {
        public SysinfoElement()
        {

        }

        public SysinfoElement(String sysName,
                String staffTable, String loginURL, string logoutURL)
        {
            SysName = sysName;
            StaffTable = staffTable;
            LoginURL = loginURL;
            LogoutURL = logoutURL;
        }

        // 子系统名称.
        [ConfigurationProperty("sysName", IsRequired = true)]
        public string SysName
        {
            get
            {
                return (string)this["sysName"];
            }
            set
            {
                this["sysName"] = value;
            }
        }

        // 用户表名.
        [ConfigurationProperty("staffTable", IsRequired = true)]
        public string StaffTable
        {
            get
            {
                return (string)this["staffTable"];
            }
            set
            {
                this["staffTable"] = value;
            }
        }

        // 子系统登录地址.
        [ConfigurationProperty("loginURL", IsRequired = true)]
        public string LoginURL
        {
            get
            {
                return (string)this["loginURL"];
            }
            set
            {
                this["loginURL"] = value;
            }
        }

        // 子系统登出地址.
        [ConfigurationProperty("logoutURL", IsRequired = true)]
        public string LogoutURL
        {
            get
            {
                return (string)this["logoutURL"];
            }
            set
            {
                this["logoutURL"] = value;
            }
        }
    }
}