require '@oxmysql.lib.MySQL'

local function buildFilter(filter, logic)
    local whereString = ''
    if filter and #filter > 0 then
        for i = 1, #filter do
            whereString = ("%s %s "):format(whereString, (whereString:len() > 0 and logic or 'WHERE'))
            whereString = ("%s `%s` = '%s'"):format(whereString, filter[i].key, tostring(filter[i].value))
        end
    end
    return whereString
end

local function debug(query)
    lib.print.debug("Executing query: " .. query)
end

lib.callback.register('citra_bridge:server:getEntityCoords', function(_, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    return entity ~= 0 and GetEntityCoords(entity)
end)

return {
    db = {
        ---Performs a select query
        ---@param table string
        ---@param cols string[]?
        ---@param filter { key:string, value:any }[]?
        ---@param andLogic boolean? #Use AND for `filter` instead of OR
        ---@return table data
        select = function(table, cols, filter, andLogic)
            local colString, whereString = '*', buildFilter(filter, (andLogic and 'AND' or 'OR'))
            if cols and #cols > 0 then
                colString = ''
                for i = 1, #cols do
                    colString = colString .. cols[i]
                    if i < #cols then colString = colString .. ', ' end
                end
            end
            local query = ("SELECT %s FROM %s%s"):format(colString, table, whereString)
            debug(query)
            return MySQL.query.await(query) or {}
        end,

        ---Performs a scalar query
        ---@param table string
        ---@param col string
        ---@param filter { key:string, value:any }[]
        ---@param andLogic boolean? #Use AND for `filter` instead of OR
        ---@return table data
        scalar = function(table, col, filter, andLogic)
            local whereString = buildFilter(filter, andLogic)
            local query = ("SELECT %s FROM %s%s"):format(col, table, whereString)
            debug(query)
            return MySQL.scalar.await(query)
        end,

        ---Performs an update query
        ---@param table string
        ---@param kvp { string:any }[]
        ---@param filter { key:string, value:any }[]?
        ---@param andLogic boolean? #Use AND for `filter` instead of OR
        ---@return integer numRows
        update = function(table, kvp, filter, andLogic)
            local kvpString, whereString = '', buildFilter(filter, andLogic)
            if type(kvp) ~= 'table' or not next(kvp) then return 0 end
            for k, v in pairs(kvp) do
                kvpString = ("%s %s = %s"):format(kvpString, k, type(v) == 'string' and "'" .. v .. "'" or v)
                if next(kvp, k) then kvpString = kvpString .. ',' end
            end
            local query = ("UPDATE %s SET%s%s"):format(table, kvpString, whereString)
            debug(query)
            return MySQL.update.await(query) or 0
        end,

        ---Performs a raw query
        ---@param query string
        ---@return any
        raw = function(query)
            debug(query)
            return MySQL.query.await(query)
        end,
    },
}
