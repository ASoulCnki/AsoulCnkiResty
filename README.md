# Refactor ASoulCnki GateWay

对枝网当前使用的网关脚本进行重构，添加缓存

## 配置项目

先添加 `/usr/local/openresty/bin` 到 PATH

```bash
export PATH=$PATH:/usr/local/openresty/bin
```

### 安装依赖
将 `/web/lua/vendor/lua-utf8.so` 移动到 `openresty/site/lualib/` 下


### 配置

配置文件位于 `lua/config.lua`

```lua
local _M = {}

_M.requests = {
    -- 接口地址 请根据生产环境状况修改
    base_url = 'https://asoulcnki.asia/v1/api'
}

_M.cache = {
    -- 缓存过期时间(秒)
    expire = 4000
}

_M.api = {
    check = {
        -- check 的文本长度限制，UTF-8
        min_length = 10,
        max_length = 1000
    },
    flush = {
        -- 清空缓存的参数
        secret = "114514"
    },
    data = {
        -- data接口的secure_key
        secure_key = "114514"
    }
}

return _M
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

## 项目结构

```
./
├── bin
├── util
└── web
    ├── conf              NGINX 配置文件
    ├── dist              前端静态文件位置
    ├── dist              现在只用来放404页面，防止报错
    ├── logs              日志位置
    └── lua               lua 脚本目录
        ├── api           接口限流规则和缓存规则，待完善
        │   ├── check
        │   ├── data
        │   └── ranking
        ├── hooks         
        ├── utils
        └── vendor        第三方库等
```

其他待补充