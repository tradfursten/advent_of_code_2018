var v = 10551305

var sum = 0


# after looking at how the registers changed i saw that the program whas calculating the factors of the large number


for i in 1..v:
  if v mod i == 0:
    sum.inc(i)

echo sum