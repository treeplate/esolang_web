void main() {
  int i = 0;
  while (i < 10) {
    i++;
    print('>$i');
    switch(i) {
        case 2:
          print('2 break');
          break;
        case 5:
          print('5 continue');
          continue;
    }
    print('<$i');
  }
  print('the end');
}