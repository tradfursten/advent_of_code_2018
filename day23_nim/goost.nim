type
  Vec3* = tuple
    x: int
    y: int
    z: int
  Bot* = tuple
    p: Vec3
    r: int
  #Map[T] = array[0..x_lim, array[0..y_lim, array[0..z_lim, T]]]

template `<`*(a, b: Bot): bool =
  a.r < b.r

template `+`*(a, b: Vec3): Vec3 = (x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)
template `-`*(a,b: Vec3): Vec3 = (x: a.x-b.x, y: a.y-b.y, z: a.z-b.z)

proc cross*(a,b: Vec3): Vec3 = (x:(a.y*b.z - a.z*b.y), y:(a.z*b.x - a.x*b.z), z:(a.x*b.y - a.y*b.x))
proc dot*(a,b: Vec3): int = a.x*b.x + a.y*b.y + a.z*b.z

proc top*(b: Bot): Vec3 = b.p + (x:0, y: b.r, z:0)
proc bottom*(b: Bot): Vec3 = b.p + (x:0, y: (-b.r), z:0)
proc left*(b: Bot): Vec3 = b.p + (x:b.r, y: 0, z:0)
proc right*(b: Bot): Vec3 = b.p + (x:(-b.r), y: 0, z:0)
proc near*(b: Bot): Vec3 = b.p + (x:0, y: 0, z: (-b.r))
proc far*(b: Bot): Vec3 = b.p + (x:0, y: 0, z:b.r)

proc distance*(a, b: Vec3): int =
  result = abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)

iterator corners*(b: Bot): Vec3 =
  yield(b.top)
  yield(b.bottom)
  yield(b.near)
  yield(b.far)
  yield(b.left)
  yield(b.right)