

def read_game_state_file(day=0)

  items = []

  lines = File.readlines("turn#{day}.txt")

  my_ship_count = lines[0].to_i
  entity_count = lines[1].to_i

  entity_count.times do |line_ind|
    entity_id, entity_type, x, y, arg_1, arg_2, arg_3, arg_4 = lines[line_ind+2].split(" ")
    itt = Item.new
    itt.id = entity_id.to_i
    itt.type = entity_type
    itt.pos = [x.to_i,y.to_i]
    itt.info = [arg_1.to_i,arg_2.to_i,arg_3.to_i,arg_4.to_i]
    items << itt
  end

  items
end

def read_game_state
  items = []

  my_ship_count = gets.to_i # the number of remaining ships
  entity_count = gets.to_i # the number of entities (e.g. ships, mines or cannonballs)

  entity_count.times do
    entity_id, entity_type, x, y, arg_1, arg_2, arg_3, arg_4 = gets.split(" ")
    itt = Item.new
    itt.id = entity_id.to_i
    itt.type = entity_type
    itt.pos = [x.to_i,y.to_i]
    itt.info = [arg_1.to_i,arg_2.to_i,arg_3.to_i,arg_4.to_i]
    items << itt
  end
  items
end


def cube_distance(a, b)
  return ( (a[0] - b[0]).abs + (a[1] - b[1]).abs + (a[2] - b[2]).abs ) / 2
end
#p cube_distance([1,2,3],[5,7,8])

def offset_to_cube(a)
  x = a[0] - (a[1] - (a[1]&1)) / 2
  z = a[1]
  y = -x-z
  [x,y,z]
end

def offset_distance(a, b)
  ac = offset_to_cube(a)
  bc = offset_to_cube(b)
  return cube_distance(ac, bc)
end

#p offset_distance([1,2],[3,2])
