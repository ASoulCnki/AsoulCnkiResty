local json = require("cjson")

local function decodeJSON(response)
    local status, result = pcall(json.decode, response)
    if not status then
        return nil, result
    end
    return result
end

-- keywords
local keywords = {}

local function codeGenKeyWordRe(keywords)
    if #keywords == 0 then
        return nil
    end

    if type(keywords) == "string" then
        keywords = {keywords}
    end

    return '(' .. table.concat(keywords, "|") .. ')'
end

local keywordsRegex = codeGenKeyWordRe(keywords)

local isContentHasKeyword = function(content, keywordsRegex)
    if content == nil or content == '' then
        return false
    end
    local m = ngx.re.match(content, keywordsRegex, "ijo")
    return m ~= nil
end

local function filterByKeyword(listStr)
    local list = decodeJSON(listStr)

    if not list or #list == 0 then
        return {}
    end

    local result = table.new(#list, 0)
    for _, v in ipairs(list) do
        if not isContentHasKeyword(v['content'], keywordsRegex) then
            table.insert(result, v)
        end
    end

    return result
end

local function filterResult(res)
    if not keywordsRegex then
        return res
    end

    res = decodeJSON(res)

    if res and res.data and res.data.replies then
        local listStr = json.encode(res.data.replies)
        res.data.replies = filterByKeyword(listStr)
    end

    return json.encode(res)
end

local _M = {}

_M.filterByKeyword = filterByKeyword
_M.filterResult = filterResult
return _M
