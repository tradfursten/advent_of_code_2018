import strutils, sequtils, strscans, algorithm


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)


proc parseInput(input: string): seq[(string, string)] =
  var A, B: string
  var r : seq[(string, string)]
  for line in input.splitLines():
    if line.scanf("Step $w must be finished before step $w can begin.", A, B):
      r.add((A, B))
  result = r

proc isAvailable(s: string, d: seq[(string, string)], processed: seq[string]): bool =
  let missesRequirements = d.filter(func(i: (string, string)): bool =
    i[1] == s and not processed.any(func(p:string):bool =
      p == i[0]
    )
  )
  result = missesRequirements.len == 0

proc solve1(input : seq[(string, string)]): string =
  var processed: seq[string]
  var available: seq[string]
  var data = input
  var processing : string
  while data.len > 0:
    for d in data:
      if not available.contains(d[0]) and not processed.contains(d[0]) and isAvailable(d[0], data, processed):
        available.add(d[0])
      if not available.contains(d[1]) and processed.contains(d[0]) and not processed.contains(d[1]) and isAvailable(d[1], data, processed):
        available.add(d[1])
    available.sort(func(a: string, b: string):int = cmp(a, b), order = SortOrder.Descending)
    processing = available.pop
    processed.add(processing)
    data.keepItIf(it[1]!=processing)
   # echo "processing ", processing
   # echo "processed ", processed
   # echo "available ", available
   # echo "data ", data
    result = processed.join("")

proc isAvailablePart2(item: (string, string), processing: seq[(string, int, int)], processed, available:seq[string], data: seq[(string, string)]): (bool, string) =
    if not processing.any(func(i:(string, int, int)):bool = i[0] == item[0]) and not available.contains(item[0]) and not processed.contains(item[0]) and isAvailable(item[0], data, processed):
      return (true, item[0])
    if not processing.any(func(i:(string, int, int)):bool = i[0] == item[1]) and not available.contains(item[1]) and processed.contains(item[0]) and not processed.contains(item[1]) and isAvailable(item[1], data, processed):
      return (true, item[1])
    result = (false, "")


proc solve2(input: seq[(string, string)], nrWorkers: int, baseTime: int ): int=
  var processed: seq[string]
  var available: seq[string]
  var data = input
  var processing : seq[(string,int,int)]
  var workers : seq[int]
  for i in 1.. nrWorkers:
    workers.add(i)
  var worker, doneAt: int
  var item: string
  var time = 0
  var a :(bool, string)
  while data.len > 0:
    for d in data:
      a = isAvailablePart2(d, processing, processed, available, data)
      if a[0]:
        available.add(a[1])
    available.sort(func(a: string, b: string):int = cmp(a, b), order = SortOrder.Descending)
    while available.len > 0 and workers.len > 0:
      worker = workers.pop()
      item = available.pop()
      processing.add((item, worker, time+baseTime+ord(item[0])-ord('A')))


    for p in processing.filterIt(it[2] == time):
      processed.add(p[0])
      data.keepItIf(it[1]!=p[0])
      workers.add(p[1])

    processing.keepItIf(it[2] != time)

    time.inc

  result = time
  

let testInput = rFile("test_input1.txt")
let testParsed =  parseInput(testInput)
echo solve1(testParsed)
echo solve2(testParsed, 2, 0)


let input = rFile("input.txt")
let parsed = parseInput(input)
echo solve1(parsed)
echo solve2(parsed, 5, 60)
