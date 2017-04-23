

def read_game_state_file(day=0)
   items = []
   
   lines = File.readlines("turn#{day}.txt")   

    my_ship_count = lines[0].to_i
    entity_count = lines[1].to_i 

    entity_count.times do |line_ind|
        entity_id, entity_type, x, y, arg_1, arg_2, arg_3, arg_4 = lines[line_ind+2].split(" ")
        entity_id = entity_id.to_i
        x = x.to_i
        y = y.to_i
        arg_1 = arg_1.to_i
        arg_2 = arg_2.to_i
        arg_3 = arg_3.to_i
        arg_4 = arg_4.to_i
        items << {id: entity_id, type: entity_type, pos:[x,y], info:[arg_1,arg_2,arg_3,arg_4]}
    end
  items

end

def read_game_state
    items = []
   
    my_ship_count = gets.to_i # the number of remaining ships
    entity_count = gets.to_i # the number of entities (e.g. ships, mines or cannonballs)
  
    entity_count.times do
        entity_id, entity_type, x, y, arg_1, arg_2, arg_3, arg_4 = gets.split(" ")
        entity_id = entity_id.to_i
        x = x.to_i
        y = y.to_i
        arg_1 = arg_1.to_i
        arg_2 = arg_2.to_i
        arg_3 = arg_3.to_i
        arg_4 = arg_4.to_i
        items << {id: entity_id, type: entity_type, pos:[x,y], info:[arg_1,arg_2,arg_3,arg_4]}
    end
    items

end


