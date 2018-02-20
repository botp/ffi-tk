# frozen_string_literal: true
module Tk
  module Cget
    CGET_MAP = {}

    insert = lambda do |type, array|
      array.each { |option| CGET_MAP["-#{option}"] = type }
    end

    insert[:integer, %w(
      height width maxundo spacing1 spacing2 spacing3 borderwidth bd
      highlightthickness insertborderwidth insertofftime insertontime
      insertwidth padx pady selectborderwidth endline startline length
      maximum
    )]
    insert[:boolean, %w(
      autoseparators blockcursor undo exportselection setgrid takefocus
    )]
    insert[:color, %w(
      inactiveselectbackground disabledbackground disabledforeground background
      bg foreground fg highlightbackground highlightcolor insertbackground
      selectbackground selectforeground readonlybackground
    )]
    insert[:command, %w(
      invalidcommand invcmd yscrollcommand xscrollcommand validatecommand
      command vcmd
    )]
    insert[:string, %w(tabs cursor text show default class)]
    insert[:font, %w(font)]
    insert[:symbol, %w(wrap tabstyle relief justify validate orient mode selectmode)]
    insert[:variable, %w(textvariable)]
    insert[:bitmap, %w(stipple)]
    insert[:list, %w(padding state style columns displaycolumns)]

    def cget(option)
      option = option.to_tcl_option
      Cget.option_to_ruby(option, execute('cget', option))
    end

    module_function

    def option_to_ruby(name, value)
      if type = CGET_MAP[name.to_tcl_option]
        type_to_ruby(type, value)
      else
        raise 'Unknown type for %p: %p' % [name, value]
      end
    end

    def type_to_ruby(type, value)
      case type
      when :integer
        value.respond_to?(:to_i?) ? value.to_i? : value.to_i
      when :symbol
        value&.to_sym
      when :boolean
        Tk.boolean(value)
      when :color, :string, :font, :bitmap
        value.respond_to?(:to_s?) ? value.to_s? : value
      when :variable
        Variable.new(value.to_s?) if value.respond_to?(:to_s?)
      when :list
        case value
        when Array
          value
        when String
          value.split
        else
          value.to_a
        end
      when :float
        value.to_f
      when :pathname
        Tk.pathname_to_widget(value.to_s)
      when :command
        string = value.to_s
        string unless string.empty?
      else
        raise 'Unknown type: %p: %p' % [type, value]
      end
    end

    def option_hash_to_tcl(hash)
      result = {}

      hash.each do |key, value|
        case type = CGET_MAP[option = key.to_tcl_option]
        when :command
          command = register_command(key, &value)
          result[option] = command
        else
          result[option] = value
        end
      end

      result
    end
  end
end
