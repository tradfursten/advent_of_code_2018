import strutils, sequtils, algorithm, strscans


type
  MyCustomError* = object of Exception

  Turn = enum left, straight, right

  Cart = ref object
    position: (int, int)
    lastTurn: Turn
    tick: int
    direction: char

  Game = ref object
    carts: seq[Cart]
    track: array[150, array[150, char]]
    size: (int, int)
    collision: (int,int)

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)


proc readMap(input:string): Game =
  new result
  var x,y =0
  var maxX, maxY: int
  for line in input.splitLines():
    x = 0
    echo line
    for c in line:
      case c:
        of 'v':
          result.carts.add(Cart(position:(x,y),lastTurn:right, direction:c))
          result.track[x][y] = '|'
        of '>':
          result.carts.add(Cart(position:(x,y),lastTurn:right, direction:c))
          result.track[x][y] = '-'
        of '<':
          result.carts.add(Cart(position:(x,y),lastTurn:right, direction:c))
          result.track[x][y] = '-'
        of '^':
          result.carts.add(Cart(position:(x,y),lastTurn:right, direction:c))
          result.track[x][y] = '|'
        else:
          result.track[x][y] = c
      x.inc
      maxX = max(maxX, x)
    y.inc
    maxY = max(maxY, y)
  result.size = (maxX, maxY)
  result.collision = (-1, -1)

proc `+=`(a: var (int,int), b:(int, int))=
  a[0]+=b[0]
  a[1]+=b[1]

proc `==`(a, b: (int, int)): bool =
  result = a[0] == b[0] and a[1] == b[1]

proc `$`(cart:Cart):string =
  result = $cart.direction

proc turn(cart:Cart, c: char) =
  var x, y: int
  case c:
    of '|', '-':
      discard
    of '/':
      case cart.direction:
        of 'v': cart.direction = '<'
        of '^': cart.direction = '>'
        of '<': cart.direction = 'v'
        of '>': cart.direction = '^'
        else:
          echo "ERROR direction", cart.direction
    of '\\':
      case cart.direction:
        of 'v': cart.direction = '>'
        of '^': cart.direction = '<'
        of '<': cart.direction = '^'
        of '>': cart.direction = 'v'
        else:
          echo "ERROR direction", cart.direction
    of '+':
      case cart.lastTurn:
        of left:
          cart.lastTurn = straight
        of straight:
          cart.lastTurn = right
          case cart.direction:
            of 'v': cart.direction = '<'
            of '^': cart.direction = '>'
            of '<': cart.direction = '^'
            of '>': cart.direction = 'v'
            else:
              echo "ERROR direction", cart.direction
        of right:
          case cart.direction:
            of 'v': cart.direction = '>'
            of '^': cart.direction = '<'
            of '<': cart.direction = 'v'
            of '>': cart.direction = '^'
            else:
              echo "ERROR direction", cart.direction
          cart.lastTurn = left
        else:
          discard
    else:
      raise newException(MyCustomError, ("Out side of track: " & $cart.position[0] & "," & $cart.position[1] & " " & cart.direction & " " & c))


proc at(game:Game, p:(int,int)):char =
  result = game.track[p[0]][p[1]]

proc direction(c: char): (int,int) =
  case c:
    of 'v':
      result = (0,1)
    of '^':
      result = (0,-1)
    of '<':
      result = (-1,0)
    of '>':
      result = (1,0)
    else:
      echo "ERROR direction", c

func cartAt(c:Cart, x,y:int):bool =
  c.position[0] == x and c.position[1] == y

proc tick(game:var Game) =
  let sortedCarts = game.carts.sorted(func(a,b:Cart): int =
    result = cmp(a.position[0], b.position[0])
    if result == 0:
      result = cmp(a.position[1], b.position[1])
  )
  for cart in sortedCarts:
    #echo cart.position, " + (", cart.direction, ") ", cart.direction.direction 
    cart.position += cart.direction.direction
    if game.carts.filter(func(c: Cart):bool = cartAt(c, cart.position[0], cart.position[1])).len > 1:
      echo "Collision at: ", cart.position[0], ",", cart.position[1]
      game.collision = cart.position
      game.carts.keepItIf(it.position[0] != cart.position[0] and it.position[1] != cart.position[1])
    cart.turn(game.at(cart.position))


proc `$`(game:Game):string=
  var carts : seq[Cart]
  for y in 0..<game.size[1]:
    for x in 0..<game.size[0]:
      carts = game.carts.filter(func(c: Cart): bool = cartAt(c, x, y))
      if carts.len == 1:
        stdout.write($carts[0])
      elif carts.len > 1:
        stdout.write('X')
      else:
        stdout.write(game.track[x][y])

    echo ""


proc `$`(a: (int, int)): string =
  result = $a[0] & "," & $a[1]



let testInput = rFile("test_input1.txt")
var testGame = readMap(testInput)

while testGame.collision == (-1, -1):
  tick(testGame)

echo testGame.collision


let input = readFile("input.txt")
var game = readMap(input)

while game.carts.len > 1:
  # echo $game
  tick(game)


echo $game.carts[0].position
