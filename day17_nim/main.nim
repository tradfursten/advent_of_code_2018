import strutils, sequtils, re


type Point = tuple[x, y: int]

type Map = seq[string]



proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parse(input: string): Map =
  var clay = newSeq[Point]()
  
  for l in input.splitLines():
    var x_range = l.findAll(re"(?<=x=)([0-9.]+)")[0].split(".").filterIt(it != "").map(parseInt)
    var y_range = l.findAll(re"(?<=y=)([0-9.]+)")[0].split(".").filterIt(it != "").map(parseInt)
    if x_range.len > 1:
      for x in x_range[0].. x_range[1]:
        if y_range.len > 1:
          for y in y_range[0].. y_range[1]:
            clay.add((x: x, y: y))
        else:
          clay.add((x:x, y: y_range[0]))
    else:
      if y_range.len > 1:
        for y in y_range[0].. y_range[1]:
          clay.add((x: x_range[0], y: y))
      else:
        clay.add((x:x_range[0], y: y_range[0]))

  var start_x = clay.mapIt(it.x).min - 1
  var end_x = clay.mapIt(it.x).max; 
  var width = end_x - start_x + 2
  var height = clay.mapIt(it.y).max + 1

  result = newSeqWith(height, '.'.repeat(width))
  for c in clay:
    result[c.y][c.x-start_x] = '#'
  result[0][500-start_x] = '+'
  result[1][500-start_x] = '|'

proc print(map:Map):void=
  for s in map:
    echo s

proc tick(map:var Map):int=
  #for y in 0..<map.len:
  var y = 0
  var i = 0
  while y < map.len:
    var stills: tuple[inc_y: bool, new_x: int]
    stills = (true, -1)
    #echo y, ' ', map[y]
    var x = 0
    #for x in 0..<map[0].len:
    var inc_y = true
    while x < map[0].len:
      if map[y][x] == '|' and y < map.len-1:
        if map[y+1][x] in ['.', '|']:
          map[y+1][x] = '|'
        elif map[y][x-1] == '.':
          inc_y = false
          map[y][x-1] = '|'
        elif map[y][x+1] == '.':
          inc_y = false
          map[y][x+1] = '|'
      x.inc()
    
    var bounds = map[y].findBounds(re"#\|+#")
    if bounds[0] >= 0 and map[y+1][bounds[0]+1..<bounds[1]].allIt(it in ['~', '#']):
      map[y][bounds[0]+1..<bounds[1]] = '~'.repeat(bounds[1] - bounds[0] - 1)
      inc_y = false

    if inc_y:
      y.inc()
    else:
      y.dec()
    i.inc()
  
    


var testInput = rFile("test_input1.txt").parse()
var y = 0
testInput.print()
y = testInput.tick()
testInput.print()

#echo testInput.mapIt(it.filterIt(it == '|' or it == '~').len).foldl(a + b)

var input = rFile("input.txt").parse()
y = input.tick()
input.print()
echo input.mapIt(it.filterIt(it == '|' or it == '~').len).foldl(a + b)

for y in 0..<input.len:
  if input[y].contains('#'):
    let total = input[y..<input.len].join()
    let drops = total.filterIt(it in ['|']).len
    let still = total.filterIt(it in ['~']).len
    echo "Part 1: ", drops + still
    echo "Part 2: ", still
    break
#var t2 = rFile("testinput2 copy.txt").parse()
#y = t2.tick()
#t2.print()

