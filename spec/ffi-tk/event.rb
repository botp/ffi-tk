# frozen_string_literal: true
require_relative '../helper'

describe Tk::Event do
  it 'gives a list of defined virtual events' do
    Tk::Event.info.sort.unshift('<<Clear>>').uniq.should ==  [
      '<<Clear>>', '<<ContextMenu>>', '<<Copy>>', '<<Cut>>', '<<LineEnd>>', '<<LineStart>>', '<<NextChar>>', '<<NextLine>>', '<<NextPara>>', '<<NextWindow>>', '<<NextWord>>', '<<Paste>>', '<<PasteSelection>>', '<<PrevChar>>', '<<PrevLine>>', '<<PrevPara>>', '<<PrevWindow>>', '<<PrevWord>>', '<<Redo>>', '<<SelectAll>>', '<<SelectLineEnd>>', '<<SelectLineStart>>', '<<SelectNextChar>>', '<<SelectNextLine>>', '<<SelectNextPara>>', '<<SelectNextWord>>', '<<SelectNone>>', '<<SelectPrevChar>>', '<<SelectPrevLine>>', '<<SelectPrevPara>>', '<<SelectPrevWord>>', '<<ToggleSelection>>', '<<Undo>>'
    ]
    # tk-aqua: <<Clear>>, ...
  end

  it 'shows what sequences invoke a specific virtual event' do
    info = Tk::Event.info('<<Paste>>')
    info.should.is_a? Array
    %w(<Control-Key-v> <Mod1-Key-v>).should.include info.first
    # "<Control-Key-v>", "<Key-F18>", "<Control-Key-y>"
    # "<Control-Key-v>", "<Key-F18>", "<Control-Lock-Key-V>", "<Control-Key-y>"
    # tk-aqua: "<Mod1-Key-v>", "<Key-F4>", "<Control-Lock-Key-V>"
  end

  it 'adds a virtual event' do
    Tk::Event.add('<<Spec>>', '<Control-Alt-Key-Escape>')
    Tk::Event.info.should.include('<<Spec>>')
    Tk::Event.info('<<Spec>>').should == ['<Control-Alt-Key-Escape>']
  end

  it 'deletes a virtual event' do
    Tk::Event.delete('<<Spec>>', '<Control-Alt-Key-Escape>')
    Tk::Event.info.should.not.include('<<Spec>>')
    Tk::Event.info('<<Spec>>').should == []
  end

  it 'generates a virtual event and calls it' do
    Tk::Event.add('<<Clear>>', '<BackSpace>')

    entry = Tk::Entry.new('.')
    entry.bind('<<Clear>>') { entry.delete(0, :end) }
    entry.bind('<Map>') do
      Tk::Event.generate(entry, '<<Clear>>')
      Tk.interp.do_one_event
    end
    entry.insert 0, 'Hello, World!'
    entry.get.should == 'Hello, World!'

    entry.pack
    entry.focus

    Tk.interp.do_events_until do
      entry.get.empty?
    end

    entry.get.should == ''
  end

  it 'generates a virtual event and calls normal event' do
    Tk::Event.add('<<Clear>>', '<BackSpace>')

    entry = Tk::Entry.new('.')
    entry.bind('<<Clear>>') { entry.delete(0, :end) }
    entry.bind('<Map>') do
      entry.focus
      Tk::Event.generate(entry, '<BackSpace>')
      Tk.interp.do_one_event
    end
    entry.insert 0, 'Hello, World!'
    entry.get.should == 'Hello, World!'

    entry.pack
    entry.focus

    Tk.interp.do_events_until do
      entry.get.empty?
    end

    entry.get.should == ''
  end

  it 'associates event with button and calls it' do
    entered = false

    entry = Tk::Entry.new('.')
    entry.bind('<Key>') { entered = true; Tk.stop }
    entry.bind('<Map>') do
      entry.focus
      Tk::Event.generate(entry, '<KeyPress-a>')
    end

    entry.pack
    entry.focus

    Tk.interp.do_events_until do
      entered
    end

    entered.should == true
  end
end
