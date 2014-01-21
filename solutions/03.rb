module Graphics
  class Canvas
    attr_reader  :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @canvas = 1.upto(height).map { 1.upto(width).map { false } }
    end

    def set_pixel(x, y)
      @canvas[y][x] = true
    end

    def pixel_at?(x, y)
      @canvas[y][x]
    end

    def draw(shape)
      shape.points.each { |point| set_pixel(point.x, point.y) }
    end

    def render_as(renderer)
      renderer.render(self)
    end

    def render_image(pixels, delimiter)
      @canvas.map do |pixel_row|
        pixel_row.map do |pixel|
          pixels[pixel]
        end.join
      end.join(delimiter)
    end

  end

  class Point
    include Comparable

    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    alias_method :eq?, :==
    def ==(other)
      @x == other.x and @y == other.y
    end

    def <=>(other)
      comparison = self.x <=> other.x

      if comparison == 0
        return self.y <=> other.y
      else
        return comparison
      end
    end

    def hash
      @x.hash - @y.hash
    end

    def points
      [self]
    end
  end

  class Line
    attr_reader :from, :to

    def initialize(first_point, second_point)
      @from, @to = [first_point,second_point].sort
    end

    alias_method :eq?, :==
    def ==(other)
      [@from, @to].sort == [other.from, other.to].sort
    end

    def hash
      @from.hash + @to.hash
    end

    def points
      line_points(*bresenham_points)
    end

    private

    def bresenham_points()
      from_x, from_y, to_x, to_y = @from.x, @from.y, @to.x, @to.y
      if steep_line?
        from_x, from_y, to_x, to_y = from_y, from_x, to_y, to_x
      end

      if from_x > to_x
        from_x, to_x = to_x, from_x,
        from_y, to_y = to_y, from_y
      end

      [Point.new(from_x, from_y), Point.new(to_x, to_y)]
    end

    def line_points(from_point, to_point)
      error = (delta(from_point.x, to_point.x) / 2).to_i
      y = from_point.y
      ordinate_step = from_point.y < to_point.y ? 1 : -1
      generate_points(error, y, ordinate_step, from_point, to_point)
    end

    def generate_points(error, y, ordinate_step, from_point, to_point)
      (from_point.x..to_point.x).each_with_object([]) do |x, points|
        points << (steep_line? ? Point.new(y, x) : Point.new(x, y))
        error -= delta(from_point.y, to_point.y)
        if error < 0
          y += ordinate_step
          error += delta(from_point.x, to_point.x)
        end
      end
    end

    def steep_line?
      (@to.y-@from.y).abs > (@to.x-@from.x).abs
    end

    def delta(from_coordinate, to_coordinate)
      (from_coordinate - to_coordinate).abs
    end
  end

  class Rectangle
    attr_reader :left, :right, :top_left, :top_right, :bottom_left, :bottom_right

    def initialize(first, second)
      @left = Point.new([first.x,second.x].min,[first.y,second.y].min)
      @right = Point.new([first.x,second.x].max,[first.y,second.y].max)
      @top_left, @bottom_right = @left, @right
      @bottom_left = Point.new(@left.x,@right.y)
      @top_right = Point.new(@right.x,@left.y)
    end

    alias_method :eq?, :==
    def ==(other)
      @left == other.left and @right == other.right
    end

    def hash
      @left.hash + @right.hash
    end

    def points
      [
        [@top_left,     @top_right],
        [@top_right,    @bottom_right],
        [@bottom_right, @bottom_left],
        [@bottom_left,  @top_left]
      ].map { |a, b| Line.new(a,b).points }.flatten
    end
  end

  module Renderers
    class Ascii
      def self.render(canvas)
        hash = {true => '@'.freeze, false => '-'.freeze}
        canvas.render_image(hash, '\n'.freeze)
      end
    end

    class Html

      LAYOUT_HEADER = <<-HEADER.freeze
        <!DOCTYPE html>
        <html>
        <head>
          <title>Rendered Canvas</title>
          <style type="text/css">
            .canvas {
              font-size: 1px;
              line-height: 1px;
            }
            .canvas * {
              display: inline-block;
              width: 10px;
              height: 10px;
              border-radius: 5px;
            }
            .canvas i {
              background-color: #eee;
            }
            .canvas b {
              background-color: #333;
            }
          </style>
        </head>
        <body>
          <div class="canvas">
      HEADER

      LAYOUT_FOOTER = %(</div> </body> </html>)

      def self.render(canvas)
        hash = {true => '<b></b>'.freeze, false => '<i></i>'.freeze}
        self.new.add_layout canvas.render_image(hash, '<br/>'.freeze)
      end

      def add_layout(drawing)
        LAYOUT_HEADER + drawing + LAYOUT_FOOTER
      end
    end
  end
end