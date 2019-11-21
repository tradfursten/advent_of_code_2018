import strutils, os, sequtils, math, tables, re

type Direction = enum N, E, S, W

type
  Node = ref object
    id: int
    value: seq[char]
    edges: seq[Edge]

  Edge = ref object
    value: Direction
    origin: Node
    target: Node

type Traverse = tuple[end_id: int, value: int, path: string]

proc getDirection(c: char): Direction =
  result = parseEnum[Direction](""&c)


proc buildDFA(input: string): Node =
  var nodeId = 0
  result = Node()
  result.id = nodeId
  result.value = newSeq[char]()
  nodeId.inc()
  var last: Node
  last = result
  var forkOrigins = newSeq[Node]()
  var forks: seq[seq[Node]]
  forks = newSeq[seq[Node]]()
  for c in input[1..<(input.len-1)]:
    if c in ['N', 'E', 'W', 'S']:
      last.value.add(c)
    elif c == '(':
      forkOrigins.add(last)
      var current = Node()
      current.id = nodeId
      last.edges.add(Edge(origin:last, target: current))
      last = current
      
      nodeId.inc()
      forks.add(newSeq[Node]())
      forks[forks.len-1].add(last)
    elif c == ')':
      var current = Node()
      current.id = nodeId
      nodeId.inc()

      last.edges.add(Edge(origin:last, target: current))
      last = current
      for f in forks[forks.len-1]:
        f.edges.add(Edge(origin: f, target: last))

      forks.delete(forks.len-1)
      forkOrigins.delete(forkOrigins.len - 1)
    elif c == '|':
      last = forkOrigins[forkOrigins.len - 1]
      var current = Node()
      current.id = nodeId
      nodeId.inc()
      last.edges.add(Edge(origin:last, target: current))
      last = current
    
   # echo "Last"
   # echo last.id, ' ', last.value
   # echo "Forks"
   # for f in forks:
   #   echo "One fork"
   #   for n in f:
   #     echo n.id, ' ', n.value
   # echo "Fork origin"
   # for n in forkOrigins:
   #   echo n.id, ' ', n.value





proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

var input = paramStr(1).rFile()

echo input

var generatedStrings: Table[int, seq[string]]
generatedStrings = initTable[int, seq[string]]()

var visitedNodes: Table[int, tuple[v: string, r: int]]
visitedNodes = initTable[int, tuple[v:string, r:int]]()

proc traverse(n: Node, level: int, steps: int, path: string): tuple[e: int, v: string, r: int] =
  if visitedNodes.hasKey(n.id):
    #echo "Get from cache:", n.id
    return (n.id, visitedNodes[n.id].v, visitedNodes[n.id].r)
  else:
    var childValue = newSeq[tuple[e: int, v:string, r:int]]()
    var l = level
    if n.edges.len > 1:
      l.inc()
    #echo n.id, ' ', n.value, ' ', n.edges.len, " [", n.edges.mapIt(it.target.id).join(", "), ']'
    for e in n.edges:
      childValue.add(e.target.traverse(l, steps + 1, path & $n.value.join("")))

    #echo n.id, ' ', n.value, ' ', childValue

    var p = ""
    var bestPaths = initTable[int, string]()
    var r: int
    for c in childValue:
      if not bestPaths.hasKey(c.e):
        bestPaths[c.r] = c.v
        r = c.r
        p = c.v
      elif bestPaths[c.r].len > c.v.len:
        bestPaths[c.r] = c.v
        r = c.r
        p = c.v
      if r != c.r and c.v.len > p.len:
        p = c.v
        r = c.r
  
    if p.len == 0:
      r = n.id
    visitedNodes[n.id] = (v: n.value.join("") & p, r: r)
    echo n.id, " root:",r, " best paths ", n.value.join(""),'+',p, ' ', bestPaths, ' ', visitedNodes[n.id]
          
    return (n.id, visitedNodes[n.id].v, visitedNodes[n.id].r)


var dfa = input.buildDFA()
var longest = dfa.traverse(0, 0, "")
echo visitedNodes
echo longest.v.len, ' ', longest.v
