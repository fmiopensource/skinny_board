# To change this template, choose Tools | Templates
# and open the template in the editor.

class Hash
  def method_missing(method, *params)
    self[method.to_sym] || self["#{method}"]
  end

  def diff(h2)
    self.dup.delete_if { |k, v| h2[k] == v }.merge(h2.dup.delete_if { |k, v| self.has_key?(k) })
  end

end
