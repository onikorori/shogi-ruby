require "shogi"
require "shogi/game"

class TestGameKifu <  Test::Unit::TestCase
  def setup
    @game = Shogi::Game.new
  end

  def test_movements_1
    @game.move('▲７６歩', :kifu)
    @game.move('△３四歩', :kifu)
    @game.move('+22角成', :kifu)
    assert_equal @game.kifulog, %w{+7776FU -3334FU +8822UM}
  end

  def test_movements_2
    @game.move('76歩', :kifu)
    @game.move('34歩', :kifu)
    @game.move('22角', :kifu)
    @game.move('同銀', :kifu)
    @game.move('55角打', :kifu)
    assert_equal @game.kifulog, %w{+7776FU -3334FU +8822KA -3122GI +0055KA}
  end

  def _(board_num, movement, csa)
    send("setup_test_board#{board_num}")
    @game.move(movement, :kifu)
    assert_equal @game.kifulog.last, csa
  end

  def setup_test_board0
    csa = <<EOS
P1 *  *  *  *  *  * +KI *  * 
P2 *  * +KI *  *  *  *  *  * 
P3+KI *  *  *  * +KI *  *  * 
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  * +KI *  *  * 
P6 *  *  *  * +KI *  *  *  * 
P7 *  * +GI *  *  *  * +GI * 
P8 *  *  *  *  *  *  *  *  * 
P9 * +GI *  *  * +GI *  *  * 
P+00GI00KE
P-
EOS
    @game.load_csa(csa)
  end

  def test_movement_agaru0
    _ 0, '+82金上', '+9382KI'
  end

  def test_movement_agaru1
    _ 0, '+32金上', '+4332KI'
  end

  def test_movement_agaru2
    _ 0, '+55金上', '+5655KI'
  end

  def test_movement_agaru3
    _ 0, '+88銀上', '+8988GI'
  end

  def test_movement_agaru4
    _ 0, '+38銀上', '+4938GI'
  end

  def test_movement_yoru1
    _ 0, '+82金寄', '+7282KI'
  end

  def test_movement_yoru2
    _ 0, '+55金寄', '+4555KI'
  end

  def test_movement_hiku0
    _ 0, '+32金引', '+3132KI'
  end

  def test_movement_hiku1
    _ 0, '+88銀引', '+7788GI'
  end
  
  def test_movement_hiku2
    _ 0, '+38銀引', '+2738GI'
  end

  def setup_test_board1
    csa = <<EOS
P1 *  *  *  *  *  *  *  *  * 
P2+KI * +KI *  *  * +KI * +KI
P3 *  *  *  *  *  *  *  *  * 
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  * +GI * +GI *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7 *  *  *  *  *  *  *  *  * 
P8 *  *  *  *  *  *  *  *  * 
P9 * +KI+KI *  *  * +GI+GI * 
P+00GI00KE
P-
EOS
    @game.load_csa(csa)
  end

  def test_movement_migi0
    _ 1, '+81金右', '+7281KI'
  end

  def test_movement_migi1
    _ 1, '+22金右', '+1222KI'
  end

  def test_movement_migi2
    _ 1, '+56銀右', '+4556GI'
  end

  def test_movement_migi3
    _ 1, '+38銀右', '+2938GI'
  end

  def test_movement_hidari0
    _ 1, '+81金左', '+9281KI'
  end

  def test_movement_hidari1
    _ 1, '+22金左', '+3222KI'
  end

  def test_movement_hidari2
    _ 1, '+56銀左', '+6556GI'
  end

  def test_movement_hidari3
    _ 1, '+78金左', '+8978KI'
  end

  def test_movement_sugu0
    _ 1, '+78金直', '+7978KI'
  end

  def test_movement_sugu1
    _ 1, '+38銀直', '+3938GI'
  end

  def setup_test_board2
    csa = <<EOS
P1 *  *  *  *  *  *  *  *  * 
P2 *  *  *  *  *  *  *  *  * 
P3 *  *  * +KI+KI+KI *  *  * 
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7 * +TO *  *  *  * +GI * +GI
P8+TO *  *  *  *  *  *  *  * 
P9+TO+TO+TO *  *  * +GI+GI * 
P+00GI00KE
P-
EOS
    @game.load_csa(csa)
  end

  def test_movement_m_hidari0
    _ 2, '+52金左', '+6352KI'
  end

  def test_movement_m_sugu0
    _ 2, '+52金直', '+5352KI'
  end

  def test_movement_m_migi0
    _ 2, '+52金右', '+4352KI'
  end

  def test_movement_m_migi1
    _ 2, '+88と右', '+7988TO'
  end

  def test_movement_m_sugu1
    _ 2, '+88と直', '+8988TO'
  end

  def test_movement_m_hidariagaru1
    _ 2, '+88と左上', '+9988TO'
  end

  def test_movement_m_yoru1
    _ 2, '+88と寄', '+9888TO'
  end

  def test_movement_m_hiku1
    _ 2, '+88と引', '+8788TO'
  end

  def test_movement_m_sugu2
    _ 2, '+28銀直', '+2928GI'
  end

  def test_movement_m_migi2
    _ 2, '+28銀右', '+1728GI'
  end

  def test_movement_m_hidariagaru2
    _ 2, '+28銀左上', '+3928GI'
  end

  def test_movement_m_hidarihiku2
    _ 2, '+28銀左引', '+3728GI'
  end

  def setup_test_board3
    csa = <<EOS
P1 *  *  *  *  *  *  *  *  * 
P2 *  *  *  *  *  *  *  *  * 
P3 *  *  *  *  *  *  *  *  * 
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7 *  *  *  *  *  *  *  *  * 
P8 *  *  *  *  *  *  *  *  * 
P9+RY+RY *  *  *  *  *  *  * 
P+
P-
EOS
    @game.load_csa(csa)
  end

  def test_movement_2_hidari
    _ 3, '+88竜左', '+9988RY'
  end

  def test_movement_2_migi
    _ 3, '+88竜右', '+8988RY'
  end

end


