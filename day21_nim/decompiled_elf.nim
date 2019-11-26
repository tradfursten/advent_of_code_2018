var
  a = 0
  b = 0
  c = 0
  d = 0
  e = 0
  f = 0

f = 123                 # 0
f = f or 456            # 1
if f == 72: f = 1       # 2
else: f = 0
b = f + a               # 3 Jump ?
b = 0                   # 4 GOTO 1
f = 0                   # 5
e = f or 65536          # 6
f = 3935295             # 7
f = e and 255           # 8
f = f + c               # 9
f = f and 16777215      # 10
f = f * 65899           # 11
f = f and 16777215      # 12
if 256 > e: c = 1       # 13
else: c = 0
b = b + c               # 14 Jump
b = b + 1               # 15 Skip next
b = 27                  # 16 GOTO 27
c = 0                   # 17
d = c + 1               # 18
d = c * 256             # 19
if d > e: d = 1         # 20
else: d = 0
b = b + d               # 21
b = b + 1               # 22 Skip next
b = 25                  # 23 GOTO 26
c = c + 1               # 24
b = 17                  # 25 GOTO 18
e = c                   # 26
b = 7                   # 27 GOTO 8
if f == a: c = 1        # 28
else: c = 0
b = b + c               # 29               
b = 5                   # 30 GOTO 6

