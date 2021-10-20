# Refactor ASoulCnki GateWay

对枝网当前使用的网关脚本进行重构，添加缓存

## 配置项目

先添加 `/usr/local/openresty/bin` 到 PATH

```bash
export PATH=$PATH:/usr/local/openresty/bin
```

### 安装依赖
```bash
opm get ledgetech/lua-resty-http
```

## 运行脚本


```bash
cd web/
# 启动
openresty -p `pwd` -c conf/nginx.conf
# 停止
openresty -p `pwd` -c conf/nginx.conf -s stop
# 重载配置
openresty -p `pwd` -c conf/nginx.conf -s reload
# 测试配置
openresty -p `pwd` -c conf/nginx.conf -t
```