# frozen_string_literal: true
require_relative '../../helper'

describe Tk::PanedWindow do
  it 'initializes' do
    instance = Tk::PanedWindow.new
    instance.class.should == Tk::PanedWindow
    instance.tk_parent.should == Tk.root
  end

  it 'needs more specs' do
  end
end
