# https://github.com/modularml/mojo/issues/1367


fn main():
    var s = String("a   complex  test case  with some  spaces")
    s = s.replace("  ", " ")
    print(s)
    # prints "a  complex test case with some  aces"
