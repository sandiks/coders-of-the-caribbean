#require_relative  'helper'

STDOUT.sync = true # DO NOT REMOVE

class Game
  attr_accessor :opp_pos_list, :ships, :barrels, :mines, :test

  def initialize()
    @opp_pos_list = []
    @barrels = []
    @mines = []
    @test = true
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
  #info: rotation, speed, barrels_count, my or opp

  def find_type(items, type)
    items.select{|tt| tt[:type] ==type}
  end
  def find_ships_by(ships, owner)
    ships.select{|tt| tt[:info][3] ==owner}
  end
  def distance(a,b)
    #return 100 if a.nil? or b.nil?
    Math.sqrt( (a[0] - b[0])**2 + (a[1] - b[1])**2 ).ceil
  end

  def calc_dist(objects, ship)
    objects.map { |bb| { id: bb[:id], amount: bb[:info][0], dist: distance(bb[:pos],ship[:pos]) } }.sort_by { |hh| hh[:dist] }
  end

  def calc_fire_pos(list, orient)
    
    pp = list.last #last opp position
    prev = list[-2] if list.size>1
    return pp if pp == prev 

    case orient
    when 0 ; [pp[0]+2,pp[1]]
    when 1 ; [pp[0]+1,pp[1]-1]
    when 2 ; [pp[0]-1,pp[1]-1]
    when 3 ; [pp[0]-2,pp[1]]
    when 4 ; [pp[0]-1,pp[1]+1]
    when 5 ; [pp[0]+1,pp[1]+1]
    else
      pp
    end
  end

  def skirt_mine(pp,orient,mine)
    case orient
    when 0 ; [pp[0],pp[1]+1] if pp[0]+2 == mine[0]
    when 1 ; [pp[0]+1,pp[1]-1] if pp[0]+1 == mine[0] && pp[1] == mine[1]-2
    when 2 ; [pp[0]-1,pp[1]-1]
    when 3 ; [pp[0]-2,pp[1]]
    when 4 ; [pp[0]-1,pp[1]+1]
    when 5 ; [pp[0]+1,pp[1]+1]
    else
      pos
    end
  end

  def run_turn(day=0)

    items =  @test ? read_game_state_file(day) : read_game_state

    @barrels = find_type(items,"BARREL")
    barrels_hash = Hash[@barrels.map { |tt|  [tt[:id],tt] }]

    @mines= find_type(items,"MINE")

    @ships= find_type(items,"SHIP")

    my = find_ships_by(@ships,1).first
    p opp = find_ships_by(@ships,0).first

    @opp_pos_list<<opp[:pos]

    my_dist = calc_dist(@barrels, my)
    mines_dist = calc_dist(@mines, my)
    #opp_dist = calc_dist(brl, opp)

    next_point = my_dist.first

    dd=distance(opp[:pos],my[:pos])
    need_fire = dd<4 if opp[:pos] && my[:pos]

    if need_fire
      orient = opp[:info][0]
      ff = calc_fire_pos(@opp_pos_list, orient)
      printf("FIRE #{ff[0]} #{ff[1]}\n")

    elsif next_point
      min_id = next_point[:id]
      pp = barrels_hash[min_id][:pos]
      printf("MOVE #{pp[0]} #{pp[1]}\n")

    else
      orient = opp[:info][0]
      ff = calc_fire_pos(@opp_pos_list, orient)
      printf("MOVE #{ff[0]} #{ff[1]}\n")

    end
  end
end

def run
  gg = Game.new
  gg.test = false

  if gg.test
    gg.run_turn(0)
    gg.run_turn(1)
  else
    loop do
      gg.run_turn
    end
  end
end
run
