import strutils, sequtils, re, tables, sets, algorithm


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc sumDay(a: string, b:int):int =
  if a == "X":
    result = b + 1
  else:
    result = b

proc parseInput(input:string): (Table[(string, string), array[60, string]], seq[(string, seq[int])]) =
  var table = initTable[(string, string), array[60, string]]()
  var days = newSeq[(string, seq[int])]()
  let lines = input.splitLines()
  var guardMatches: array[3, string]
  let guardPattern = re"\[\d{4}-(\d{2}-\d{2}) \d{2}:(\d{2})\] Guard #(\d+) begins shift"
  var done = false
  var guardDone = false
  var i = 0
  var j = 0
  while not done:
    if match(lines[i], guardPattern, guardMatches,0):
      var dayArray: array[60, string]
      var daySeq = newSeq[int]()
      j = i + 1
      var asleepAt = 0
      guardDone = false
      while not guardDone:
        if j == lines.len:
          i = j
          break
        if lines[j].contains("falls asleep") or lines[j].contains("wakes up"):
          let time = lines[j].findAll(re(r"\d+"))[4].parseInt()
          if lines[j].contains("falls asleep"):
            asleepAt = time
          else:
            for k in asleepAt..<time:
              dayArray[k] = "X"
              daySeq.add(k)
          j.inc
        else:
          guardDone = true
          i = j
      table[($guardMatches[0],$guardMatches[2])] = dayArray
      days.add(($guardMatches[2], daySeq))
    else:
      i.inc
    if i >= lines.len:
      done = true
  result = (table, days)


proc findGuardThatSleepsMost(days: seq[(string, seq[int])]): (int, int, int) =
  var sleepyHead = ""
  let guard = days.map(func(day: (string, seq[int])):string = day[0])
    .deduplicate()
    .map(func(guard: (string)): (int, int, int) =
      let totalMinutes = days
        .filter(func(day: (string, seq[int])): bool = day[0] == guard)
        .map(func(d: (string, seq[int])): seq[int] = d[1])
        .foldl(a.concat(b))

      var mostMinute = 0
      if totalMinutes.len > 0:
        mostMinute = totalMinutes
          .deduplicate()
          .map(func(current: int): (int, int) = (-totalMinutes.count(current), current))
          .sorted(cmp)[0][1]
      result = (totalMinutes.len, parseInt(guard), mostMinute))
    .sorted(cmp, order = SortOrder.Descending)[0]

  result = guard


proc findGuardThatSleepsMostOnTheSameMinute(days: seq[(string, seq[int])]): (int, int, int) =
  var sleepyHead = ""
  let guard = days.map(func(day: (string, seq[int])):string = day[0])
    .deduplicate()
    .map(func(guard: (string)): (int, int, int) =
      let totalMinutes = days
        .filter(func(day: (string, seq[int])): bool = day[0] == guard)
        .map(func(d: (string, seq[int])): seq[int] = d[1])
        .foldl(a.concat(b))

      var mostMinute = (0,0)
      if totalMinutes.len > 0:
        mostMinute = totalMinutes
          .deduplicate()
          .map(func(current: int): (int, int) = (-totalMinutes.count(current), current))
          .sorted(cmp)[0]
        
      result = (-mostMinute[0], parseInt(guard), mostMinute[1]))
    .sorted(cmp, order = SortOrder.Descending)[0]

  result = guard


let testInput = rFile("test_input1.txt")
let parsedTest = parseInput(testInput)
let guard = findGuardThatSleepsMost(parsedTest[1])
echo $guard & " = " & $(guard[1] * guard[2])
let guard2 = findGuardThatSleepsMostOnTheSameMinute(parsedTest[1])
echo $guard2 & " = " & $(guard2[1] * guard2[2])


let input = rFile("input.txt")
let parsed = parseInput(input)
let realGuard = findGuardThatSleepsMost(parsed[1])
echo $realGuard & " = " & $(realGuard[1] * realGuard[2])
let realGuard2 = findGuardThatSleepsMostOnTheSameMinute(parsed[1])
echo $realGuard2 & " = " & $(realGuard2[1] * realGuard2[2])
