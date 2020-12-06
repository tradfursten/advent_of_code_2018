import strformat, sequtils, strutils, tables, algorithm

type
  AttackType = enum fire, cold, slashing, bludgeoning, radiation
  Race = enum Immune, Infection
  FightingGroup = ref object
    nr: int
    race: Race
    units: int
    hp: int
    attack: int
    initiative: int
    attackType: AttackType
    weaknes: seq[AttackType]
    immune: seq[AttackType]

  Batle = tuple
    fightingParts: seq[FightingGroup]
    immune: seq[FightingGroup]
    infection: seq[FightingGroup]

proc `$`(fg: FightingGroup): string = 
  result = $fg.race & " " & $fg.nr & " units: " & $fg.units & " hp: " & $fg.hp & 
    " attack: " & $fg.attack & " " & $fg.attackType & 
    " weak: " & fg.weaknes.join(", ") & " immune: " & fg.immune.join(", ")

proc effectivePower(g: FightingGroup): int =
  g.units * g.attack

proc calculateDamage(attacker, defender: FightingGroup): int =
  result = attacker.effectivePower
  if attacker.attackType in defender.weaknes:
    result = result * 2
  elif attacker.attackType in defender.immune:
    result = 0

proc targetSelectorOrder(a, b: FightingGroup): int =
  #result = b.initiative - a.initiative
  if a.effectivePower > b.effectivePower: 1
  elif a.effectivePower == b.effectivePower:
    if a.initiative > b.initiative: 1
    else: -1
  else: -1

proc attackOrder(a, b: FightingGroup): int = b.initiative - a.initiative

proc unitKillCount(attacker, defender: FightingGroup): int = 
  result = attacker.calculateDamage(defender) div defender.hp

proc dealDamage(attacker, defender: FightingGroup) =
  if defender.units > 0:
    defender.units = max(defender.units - attacker.unitKillCount(defender), 0)


proc isFight(battle: Batle): bool =
  result = false
  var 
    immune = false
    infection = false
  for fg in battle.fightingParts:
    
    if fg.race == Infection and fg.units > 0: infection = true
    elif fg.race == Immune and fg.units > 0: immune = true

    if immune and infection: return true
  result = immune and infection
    


proc parseInput(): Batle =
  var
    group: FightingGroup
  
  group = FightingGroup()
  group.nr = 1
  group.units = 17
  group.hp = 5390
  group.attack = 4507
  group.initiative = 2
  group.weaknes.add radiation
  group.weaknes.add bludgeoning
  group.attackType = fire
  group.race = Immune
  result.fightingParts.add(group)
  result.immune.add(group)

  group = FightingGroup()
  group.nr = 2
  group.units = 989
  group.hp = 1274
  group.attack = 25
  group.initiative = 3
  group.weaknes.add bludgeoning
  group.weaknes.add slashing
  group.immune.add fire
  group.attackType = slashing
  group.race = Immune
  result.fightingParts.add(group)
  result.immune.add(group)


  group = FightingGroup()
  group.nr = 1
  group.units = 801
  group.hp = 4706
  group.attack = 116
  group.initiative = 1
  group.weaknes.add radiation
  group.attackType = bludgeoning
  group.race = Infection
  result.fightingParts.add(group)
  result.infection.add(group)

  group = FightingGroup()
  group.nr = 2
  group.units = 4485
  group.hp = 2961
  group.attack = 12
  group.initiative = 4
  group.weaknes.add fire
  group.weaknes.add cold
  group.immune.add radiation
  group.attackType = slashing
  group.race = Infection
  result.fightingParts.add(group)
  result.infection.add(group)

proc tick(battle: Batle) =
  var targets = initTable[int, FightingGroup]()
  var selected


  let order = battle.fightingParts.sorted(targetSelectorOrder)

  echo "target order"
  for o in order:
    echo o

  echo "\nTarget selection order"
  var
    currentBestOpponent: FightingGroup
    currentMaxDamage= 0
    i = 0
  for fg in order:
    if fg.units == 0:
      continue
    currentMaxDamage = 0
    for opponent in battle.fightingParts:
      if fg.race != opponent.race and opponent.units > 0:
        let damage = fg.calculateDamage(opponent)
        echo fmt"{fg.race} {fg.nr} would deal {opponent.nr} {damage}"
        if damage > currentMaxDamage:
          currentMaxDamage = damage
          currentBestOpponent = opponent
        elif damage == currentMaxDamage:
          if currentBestOpponent.effectivePower < opponent.effectivePower:
            currentBestOpponent = opponent
    
    if currentMaxDamage > 0:
      targets[i] = currentBestOpponent
    i.inc
  
  echo "\nAttack phase:"
  for i, attacker in order:
    echo attacker
    if attacker.units > 0 and targets.hasKey(i):
      let v = targets[i]
      if v.units > 0:
        echo fmt"{attacker.race} {attacker.nr} attacks {v.nr} damage {attacker.calculateDamage(v)} killing {attacker.unitKillCount(v)}"
        attacker.dealDamage(v)


proc printGroups(battle: Batle)=
  echo "\nImmune system"
  for im in battle.immune:
    echo im

  echo "\nInfection"
  for inf in battle.infection:
    echo inf

var battle = parseInput()


echo "FIIIIIIGHT!!!!"
while battle.isFight: 
  battle.printGroups
  battle.tick()

battle.printGroups


echo battle.fightingParts
      .filterIt(it.units > 0)
      .mapIt(it.units)
      .foldl(a + b)










