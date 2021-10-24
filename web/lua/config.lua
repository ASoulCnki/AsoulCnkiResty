local _M = {}

_M.requests = {
    base_url = 'https://asoulcnki.asia/v1/api'
}

_M.cache = {
    expire = 5400
}

_M.api = {
    check = {
        min_length = 10,
        max_length = 1000
    },
    flush = {
        secret = "114514"
    },
    data = {
        secure_key_len = 8
    }
}

return _M
