import strutils, sequtils, deques, tables, algorithm, sets, queues, heapqueue

type
  Kind = enum elf, goblin

  Position = tuple
    x, y:int

  Creature = ref object
    position: Position
    hp: int
    ap: int
    kind: Kind

  Game = ref object
    tiles: seq[int]
    creatures: seq[Creature]
    size: (int, int)
    over: bool

const readOrder = @[(0,-1), (-1,0), (1,0), (0,1)]

proc waitForUser() {.inline.} =
  ## Helper for waiting for a key press
  echo "Press key..."
  discard readLine(stdin)

proc `$`(creature: Creature): string =
  result = "(" & $creature.kind & " " & $creature.position.x & "," & $creature.position.y & ")"

proc `+=`(position:var Position, a: (int, int))=
  position.x += a[0]
  position.y += a[1]

proc `+`(position: Position, a: (int, int)): Position =
  result = (position.x + a[0], position.y + a[1])

proc `-`(a, b: Position): Position =
  result = (x: a.x - b.x, y: a.y - b.y)

proc `<`(a, b: Position): bool =
  result = if a.y < b.y: true
    elif a.y == b.y: a.x < b.x
    else: false

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc manhattan(a, b: Position): int =
  result = abs(a.x - b.x) + abs(a.y - b.y)

proc neighbors(game: Game, p: Position): seq[Position] =
  result = @[]
  for x in readOrder:
    let n = p + x
    result.add(n)


proc createGame(input:string): Game =
  new result
  var x,y: int
  var tiles: seq[int]
  for l in input.splitLines():
    x = 0
    for c in l:
      case c:
        of '#':
          tiles.add 1
        of '.':
          tiles.add 0
        of 'E':
          tiles.add 0
          result.creatures.add(Creature(position: (x,y), hp: 200, ap: 3, kind: elf))
        of 'G':
          result.creatures.add(Creature(position: (x,y), hp: 200, ap: 3, kind: goblin))
          tiles.add 0
        else:
          echo "error"

      x.inc

    y.inc
  result.tiles = tiles
  result.size = (x, y)


proc isEnemy(position: Position, game: Game, kind: Kind): bool=
  result = game.creatures.anyIt(it.position == position and it.kind != kind and it.hp > 0)

proc isAccessible(game: Game, p: Position): bool =
  result = game.tiles[p.x + p.y * game.size[1]] == 0 and not game.creatures.anyIt(it.position == p and it.hp > 0)

proc isAccessible(game: Game, p: Position, kind: Kind): bool =
  result = game.tiles[p.x + p.y * game.size[1]] == 0 and not game.creatures.anyIt(it.position == p and it.kind == kind and it.hp > 0)

proc getPath(meta: Table[Position, (Position, (int, int))], p: Position): seq[(int, int)] =
  var state = p
  var path: seq[(int, int)]
  while meta.hasKey(state):
    let action = meta[state][1]
    state = meta[state][0]
    path.add(action)
  return path.reversed()

proc findPathBFS(game: Game, creature: Creature, goal: Position): seq[Position] =
  var openSet = initQueue[Position]()
  var closedSet = initSet[Position]()
  var meta = initTable[Position, Position]()
  var path : seq[(int, int)]
  openSet.add(creature.position)
  while openSet.len > 0:
    var current = openSet.pop()
    if current == goal:
      result = @[current]
      while meta.hasKey(current):
        current = meta[current]
        result = @[current].concat(result)
      return result[1..result.high]

    for n in game.neighbors(current):
      if not game.isAccessible(n) or closedSet.contains(n):
        continue
      if not openSet.contains(n):
        if meta.hasKeyOrPut(n, current):
          meta[n] = current
        openSet.enqueue(n)

    closedSet.incl(current)

proc findTarget(creature: Creature, game: Game): seq[(int, int)] =
  var check = initDeque[seq[Position]]()
  var checkNext : seq[seq[Position]]
  var visited = initSet[Position]()
  var meta = initTable[Position, (Position, (int, int))]()
  var next:Position
  var paths : seq[seq[(int, int)]]
  let neighbors = @[(-1,0), (0,-1), (0,1), (1,0)]
  check.addLast(@[creature.position])
  visited.incl(creature.position)
  while check.len > 0:
    checkNext = @[]
    while check.len > 0:
      var path = check.popLast()
      let c = path[path.len - 1]
      if c.isEnemy(game, creature.kind):
        return path
      for d in neighbors:
        next = c + d
        if game.isAccessible(next, creature.kind) and not visited.contains(next):
          visited.incl(next)
          checkNext.add(concat(path,@[next]))
      checkNext.sort(func(a, b:seq[Position]):int =
        let la = a[a.len-1]
        let lb = b[b.len-1]
        result = cmp(la.y, lb.y)
        if result == 0:
          result = cmp(la.x, lb.x)
      )
      check.clear()
      for i in checkNext:
        check.addLast(i)
  result = @[]


