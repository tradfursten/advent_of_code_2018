import strutils, sequtils, strscans, tables

type Game = tuple
  players: int
  lastMarble: int

type Player = tuple
  id: int
  points: int

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parseInput(input: string): seq[Game] =
  result = input.splitLines()
    .map(proc(line: string):Game =
      var A, B: int
      if line.scanf("$i players; last marble is worth $i points", A, B):
        result = (players: A, lastMarble: B)
     )

func getNextIndexOffset(lastIndex, length, offset: int): int =
  var newIndex = lastIndex + offset
  if newIndex < 0:
    newIndex = length - newIndex
  while newIndex > length:
    newIndex -= length
  result = newIndex

func getNextIndex(lastIndex, length: int): int =
  result = lastIndex.getNextIndexOffset(length, 2)

proc playGame(game: Game): Player =
  var marbles : seq[int]
  var currentMarble, lastIndex, points, player, highestScore : int
  var players = initTable[int, int]()
  marbles.add(0)
  lastIndex = 0
  for i in 1..game.lastMarble:
    player = i mod game.players
    if (i mod 23) == 0:
      lastIndex = lastIndex.getNextIndexOffset(marbles.len, -7)
      if not players.hasKey(player):
        players[player] = 0
      players[player] = players[player] + i + marbles[lastIndex]
      marbles.delete(lastIndex)
    else :
      lastIndex = lastIndex.getNextIndex(marbles.len)
      marbles.insert(i, lastIndex)

#  echo marbles

  highestScore = 0
  for p in players.pairs():
    if p[1] > highestScore:
      result = (p[0], p[1])
      highestScore = p[1]

type Marble = ref object
  value: int
  next: Marble
  prev: Marble

proc remove(marble: Marble): Marble =
  var next = marble.next
  next.prev = marble.prev
  marble.prev.next = next
  result = next

proc insert(marble: Marble, value: int): Marble =
  result = Marble(value: value)
  result.next = marble.next.next
  result.prev = marble.next
  result.prev.next = result
  result.next.prev = result

template loop(body: untyped): typed =
  while true:
    body

template until(cond: typed): typed =
  if cond: break

proc echoMarbles(marble: Marble) =
  var foundZero = false
  var start = marble
  while not foundZero:
    if start.value == 0:
      foundZero = true
    else:
      start = start.next

  var endMarble = start.prev
  var values : seq[int]
  loop:
    values.add(start.value)
    start = start.next
    until start.value == endMarble.value

  echo values.join(" ")




  

proc playGameTry2(game: Game): int =
  var current = Marble(value:0)
  var highestScore, winner:int
  current.next = current
  current.prev = current
  var players : seq[int]
  for p in 0..<game.players:
    players.add(0)
  var player = 0
  for i in 1..game.lastMarble:
    #current.echoMarbles()
    player = (player + 1) mod game.players
    if (i mod 23) == 0:
      var seventh = current.prev.prev.prev.prev.prev.prev.prev
      players[player] = players[player] + seventh.value + i
      #echo player , " gets points ", i, "+",seventh.value
      current = seventh.remove()
    else :
      current = current.insert(i)

#  echo marbles

  highestScore = 0
  #echo players
  for i in 0..<players.len:
    if players[i] > highestScore:
      highestScore = players[i]
      winner = i
  result = highestScore



let testInput = rFile("test_input1.txt")
let parsedTestInput = parseInput(testInput)
echo parsedTestInput.map(playGameTry2)


let input = rFile("input.txt")
let parsed = parseInput(input)
echo parsed.map(playGameTry2)
echo playGameTry2((parsed[0].players, parsed[0].lastMarble*100))

