require File.dirname(__FILE__) + '/../spec_helper'

describe Array do
  describe 'total' do
    it 'should calculate the total properly' do
      a = [5, 4, 3, 2, 1]
      a.total.should == 15
    end
    
    it 'should return 0 for an empty array' do
      a = Array.new
      a.empty?.should be_true
      a.total.should == 0
      a.empty?.should be_true
    end
  end
  
  describe 'mean' do
    it 'should calculate the mean properly' do
      a = [5, 4, 3, 2, 1]
      a.mean.should == 3
    end
    
    it 'should return 0 for an empty array' do
      a = Array.new
      a.empty?.should be_true
      a.mean.should == 0
      a.empty?.should be_true
    end
  end
end