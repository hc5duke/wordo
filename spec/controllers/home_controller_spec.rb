require 'spec_helper'

describe HomeController do
  describe '#analyze' do
    it 'analyze image' do
      post :analyze
    end
  end
end
