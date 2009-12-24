require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# How to test a module... Hmm...

describe ActsAsSvgGraph::TagHelper do
  
  before(:each) do
    @graphr = ActsAsSvgGraph::LineGraph.new
    @graphr.add('Apples',  [1, 2, 3, 4, 5, 6, 7],  'red')
    @graphr.add('Oranges', [1, 1, 2, 3, 5, 8, 13], 'blue')
    @graphr.labels = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun']
  end
  
  it "should clear the last point" do
    @graphr.last_point = [1,2]
    @graphr.clear_last_point
    @graphr.last_point.should be_nil
  end
  
  it 'should create an svg tag with the proper namespaces' do
    tag = @graphr.svg_tag { '' }
    tag.should have_tag('svg')
    tag.should match(/http:\/\/www\.w3\.org\/2000\/svg/)
    tag.should match(/http:\/\/www\.w3\.org\/1999\/xlink/)
    tag.should match(/0 0 480 320/)
  end
  
  it 'should render the title tag' do
    title = @graphr.draw_title('TITLE!')
    title.should have_tag('title', 'TITLE!')
    title.should have_tag('g')
    title.should have_tag('rect')
    title.should have_tag('text', 'TITLE!')
  end
  
  it 'should render a gradiant' do
    grad = @graphr.draw_vertical_gradiant('sbgradiant', '123,234,210', '255,255,255')
    grad.should have_tag('defs')
    grad.should have_tag('linearGradient[id=?]', 'sbgradiant')
    grad.should have_tag('stop[style=?]', "stop-color:rgb(123,234,210); stop-opacity:1")
    grad.should have_tag('stop[style=?]', "stop-color:rgb(255,255,255); stop-opacity:1")
  end
  
  it 'should make the y_gridline_helper' do
    @graphr.y_axis_lines = 5
    @graphr.y_gridline_helper
    @graphr.svg.should have_tag('path[d=?]', "M 0,0.0 h 380")   # i = 0
    @graphr.svg.should have_tag('path[d=?]', "M 0,260.0 h 380") # i = 4
  end
  
  it 'should make the x gridline helper' do
    @graphr.x_gridline_helper
    # x = i * 380/7 + 20
    @graphr.svg.should have_tag('path[d=?]', 'M 20.0,260 v 5')    # i = 0
    @graphr.svg.should have_tag('path[d=?]', 'M 345.714,260 v 5') # i = 6
  end
  
  it 'should draw the grid and legend' do
    @graphr.draw_grid_and_legend
    @graphr.svg.should have_tag("g[id='GridAndLegend']")
    @graphr.svg.should have_tag("g[style='stroke:none;']")
  end
  
  it 'should draw labels' do
    @graphr.draw_labels
    @graphr.svg.should have_tag("g[style='font-size: 10px']")
  end
  
  it 'should draw the grid' do
    @graphr.draw_grid
    @graphr.svg.should have_tag("g[stroke='black']")
    @graphr.svg.should have_tag("rect[x=0]")
    @graphr.svg.should have_tag("rect[y=0]")
    @graphr.svg.should have_tag("rect[width=380]")
    @graphr.svg.should have_tag("rect[height=260]")
    @graphr.svg.should have_tag("rect[fill='url(#sb_gradient)']")
    @graphr.svg.should have_tag("rect[stroke='black']")
  end
  
  it 'should draw the legend' do
    @graphr.draw_legend
    @graphr.svg.should have_tag("g[style='font-size: 10px']")
    @graphr.svg.should have_tag("g[transform='translate(390, 112)']")
    @graphr.svg.should have_tag("g[stroke='black']")
  end
  
  it 'should draw legend\'s background' do
    @graphr.draw_legend_background
    @graphr.svg.should have_tag('rect[x=0]')
    @graphr.svg.should have_tag('rect[y=0]')
    @graphr.svg.should have_tag('rect[width=70]')
    @graphr.svg.should have_tag('rect[height=35]')
    @graphr.svg.should have_tag("rect[fill='lightgray']")
  end
  
  describe 'drawing legend items' do
    before(:each) do
      @graphr = ActsAsSvgGraph::LineGraph.new
      #@graphr.add('Apples',  [1, 2, 3, 4, 5, 6, 7],  'red')
      #@graphr.add('Oranges', [1, 1, 2, 3, 5, 8, 13], 'blue')
      #@graphr.labels = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun']
      @color = 'red'
      @label = 'Apple'
      @graphr.draw_legend_item(@label, @color, 0)
    end
    
    it 'should draw the rectangle for the item in the legend' do
      @graphr.svg.should have_tag("rect[x=5]")
      @graphr.svg.should have_tag("rect[y=5]")
      @graphr.svg.should have_tag("rect[width=10]")
      @graphr.svg.should have_tag("rect[height=10]")
      @graphr.svg.should have_tag("rect[fill='#{@color}']")
    end
  
    it 'should draw the text for the item in the legend' do
      @graphr.svg.should have_tag("text[x=20]")
      @graphr.svg.should have_tag("text[y=13]")
      @graphr.svg.should have_tag("text[stroke='none']")
      @graphr.svg.should have_tag("text", @label)
    end
  end
  
  it 'should generate the connecting line' do
    @graphr.last_point = [5, 10]
    @graphr.connect_line(15, 20)
    @graphr.svg.should have_tag("path[d='M 5 10 L 15 20']")
  end
  
  describe 'g' do
    it 'should make a g' do
      @graphr.g {}
      @graphr.svg.should have_tag('g')
    end
    
    it 'should make a g with options' do
      @graphr.g(:fill => 'none') {}
      @graphr.svg.should have_tag("g[fill='none']")
    end
  end
  
  
end
