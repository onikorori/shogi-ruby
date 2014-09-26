module Shogi
  KIFU_NAME = Hash[%w(玉 飛 竜 角 馬 金 銀 成銀 桂 成桂 香 成香 歩 と).zip(%w(OU HI RY KA UM KI GI NG KE NK KY NY FU TO))]
  KIFU_NUM  = Hash[%w(１ ２ ３ ４ ５ ６ ７ ８ ９ 一 二 三 四 五 六 七 八 九 1 2 3 4 5 6 7 8 9).zip((1..9).to_a * 3)]

  name = '(' + KIFU_NAME.keys.join('|') + ')'
  num = '([' + KIFU_NUM.keys.join('') + '])'
  KIFU_MOVEMENT_REGEX0 = /([▲△\+-])?#{num}#{num}#{name}([右左])?([上寄引直])?(成|不成|打)?/o
  KIFU_MOVEMENT_REGEX1 = /([▲△\+-])?同#{name}([右左])?([上寄引直])?(成|不成|打)?/o

  class Game
    attr_accessor :default_format
    attr_reader :turn
    def initialize(format=:csa, turn="+")
      raise ArgumentError, "Undefined format: #{format}" unless /\Acsa\z/ =~ format
      raise ArgumentError, "Invalid turn: #{turn}" unless /\A[+-]\z/ =~ turn

      @default_format = format
      @board = Shogi::Board.new(@default_format)
      @turn = turn
      @kifu = []
    end

    def to_csa
      @board.to_csa << turn << "\n"
    end

    def move(movement_lines, format=@default_format)
      movement_lines.each_line do |movement|
        movement.chomp!
        case format
        when :csa
        when :kifu
          movement = kifu_to_csa_movement(movement)
          format = :csa
        else raise Board::FormatError, 'unknown format'
        end
        @board.move(movement, format)
        @kifu << movement
        @turn = (@turn == "+") ? "-" : "+"
      end
      self
    end

    def kifulog
      @kifu
    end

    def load_csa(csa)
      @board.set_from_csa(csa)
    end

    def kifu_to_csa_movement(movement)
      case movement
      when KIFU_MOVEMENT_REGEX0
        o, x, y, k, d0, d1, n = $~.to_a.drop(1)
        dx = KIFU_NUM[x]
        dy = KIFU_NUM[y]
      when KIFU_MOVEMENT_REGEX1
        o, k, d0, d1, n = $~.to_a.drop(1)
        raise Board::MoveError, "last kifu is not csa format: #{@kifu.last}" unless @kifu.last =~ /[\+-]\d\d(\d)(\d)/
        dx = $1.to_i
        dy = $2.to_i
      else raise Board::FormatError, movement
      end

      case o
      when '▲' then o = '+'
      when '△' then o = '-'
      when nil  then o = @turn
      end

      name = KIFU_NAME[k]

      if n == '打'
        ms = [[0, 0]]
      elsif name == 'FU'
        ms = [[dx, o == '+' ? dy + 1 : dy - 1]]
      else
        # 歩以外は面倒なので総当たりで探す
        ms = []
        t = "#{o}#{name}"
        position = @board.instance_variable_get(:@position)
        position.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            next if cell != t
            sx, sy = 9 - x, y + 1
            m = "#{o}#{sx}#{sy}#{dx}#{dy}#{name}"
            ms << [sx, sy] if @board.movable_by_csa?(m)
          end
        end
      end

      if 1 < ms.size
        case o
        when '+'
          if name == 'RY' or name == 'UM'
            ms.sort! { |a, b| a[0] <=> b[0] }
            case d0
            when '右' then ms = [ms[0]]
            when '左' then ms = [ms[1]]
            end
          else
            case d0
            when '右' then ms.keep_if { |sx, sy| sx < dx }
            when '左' then ms.keep_if { |sx, sy| dx < sx }
            end
            case d1
            when '上' then ms.keep_if { |sx, sy| dy < sy }
            when '直' then ms.keep_if { |sx, sy| dy < sy and dx == sx }
            when '寄' then ms.keep_if { |sx, sy| dy == sy }
            when '引' then ms.keep_if { |sx, sy| sy < dy }
            end
          end
        when '-'
          if name == 'RY' or name == 'UM'
            ms.sort! { |a, b| a[0] <=> b[0] }
            case d0
            when '右' then ms = [ms[1]]
            when '左' then ms = [ms[0]]
            end
          else
            case d0
            when '右' then ms.keep_if { |sx, sy| sx > dx }
            when '左' then ms.keep_if { |sx, sy| dx > sx }
            end
            case d1
            when '上' then ms.keep_if { |sx, sy| dy > sy }
            when '直' then ms.keep_if { |sx, sy| dy > sy and dx == sx }
            when '寄' then ms.keep_if { |sx, sy| dy == sy }
            when '引' then ms.keep_if { |sx, sy| sy > dy }
            end
          end
        end
      end

      if n == '成'
        case k
        when '角' then k = '馬'
        when '飛' then k = '竜'
        when '歩' then k = 'と'
        else k = "成#{k}"
        end
      end

      raise Board::CodingError, 'multiple candidates remained' if ms.size > 1
      raise Board::MoveError, movement if ms.size == 0
      sx, sy = ms[0]
      "#{o}#{sx}#{sy}#{dx}#{dy}#{KIFU_NAME[k]}"
    end

    def kifu
      @kifu.join("\n") << "\n"
    end

    def show(format=@default_format)
      $stdout.puts __send__("to_#{format}")
    end

    def show_all(format=@default_format)
      show
      $stdout.puts kifu
    end

    def at(num_of_moves)
      Shogi::Game.new.move(@kifu[0, num_of_moves].join("\n") << "\n")
    end
  end
end
