# Whitelist Cloudflare IPs 
Bash script based on their [support page](https://support.cloudflare.com/hc/en-us/articles/200169166-How-do-I-whitelist-CloudFlare-s-IP-addresses-in-iptables-) for whitelisting cloudflare ips as well as setting nginx config to show real ips.
Create a new bash script ``` touch cloudflarewhitelister.sh ``` , copy and paste the contents into the file. Set the file to be executable chmod +x cloudflarewhitelister.sh 
And just set it to run a couple times a day.

Uncomment the RHEL/CentOS lines and comment out the Debian/Ubuntu lines at the end, depending on your ditro.

```
#!/bin/bash
echo "#Cloudflare" > /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
iptables -F cloudflare;
iptables -N cloudflare;
for ip in `curl https://www.cloudflare.com/ips-v4`; do
        iptables -A cloudflare -I INPUT -p tcp -m multiport --dports http,https -s "$ip" -j ACCEPT;
        echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
done

ip6tables -F cloudflare;
ip6tables -N cloudflare;
for ip in `curl https://www.cloudflare.com/ips-v6`; do
        ip6tables -A cloudflare -I INPUT -p tcp -m multiport --dports http,https -s "$ip" -j ACCEPT;
        echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
done

echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;

#Debian/Ubuntu
iptables-save > /etc/iptables/rules.v4;
ip6tables-save > /etc/iptables/rules.v6;

#RHEL/CentOS
#iptables-save > /etc/sysconfig/iptables;
#ip6tables-save > /etc/sysconfig/ip6tables;
```

# Nginx Real IP
 Since CloudFlare acts as a reverse proxy, all connections now come from one of CloudFlare's IP addresses. CloudFlare follows industry standards and includes the originating IP address in the X-Forwarded-For header. The CF-Connecting-IP header may also be used. To preserve the originating IP of your visitor, ensure the following Nginx module is available:

http://nginx.org/en/docs/http/ngx_http_realip_module.html

You can verify that it was compiled in your current NGINX installation with the `nginx -V` command, checking for the `--with-http_realip_module`.

By default the `nginx.conf` file includes all configurations in the `/etc/nginx/conf.d/` folder, so this script should automatically add the correct parameters to rewrite all of Cloudflare's IPs.