proc attack(game:Game, c: Creature, kind: Kind):bool =
  var enemy = game.creatures.filterIt(it.position == c.position and it.kind != kind)
  if enemy.len > 0:
    enemy[0].hp -= c.ap
    return true
  return false

proc getEnemy(game: Game, p: Position, c: Creature): seq[Creature] =
  result = game.creatures.filter(proc(it: Creature):bool =
    result = it.position == p and it.kind != c.kind and it.hp>0
  )


proc takeDamage(enemy:var Creature, creature: Creature)=
  enemy.hp -= creature.ap

proc getTarget(creature: Creature, game: Game): Creature =
  result = nil
  for n in game.neighbors(creature.position):
    var target = game.getEnemy(n, creature)
    if target.len > 0  and (result == nil or result.hp > target[0].hp):
      result = target[0]

proc findPath(game:Game, start, goal: Position): seq[Position] =
  var
    openSet = initSet[Position]()
    closedSet = initSet[Position]()
    cameFrom = initTable[Position, Position]()
    gScore = initTable[Position, int]()
    fScore = initTable[Position, int]()

  proc heuristic(a, b: Position): int {.closure.} =
    result =
      if cameFrom.hasKey(a):
        manhattan(cameFrom[a], b)
      else:
        manhattan(a, b)

  openSet.incl(start)
  gScore.add(start, 0)
  fScore.add(start, heuristic(start, goal))

  while openSet.len > 0:
    var
      smallestfScore = -1
      next = newHeapQueue[Position]()
    for p in openSet.items:
      if smallestfScore == -1 or fScore[p] < smallestfScore:
        smallestfScore = fScore[p]
    for p in openSet.items:
      if fScore[p] == smallestfScore:
        next.push(p)

    
    var current = next.pop()


    if current == goal:
      result = @[current]
      while cameFrom.hasKey(current):
        current = cameFrom[current]
        result = @[current].concat(result)
      return result[1..result.high]

    openSet.excl(current)
    closedSet.incl(current)
    
    for n in game.neighbors(current):
      if not game.isAccessible(n) or closedSet.contains(n):
        continue

      var tempgScore = gScore[current] + 1

      if not openSet.contains(n):
        openSet.incl(n)
      elif tempgScore >= gScore[n]:
        continue
      if cameFrom.hasKeyOrPut(n, current):
        cameFrom[n] = current
      let tempfScore = tempgScore + heuristic(n, goal)
      if gScore.hasKeyOrPut(n, tempgScore):
        gScore[n] = tempgScore
      if fScore.hasKeyOrPut(n, tempfScore):
        fScore[n] = tempfScore

proc getNextMove(game: Game, creature: Creature): Position =
  var destinations : seq[Position] = @[]
  for c in game.creatures:
    if c.hp > 0 and c.kind != creature.kind:
      let qn = game.neighbors(c.position)
      #echo "Searching target for ", creature, " now looking at ", c, " neighbours ", qn
      for pos in qn:
        if game.isAccessible(pos):
          #echo "    neighbour of ", c, ": ", pos
          destinations.add(pos)

  if destinations.len == 0:
    return (0,0)

  var
    paths = initTable[Position, seq[Position]]()
    reachable: seq[Position] = @[]

  for p in destinations:
    let path = game.findPathBFS(creature, p)
    #let path = game.findPath(creature.position, p)
    if path.len > 0:
      paths.add(p, path)
      reachable.add(p)

  if reachable.len == 0:
    return (0,0)

  var
    smallest: int
    nearest = newHeapQueue[Position]()

  for r in reachable:
    if smallest == 0 or paths[r].len <= smallest:
      smallest = paths[r].len
  for r in reachable:
    if paths[r].len == smallest:
      #echo $creature, " Found shortest path: ", paths[r]
      nearest.push(r)

  #for n in 0 ..< nearest.len:
  #  echo "==>Nearest: ", nearest[n], " in ", smallest, " steps"

  let p = nearest.pop()
  #echo $creature, " coosen path: ", p
  var path = paths[p]
  result = (path[0] - creature.position)

func compareCreatures(a,b: Creature): int =
  result = cmp(a.position.y, b.position.y)
  if result == 0:
    result = cmp(a.position.x, b.position.x)

func canMove(creature: Creature, game: Game): bool =
  let east = creature.position + (0,1)
  let south = creature.position + (1,0)
  let west = creature.position + (0, -1)
  let north = creature.position + (-1,0)
  return game.isAccessible(east) or game.isAccessible(south) or game.isAccessible(west) or game.isAccessible(north)
    
