import strutils, sequtils

type
  Land = enum WOOD, LUMBERYARD, OPEN

  Area = ref object
    area: seq[seq[Land]]
    nextArea: seq[Land]
    width: int
    height: int
    period: int

proc waitForUser() {.inline.} =
  ## Helper for waiting for a key press
  echo "Press key..."
  discard readLine(stdin)

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

const neighbors = @[(-1,0), (-1,-1), (0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1)]


proc `$`(area: Area):string =
  result = ""
  var i = 0
  for a in area.area[area.area.high]:
    case a:
      of WOOD: result &= "|"
      of LUMBERYARD: result &= "#"
      of OPEN: result &= "."
    i.inc
    if i == area.width:
      result &= "\n"
      i = 0

proc parseInput(input: string): Area =
  new result
  result.area = @[]
  result.period = 0

  var tmp : seq[Land] = @[]

  for line in input.splitLines():
    var width = 0
    for c in line:
      if c == ' ':
        continue
      if c == '|':
        tmp.add(WOOD)
      elif c == '#':
        tmp.add(LUMBERYARD)
      elif c == '.':
        tmp.add(OPEN)
      width.inc

    if result.width > 0 and width != result.width:
      raise ValueError.newException(
        "Incompatible line length in map " & input)
    result.width = width
    inc result.height
  result.area.add(tmp)

proc getAt(area: Area, x, y: int): Land =
  result = area.area[area.area.high][x + y * area.width]

proc isOutside(x, y, width, height: int): bool =
  result = x >= width or x < 0 or y >= height or y < 0

proc getNext(area:Area, x,y: int): Land =
  let current = area.getAt(x,y)
  var surrounding : seq[Land] = @[]
  for n in neighbors:
    if not isOutside(x + n[0], y + n[1], area.width, area.height):
      surrounding.add(area.getAt(x + n[0], y + n[1]))
  
  result = current
  case current:
    of WOOD:
      if surrounding.filterIt(it == LUMBERYARD).len >= 3:
        result = LUMBERYARD
    of LUMBERYARD:
      if surrounding.filterIt(it ==  WOOD).len == 0 or  surrounding.filterIt(it == LUMBERYARD).len == 0:
        result = OPEN
    of OPEN:
      if surrounding.filterIt(it == WOOD).len >= 3:
        result = WOOD

proc tick(area:var Area) =
  area.nextArea = @[]
  var 
    x = 0
    y = 0
  for a in area.area[area.area.high]:
    area.nextArea.add(area.getNext(x, y))
    x.inc
    if x == area.width:
      x = 0
      y.inc
  let p = area.area.filterIt(it == area.nextArea)
  if p.len > 0:
    echo "found period"
    var i = 1
    for a in area.area:
      if a == p[0]:
        echo "Period start: ", i
        area.period = i
        break
      i.inc

  area.area.add(area.nextArea)

proc printScore(a: Area, i: int)=
  let w2 = a.area[i].filterIt(it == WOOD).len
  let l2 = a.area[i].filterIt(it == LUMBERYARD).len
  echo w2 * l2

proc iteratePart1(a:var Area, interactive: bool, goal: int)=
  var i = 0
  while i < goal and a.period == 0:
    echo i, " ", a.area.len
    if interactive:
      echo $a
    a.tick()
    i.inc
    if interactive:
      waitForUser()
    if i mod 1000 == 0:
      echo "Turn: ", i
      echo $a
  let w = a.area[a.area.high].filterIt(it == WOOD).len 
  let l = a.area[a.area.high].filterIt(it == LUMBERYARD).len
  echo "i: ", i, " = ", w, "*", l, " -> ", (w*l)
  if a.period > 0:
    let periodLength = a.area.len - a.period
    let left = (goal - a.period) mod periodLength
    echo "tic ", i
    echo "tic ", i
    echo "period lenght ", periodLength
    echo "period start ", a.period
    echo "end mod ", left
    echo "the one we should select ", a.period + left
    a.printScore(a.period + left - 1)
    a.printScore(a.period + left)
    a.printScore(a.period + left + 1)

proc solve1(fileName: string, interactive: bool) =
  let input = rFile(fileName)

  var a = parseInput(input)
  a.iteratePart1(interactive, 10)

proc solve2(fileName: string, interactive: bool) =
  let input = rFile(fileName)

  var a = parseInput(input)
  a.iteratePart1(interactive,1000000000)

solve1("test_input1.txt", false)

solve1("input.txt", false)
solve2("input.txt", false)
