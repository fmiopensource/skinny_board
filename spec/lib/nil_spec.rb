require File.dirname(__FILE__) + '/../spec_helper'

describe NilClass do
  describe 'empty?' do
    it 'should return true' do
      x = nil
      x.empty?.should be_true
    end
  end
end