function async(f)
    return function(...)
        local co = coroutine.create(f)
        local ret = {true, ...}
        while coroutine.status(co) ~= 'dead' do
            ret = {coroutine.resume(co, unpack(ret, 2))}
        end
        return unpack(ret, 2)
    end
end
await = coroutine.yield

do
    local add =
        async(
        function(a, b)
            return a + b
        end
    )
    local function mul(a, b)
        return a * b
    end
    local main =
        async(
        function()
            local c, d = await(add(1, 2), 3 + 4)
            local e = await(mul(c, d))
            print(c, d, e)
        end
    )
    main()
end

do
    local function callback_example(a, b, cb)
        cb('Greetings ' .. a .. ' and ' .. b)
    end
    local function callback_removed(a, b)
        local co = coroutine.running()
        local done
        local ret
        callback_example(
            a,
            b,
            function(...)
                -- A
                done = true
                ret = {...}
                if coroutine.status(co) == 'suspended' then
                    coroutine.resume(co)
                end
            end
        )
        -- B
        if not done then
            coroutine.yield()
        end
        return unpack(ret)
    end
    local main =
        async(
        function()
            print(await(callback_removed('tom', 'jerry')))
            print(await(callback_removed('foo', 'bar')))
        end
    )
    main()
end