proc tic(game: Game, debug: bool)=
  let sortedCreatures = game.creatures.filterIt(it.hp > 0)
    #.sorted(compareCreatures, order = SortOrder.Descending)
    .sorted(compareCreatures)
  for c in sortedCreatures:
    if debug:
      echo $c, "s turn"
    if c.hp > 0:
      if game.creatures.filterIt(it.kind != c.kind and it.hp > 0).len == 0:
        if debug:
          echo "No more enemies of " & $c.kind
        game.over = true
        return
      var target = c.getTarget(game)
      if target != nil:
        if debug:
          echo "Can attack directly"
        target.takeDamage(c)
      else:
        let m = game.getNextMove(c)
        if debug:
          echo "Move ", m
        c.position += m
        target = c.getTarget(game)
        if target != nil:
          if debug:
            echo "Can attack after move"
          target.takeDamage(c)
  if debug and false:
    waitForUser()
        

proc `==`(a, b: (int, int)): bool =
  return a[0] == b[0] and a[1] == b[1]

proc `$`(creatures: seq[Creature]): string =
  result = creatures.mapIt("(" & $it.kind & " " & $it.position[0] & "," & $it.position[1] & ", hp:" & $it.hp & ")").join(",")

proc `$`(game: Game): string =
  result = ""
  var x, y: int
  for i, tile in game.tiles:
    if i != 0 and i mod game.size[0] == 0:
      result &= "\t" & game.creatures
        .filterIt(it.hp > 0 and it.position.y == y)
        .sorted(func(a,b: Creature): int = cmp(a.position.x, b.position.x))
        .mapIt($(if it.kind == goblin: "G(" else: "E(") & $it.hp & ")")
        .join(", ")
      result &= '\n'
      result &= (if tile == 0: '.' else: '#')
      y.inc
      x = 1
    else:
      let creatures = game.creatures.filterIt(it.position == (x,y) and it.hp > 0)
      if creatures.len > 0 and creatures[0].kind == elf:
        result &= 'E'
      if creatures.len > 0 and creatures[0].kind == goblin:
        result &= 'G'
      if creatures.len == 0:
        result &= (if tile == 0: '.' else: '#')
      x.inc

proc testStuff(name: string, debug: bool) =
  let testInput = rFile(name)
  let testGame = createGame(testInput)
  var i = 0
  while not testGame.over:
    if debug:
      echo "Turn: ", i
      echo $testGame
    testGame.tic(debug)
    i.inc

  i.dec
  if debug:
    echo $testGame.creatures
  echo $testGame
  echo $i, "*",  testGame.creatures.filterIt(it.hp > 0).mapIt(it.hp).foldl(a + b)
  echo i * testGame.creatures.filterIt(it.hp > 0).mapIt(it.hp).foldl(a + b)

proc newFight(game:var Game, elfPower: int, debug: bool): int=
  for c in game.creatures:
    if c.kind == elf:
      c.ap = elfPower
  var i = 0
  while not game.over:
    if debug:
      echo "Turn: ", i
      echo $game
    game.tic(debug)
    i.inc
  i.dec
  result = i

proc elfVictory(game: Game): bool =
  result = game.creatures.filterIt(it.kind != elf and it.hp > 0).len == 0 and
    game.creatures.filterIt(it.kind == elf and it.hp <= 0).len == 0


proc fightToTheDeath(name: string, debug: bool) =
  let testInput = rFile(name)
  var game = createGame(testInput)
  var i: int
  var elfPower = 4
  while not game.elfVictory():
    i = game.newFight(elfPower, debug)
    echo "Elf power: ", elfPower, " turns: ", i
    if not game.elfVictory():
      echo $game
      game = createGame(testInput)
      elfPower.inc
  if debug:
    echo $game.creatures
  echo $game
  echo $i, "*",  game.creatures.filterIt(it.hp > 0).mapIt(it.hp).foldl(a + b)
  echo i * game.creatures.filterIt(it.hp > 0).mapIt(it.hp).foldl(a + b)



#testStuff("test_input1.txt", false)
#echo "\n*****************\n"
#testStuff("test2.txt", false)
#echo "\n*****************\n"
#testStuff("test3.txt", false)
#echo "\n*****************\n"
#testStuff("test4.txt", false)
#echo "\n*****************\n"
#testStuff("test5.txt", false)
#echo "\n*****************\n"
#testStuff("test6.txt", false)
#echo "\n*****************\n"

#testStuff("input.txt", true)
#
fightToTheDeath("input.txt", false)


