import strutils, sequtils, strscans, terminal, os, re, rdstdin, math


func calculateGridPoint(x, y, serialNumber: int): int =
  let rackId = x + 10
  let powerLevel = int(floor(((((y * rackId) + serialNumber) * rackId) mod 1000)/100) - 5)
  result = powerLevel


proc buildGrid(serialNumber: int): array[300, array[300, (int, int)]] =
  var ar : array[300, array[300, (int, int)]]
  var sumPower, powerLevel: int
  for x in 0..<300:
    for y in 0..<300:
      powerLevel = calculateGridPoint(x, y, serialNumber)
      if x > 0 and y > 0:
        sumPower = powerLevel + ar[x][y-1][1] + ar[x-1][y][1] - ar[x-1][y-1][1]
      if x == 0 and y > 0:
        sumPower = powerLevel + ar[x][y-1][1]
      if y == 0 and x > 0:
        sumPower = powerLevel + ar[x-1][y][1]
      ar[x][y] = (powerLevel, sumPower)
  result = ar

proc solve1(grid: array[300, array[300, (int, int)]]): string =
  var maxPower, maxX, maxY, currentPower: int
  for x in 3..<300:
    for y in 3..<300:
      currentPower = grid[x][y][1] - grid[x-3][y][1] - grid[x][y-3][1] + grid[x-3][y-3][1]
      if currentPower > maxPower:
        maxPower = currentPower
        maxX = x - 2
        maxY = y - 2
  result = $maxX & "," & $maxY

proc solve2(grid: array[300, array[300, (int, int)]]): string =
  var maxPower, currentPower, maxX, maxY, size: int
  for s in 1..300:
    for x in s..<300:
      for y in s..<300:
        currentPower = grid[x][y][1] - grid[x-s][y][1]-grid[x][y-s][1]+grid[x-s][y-s][1]
        if currentPower > maxPower:
          maxPower = currentPower
          maxX = x - size +1
          maxY = y - size + 1
          size = s
  result = $maxX & "," & $maxY & "," & $size


let testGrid = buildGrid(18)
echo solve1(testGrid)
echo solve2(testGrid)

let testGrid2 = buildGrid(42)
echo solve1(testGrid2)
echo solve2(testGrid2)

let grid = buildGrid(7989)
echo solve1(grid)
echo solve2(grid)
