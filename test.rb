def distance(a,b)
  #return 100 if a.nil? or b.nil?
  Math.sqrt( (a[0] - b[0])**2 + (a[1] - b[1])**2 ).ceil
end

def close_grouping_of3(a,b,c)
  distance(a,b)+distance(a,c)+distance(b,c)
end

def detect_most_value_barrel(dd)
  if dd.size>3
    b1 = dd[0]
    b2 = dd[1]
    b3 = dd[2]
    b4 = dd[3]

    d123 = close_grouping_of3(b1,b2,b3)
    d124 = close_grouping_of3(b1,b2,b4)
    d134 = close_grouping_of3(b1,b3,b4)
    d234 = close_grouping_of3(b2,b3,b4)
    most_valuable = [[d123,0], [d124,0], [d134,0], [d234,1]].sort_by { |el| el[0] }
    dd[most_valuable.first[1]]
  elsif dd.size>2
    b1 = dd[0]
    b2 = dd[1]
    b3 = dd[2]
    d12 = distance(b1,b2,)
    d13 = distance(b1,b3)
    d23 = distance(b2,b3)
    p most_valuable = [[d12,0], [d13,0], [d23,1]].sort_by { |el| el[0] }
    dd[most_valuable.first[1]]
  else
    dd.first
  end
end
def show_map
  rows = []
  for i in 0..20
    row='-'*22
    row= ' '+row if i%2 ==1
    rows[i] = row
  end
  barrels.each do |bb|
    pp = bb.pos
    rows[pp[1]][pp[0]]='B'
  end
  puts rows
end

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

def calc_fire_pos(list, orient, dist=2)
  base = [1,1,2,2,3,3,4,4]
  even_d1 = [0]+base   #четное
  odd_d1 =  base
  even_d2 = base
  odd_d2 =  [0]+base
  even_d4 = base
  odd_d4 =  [0]+base
  even_d5 = [0]+base
  odd_d5 =  base

  pp = list.last #last opp position
  prev = list[-2] if list.size>1
  return pp if pp == prev

  x = pp[0]
  offset = case orient
  when 0 ; [dist,0]
  when 1 ; x.even? ? [even_d1[dist-1],-dist] : [odd_d1[dist-1],-dist]
  when 2 ; x.even? ? [-even_d2[dist-1],-dist] : [-odd_d2[dist-1],-dist]
  when 3 ; [-dist,0]
  when 4 ; x.even? ? [-even_d4[dist-1],dist] : [-odd_d4[dist-1],dist]
  when 5 ; x.even? ? [even_d5[dist-1],dist] : [odd_d5[dist-1],dist]
  else
    [0,0]
  end
  [pp[0]+offset[0],pp[1]+offset[1]]

end


def test_calc_fire_pos
  list = [[3,9],[4,8],[5,7]]
  p calc_fire_pos(list,1,5)
end
#test_calc_fire_pos

def test_detect_most_value_barrel
  arr = [[0,0],[2,0],[5,1]]
  #p  detect_most_value_barrel(arr)
end

aa=6
p aa&1