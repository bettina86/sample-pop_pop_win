class TestGame {
  static void run() {
    group('Game', () {
      test('initial values', _testInitial);
      test('setFlag', _testSetFlag);
      test('cannot reveal flagged', _testCannotRevealFlagged);
      test('cannot flag revealed', _testCannotFlagRevealed);
      test('reveal zero', _testRevealZero);
      test('loss', _testLoss);
      test('win', _testWin);
      test('random winner', _testRandomField);
      test('good chord', _testGoodChord);
      test('bad chord', _testBadChord);
      test('no-op chord', _testNoopChord);
    });
  }

  static void _testBadChord() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    expect(g.minesLeft, equals(13));
    final startReveals = f.cols * f.rows - 13;
    expect(g.revealsLeft, equals(startReveals));
    expect(g.state, equals(GameState.notStarted));

    g.reveal(2, 3);
    g.setFlag(1, 2, true);
    g.setFlag(3, 2, true);

    expect(g.minesLeft, equals(11));
    expect(g.revealsLeft, equals(startReveals - 1));

    g.reveal(2, 3);
    expect(g.state, equals(GameState.lost));
  }

  // Adjacent flag count != square count
  // so nothing happens
  static void _testNoopChord() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    expect(g.minesLeft, equals(13));
    final startReveals = f.cols * f.rows - 13;
    expect(g.revealsLeft, equals(startReveals));
    expect(g.state, equals(GameState.notStarted));

    g.reveal(2, 3);
    g.setFlag(2, 2, true);

    expect(g.minesLeft, equals(12));
    expect(g.revealsLeft, equals(startReveals - 1));

    g.reveal(2, 3);
    expect(g.minesLeft, equals(12));
    expect(g.revealsLeft, equals(startReveals - 1));
  }

  static void _testGoodChord() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    expect(g.minesLeft, equals(13));
    final startReveals = f.cols * f.rows - 13;
    expect(g.revealsLeft, equals(startReveals));
    expect(g.state, equals(GameState.notStarted));

    g.reveal(2, 3);
    g.setFlag(2, 2, true);
    g.setFlag(3, 2, true);

    expect(g.minesLeft, equals(11));
    expect(g.revealsLeft, equals(startReveals - 1));

    g.reveal(2, 3);
    expect(g.minesLeft, equals(11));
    expect(g.revealsLeft, equals(startReveals - 11));
  }

  // Test 5 random fields five times
  static void _testRandomField() {
    final rnd = new Random();
    for(int i = 0; i < 5; i++) {
      final f = new Field();

      for(int j = 0; j < 5; j++) {
        final g = new Game(f);
        while(g.revealsLeft > 0) {
          final x = rnd.nextInt(f.cols);
          final y = rnd.nextInt(f.rows);
          if(g.getSquareState(x, y) == SquareState.hidden) {
            if(f.isMine(x, y)) {
              g.setFlag(x, y, true);
            } else if(!f.isMine(x, y)) {
              g.reveal(x, y);
            }
          }
        }
        expect(g.state == GameState.won);
      }
    }
  }

  static void _testRevealZero() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    expect(g.minesLeft, equals(13));
    final startReveals = f.cols * f.rows - 13;
    expect(g.revealsLeft, equals(startReveals));
    expect(g.state, equals(GameState.notStarted));

    g.reveal(5, 4);
    expect(g.revealsLeft, equals(startReveals - 10));
  }

  static void _testInitial() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    expect(g.minesLeft, equals(13));
    expect(g.revealsLeft, equals(f.cols * f.rows - 13));
    expect(g.state, equals(GameState.notStarted));

    for(int x = 0; x < f.cols; x++) {
      for(int y = 0; y < f.rows; y++) {
        expect(g.getSquareState(x,y), equals(SquareState.hidden));
      }
    }
  }

  static void _testSetFlag() {
    final g = new Game(TestField.getSampleField());

    expect(g.getSquareState(0,0), equals(SquareState.hidden));
    g.setFlag(0, 0, true);
    expect(g.getSquareState(0,0), equals(SquareState.flagged));
    expect(g.minesLeft, equals(12));
    expect(g.state, equals(GameState.started));
  }

  static void _testCannotRevealFlagged() {
    final g = new Game(TestField.getSampleField());

    expect(g.getSquareState(0,0), equals(SquareState.hidden));
    g.setFlag(0, 0, true);
    expect(g.getSquareState(0,0), equals(SquareState.flagged));
    expect(g.minesLeft, equals(12));
    expect(g.state, equals(GameState.started));

    expect(() => g.reveal(0,0), throwsException);
  }

  static void _testCannotFlagRevealed() {
    final g = new Game(TestField.getSampleField());

    expect(g.getSquareState(1,1), equals(SquareState.hidden));
    g.reveal(1, 1);
    expect(g.getSquareState(1,1), equals(SquareState.revealed));
    expect(g.state, equals(GameState.started));

    expect(() => g.setFlag(1,1,true), throwsException);
  }

  static void _testLoss() {
    final g = new Game(TestField.getSampleField());

    expect(g.getSquareState(0,0), equals(SquareState.hidden));
    g.reveal(0, 0);
    expect(g.state, equals(GameState.lost));
    expect(g.getSquareState(0,0), equals(SquareState.mine));
  }

  static void _testWin() {
    final f = TestField.getSampleField();
    final g = new Game(f);

    int minesLleft = f.mineCount;
    expect(g.revealsLeft, equals(f.cols * f.rows - 13));
    int revealsLeft = g.revealsLeft;
    for(int x = 0; x < f.cols; x++) {
      for(int y = 0; y < f.rows; y++) {
        if(f.isMine(x,y)) {
          g.setFlag(x, y, true);
          minesLleft--;
          expect(g.minesLeft, equals(minesLleft));
        } else if(g.getSquareState(x, y) == SquareState.hidden) {
          revealsLeft -= g.reveal(x, y);
          expect(revealsLeft, equals(g.revealsLeft));
        } else {
          expect(g.getSquareState(x,y), equals(SquareState.revealed));
        }
        expect(g.state, isNot(equals(GameState.notStarted)));
        expect(g.state, isNot(equals(GameState.lost)));
      }
    }

    expect(g.state, equals(GameState.won));
  }
}