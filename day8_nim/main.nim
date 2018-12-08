import strutils, sequtils

type
  Node = ref object
    children: seq[Node]
    metadata: seq[int]

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc readNode(numbers:seq[int], index: int): (Node, int) =
  var i = index
  let nrChildren = numbers[i]
  i.inc
  let nrMetadata = numbers[i]
  i.inc

  var children : seq[Node]

  for c in 0..<nrChildren:
    let response = readNode(numbers, i)
    children.add(response[0])
    i = response[1]

  var metadata : seq[int]
  for m in 0..<nrMetadata:
    metadata.add(numbers[i])
    i.inc

  result = (Node(children:children, metadata:metadata), i)
    
proc parseInput(input: string): Node =
  let numbers = input.split(" ").map(parseInt)
  let rootNode = readNode(numbers, 0)
  result = rootNode[0]

proc solve1(node: Node): int =
  var childMeta = 0
  if node.children.len > 0:
    childMeta = node.children.map(solve1).foldl(a + b)
  result = node.metadata.foldl(a + b) + childMeta

proc solve2(node: Node): int =
  if node.children.len == 0:
    return node.metadata.foldl(a + b)
  else :
    var childMeta = node.children.map(solve2)
    result = node.metadata.mapIt(it - 1).map(proc(i: int): int =
        result = 0
        if i < childMeta.len:
          result = childMeta[i]
      ).foldl(a + b)




let testInput = rFile("test_input1.txt")
let parsedTestInput = parseInput(testInput)
echo solve1(parsedTestInput)
echo solve2(parsedTestInput)


let input = rFile("input.txt")
let parsed = parseInput(input)
echo solve1(parsed)
echo solve2(parsed)
