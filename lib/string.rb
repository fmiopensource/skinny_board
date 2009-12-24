class String
  
  # Simple convenience method to wrap the RedCloth gem's methods
  def to_html
    RedCloth.new(self).to_html
  end
  
  def scramble!
    replace(self.random_string)
  end

  def random_string
    c = %w( b c d f g h j k l m n p qu r s t v w x z ) +
    %w( ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr )
    v = %w( a e i o u y )
    f, r = true, ''

    6.times do
      r << ( f ? c[ rand * c.size ] : v[ rand * v.size ] )
      f = !f
    end

    2.times do
      r << ( rand( 9 ) + 1 ).to_s
    end
    r
  end

  # Converts the string to a boolean
  # "true".to_bool #=> true
  # "false".to_bool #=> false
  def to_bool
    return false if self.downcase == "false"
    return true
  end
end
