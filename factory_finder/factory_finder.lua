local function drawMap(mon, map)
    local old_term = term.current()
    term.redirect(mon)
    paintutils.drawImage(map, 0, 0)
    term.redirect(old_term)
end

local function drawPoints(factory_to_highlight)
    if factory_to_highlight["config"] ~= nil then
        paintutils.drawPixel(factory_to_highlight["config"]["map_x"], factory_to_highlight["config"]["map_y"], colors
        .red)
    end
end

local function update_board(board, factory_to_highlight)
    if factory_to_highlight["item"] == "" then
        board.setCursorPos(1, 2)
        board.write("Posez un item sur le dépot.")
    elseif factory_to_highlight["config"] == nil then
        board.setCursorPos(1, 2)
        board.write("Pas encore d'usine pour cet item.")
    else
        board.setCursorPos(1, 2)
        board.write("Usine à " .. factory_to_highlight["item"])
    end
    rs.setOutput("front", true)
    os.sleep(0.1)
    rs.setOutput("front", false)
end

local function render(mon, board, map, factory_to_highlight)
    drawMap(mon, map)
    drawPoints(factory_to_highlight)
    update_board(board, factory_to_highlight)
end

local function clean_spaces(str)
    return string.gsub(str, "%s*$", "")
end

local function read_item(depot)
    local item_info = clean_spaces(depot.getLine(1))
    return item_info
end

local function update(mon, board, depot, config, map)
    local item = read_item(depot)
    local factory_to_highlight = { item = item }
    factory_to_highlight["config"] = config[item]
    render(mon, board, map, factory_to_highlight)
end

local function load_config(filename)
    local config_file = fs.open(filename, "r")
    local config_str = config_file.readAll()
    config_file.close()
    return textutils.unserialiseJSON(config_str)
end

local function main()
    local mon = peripheral.find("monitor")
    local board = peripheral.find("create_source")
    local depot = peripheral.find("create_target")
    local map = paintutils.loadImage("map.nfp")
    local config = load_config("config.json")
    while true do
        update(mon, board, depot, config, map)
        os.sleep(1)
    end
end

main()
