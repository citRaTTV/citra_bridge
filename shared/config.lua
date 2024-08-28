return {
    debug = GetConvar('citRa:debug', 'false') == 'true',
    notify = GetConvar('citRa:notify', 'ox'), -- Set to 'framework' in server.cfg to use built-in
}
