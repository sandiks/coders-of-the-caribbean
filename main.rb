
require_relative  'helper'
STDOUT.sync = true # DO NOT REMOVE

class Item
  attr_accessor :id, :type, :pos, :info
end

class Game
  attr_accessor :opp_pos_list, :ships, :barrels, :mines, :test

  def initialize()
    @opp_pos_list =  Hash.new {|hsh, key| hsh[key] = [] }
    @my_pos_list =  Hash.new {|hsh, key| hsh[key] = [] }
    @barrels = []
    @mines = []
    @test = true
  end



  #info: rotation, speed, barrels_count, my or opp

  def find_type(items, type)
    items.select{|tt| tt.type ==type}
  end

  def find_ships_by(ships, owner)
    ships.select{|tt| tt.info[3] ==owner}
  end

  def distance(start, dest)
    offset_distance(start, dest)
  end

  def calc_dist(objects, ship)
    objects.map { |bb| { id: bb.id, pos: bb.pos, amount: bb.info[0], dist: distance(bb.pos,ship.pos) } }.sort_by { |hh| hh[:dist] }
  end

  def calc_fire_pos(list, orient, dist=2)
    base = [1,1,2,2,3,3,4,4,5,5]
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

  def detect_near_mine(pp,orient,mine)
    case orient
    when 0 ; [0,1] if pp[0]+2 == mine[0]
      #when 1 ; [+1,0] if pp[0]+1 == mine[0] && pp[1]+2 == mine[1]
      #when 2 ; [+1,0]  if pp[0]-1 == mine[0] && pp[1]-1 == mine[1]
    when 3 ; [0,1] if pp[0]-2 == mine[0]
      #when 4 ; [-1,0]
      #when 5 ; [-1,0]
    else
      [0,0]
    end
  end

  def close_grouping_of3(a,b,c)
    distance(a,b)+distance(a,c)+distance(b,c)
  end

  def detect_most_value_barrel(dd)
    if dd.size>3
      b1 = dd[0][:pos]
      b2 = dd[1][:pos]
      b3 = dd[2][:pos]
      b4 = dd[3][:pos]

      d123 = close_grouping_of3(b1,b2,b3)
      d124 = close_grouping_of3(b1,b2,b4)
      d134 = close_grouping_of3(b1,b3,b4)
      d234 = close_grouping_of3(b2,b3,b4)
      most_valuable = [[d123,0], [d124,0], [d134,0], [d234,1]].sort_by { |el| el[0] }.first
      dd[most_valuable[1]]
    elsif dd.size>2
      b1 = dd[0][:pos]
      b2 = dd[1][:pos]
      b3 = dd[2][:pos]
      d12 = distance(b1,b2,)
      d13 = distance(b1,b3)
      d23 = distance(b2,b3)
      most_valuable = [[d12,0], [d13,0], [d23,1]].sort_by { |el| el[0] }.first
      dd[most_valuable[1]]
    else
      dd.first
    end
  end

  def run_turn(day=0)

    items =  @test ? read_game_state_file(day) : read_game_state

    @barrels = find_type(items,"BARREL")
    @mines= find_type(items,"MINE")
    @ships= find_type(items,"SHIP")

    my_ships = find_ships_by(@ships,1)
    enemy_ships = find_ships_by(@ships,0)

    my_ships.each{|my| @my_pos_list[my.id] << my.pos}
    enemy_ships.each{|opp| @opp_pos_list[opp.id] << opp.pos}

    my_ships.each do |my|
      turn_for_ship(my, enemy_ships)
    end

  end

  def turn_for_ship(my, opps)

    my_dist = calc_dist(@barrels, my)
    mines_dist = calc_dist(@mines, my)
    #opp_dist = calc_dist(brl, opp)

    near_opp = opps.sort_by{|opp| distance(opp.pos,my.pos)}.first
    battle_opp = opps.select{|opp| distance(opp.pos,my.pos)<6}.first

    if battle_opp
      battle_opp_distance = distance(battle_opp.pos,my.pos)
      need_fire =true if battle_opp_distance <6
    end

    next_point = detect_most_value_barrel(my_dist) #my_dist.first

    near_mine = mines_dist.first   #find near mine
    if near_mine && near_mine[:dist] <3
      log "eliminate MINE"
      #mpos = my.pos
      #orient = my.info[0]
      #offset = detect_near_mine(my.pos,orient,near_mine[:pos])

      mpos2 = near_mine[:pos] #[mpos[0]+offset[0], mpos[1]+offset[1]]
      printf("FIRE #{pcoord(mpos2)}\n")

    elsif need_fire
      log "exec FIRE"
 
      orient = battle_opp.info[0]
      ff = calc_fire_pos(@opp_pos_list[battle_opp.id], orient, battle_opp_distance)
      printf("FIRE #{pcoord(ff)}\n")

    elsif next_point
      log "move to BARREL"

      bb = next_point[:pos]
      printf("MOVE #{pcoord(bb)}\n")

    else
      log "follow enemy ship"

      orient = near_opp.info[0]
      ff = calc_fire_pos(@opp_pos_list[near_opp.id], orient)
      printf("MOVE #{pcoord(ff)}\n")

    end
  end

  def pcoord(bb); "#{bb[0]} #{bb[1]}"; end
  def log(text); p text if !@test; end
  

end

def run
  gg = Game.new
  gg.test = true
  arr=["FASTER","PORT"]

  if gg.test
  	p "run TEST"
    gg.run_turn(0)
    #gg.show_map
    #gg.run_turn(1)
  else
    ind =0
    loop do
      #printf("#{arr[ind]}\n")
      ind+=1

      gg.run_turn
    end
  end
end
run
