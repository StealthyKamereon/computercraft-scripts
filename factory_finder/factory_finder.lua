local function draw_map(mon, map)
    paintutils.drawImage(map, 1, 1)
end

local function draw_points(factory_to_highlight)
    if factory_to_highlight["config"] ~= nil then
        paintutils.drawPixel(factory_to_highlight["config"]["map_x"], factory_to_highlight["config"]["map_y"], colors
            .red)
    end
end

local function update_board(board, factory_to_highlight)
    board.clear()
    board.setCursorPos(1, 1)
    board.write("Où est l'usine ?")
    if factory_to_highlight["item"] == "" then
        board.setCursorPos(1, 2)
        board.write("Posez un item sur le dépot.")
    elseif factory_to_highlight["config"] == nil then
        board.setCursorPos(1, 2)
        board.write("Pas encore d'usine")
        board.setCursorPos(1, 3)
        board.write("pour cet item.")
    else
        local config = factory_to_highlight["config"]
        board.setCursorPos(1, 2)
        board.write("Usine à " .. factory_to_highlight["item"])
        board.setCursorPos(1, 3)
        board.write("Position :")
        board.setCursorPos(3, 4)
        board.write("X: " .. config["x"])
        board.setCursorPos(3, 5)
        board.write("Y: " .. config["y"])
        board.setCursorPos(3, 6)
        board.write("Z: " .. config["z"])
    end
    rs.setOutput("left", true)
    os.sleep(0.1)
    rs.setOutput("left", false)
end

local function render(mon, board, map, factory_to_highlight)
    local old_term = term.current()
    term.redirect(mon)
    draw_map(mon, map)
    draw_points(factory_to_highlight)
    term.redirect(old_term)
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
    local map = paintutils.loadImage("/factory_finder/map.nfp")
    local config = load_config("/factory_finder/config.json")
    while true do
        update(mon, board, depot, config, map)
        os.sleep(1)
    end
end

main()
