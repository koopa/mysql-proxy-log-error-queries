local err_flag = false
function read_query( packet )
    if packet:byte() == proxy.COM_QUERY then
        local user = proxy.connection.client.username
        local host = proxy.connection.client.src.name
--        print(user .. '@' .. host)
        if --[[true or]] user:lower() == 'someuser' then
--[[
--  host will always be localhost because of proxy
          and not ( host:lower() == 'localhost'
              or host:lower() == '127.0.0.1' ) then
]]
            proxy.queries:append(1, packet, {resultset_is_needed = true})
            proxy.queries:append(2, string.char(proxy.COM_QUERY) .. "SET @last_query = '" .. string.sub(packet, 2) .. "'", {resultset_is_needed = true} )
            proxy.queries:append(3, string.char(proxy.COM_QUERY) .. "SHOW WARNINGS", {resultset_is_needed = true} )
        end
        return proxy.PROXY_SEND_QUERY
    end
end


function insert_query(err_t, err_n, err_m)
  local query = "INSERT INTO `somedb`.`mysql_error` " ..
    "(`date`, `err_num`,`err_type`, `err_message`, `problem_query`, `conn_id`)" ..
    "VALUES( NOW(), " ..
    err_n  ..  "," .. "\"" ..
    err_t .."\"" .. "," .. "\"" ..
    err_m .. "\"" .. "," ..
    "@last_query" .. "," ..
    proxy.connection.server.thread_id .. ")"
--    print(query)
    proxy.queries:append(4, string.char(proxy.COM_QUERY) .. query, {resultset_is_needed = true})
    return proxy.PROXY_SEND_QUERY
end


function read_query_result(inj)
    local res = assert(inj.resultset)
    if inj.id == 1 then
        err_flag = false
        if res.query_status == proxy.MYSQLD_PACKET_ERR then
            err_flag = true
            return proxy.PROXY_IGNORE_RESULT
        end
    elseif inj.id == 2 then
        return proxy.PROXY_IGNORE_RESULT
    elseif inj.id == 3 then
        if err_flag == true then
            for row in res.rows do
                proxy.response.type = proxy.MYSQLD_PACKET_ERR
                proxy.response.errmsg = row[3]
                insert_query(row[1], row[2], row[3])
            end
            return proxy.PROXY_SEND_RESULT
        end
        return proxy.PROXY_IGNORE_RESULT
    elseif inj.id == 4 then
        return proxy.PROXY_IGNORE_RESULT
    end
end
