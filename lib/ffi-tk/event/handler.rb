# frozen_string_literal: true
module Tk
  module Event
    module Handler
      data = Data::PROPERTIES.transpose[0].join(' ').gsub(/%/, '%%')
      @callback = %(bind %s %s { ::RubyFFI::event %d %s #{data} })
      @store = []
      @bound = {}
      @mutex = Mutex.new

      module_function

      def invoke(id, event)
        return unless found = @store.at(id)
        found.call(event)
      end

      def register_block(block)
        id = nil

        @mutex.synchronize do
          @store << block
          id = @store.size - 1
        end

        id
      end

      def register(tag, sequence, &block)
        id = register_block(block)
        if sequence.to_s == '%'
          Tk.interp.eval(
            @callback % [tag, '%%'.to_tcl, id, '%%'.to_tcl]
          )
        else
          Tk.interp.eval(
            @callback % [tag, sequence.to_tcl, id, sequence.to_tcl]
          )
        end
        @bound[[tag, sequence]] = block
        id
      end

      def register_custom(block)
        id = register_block(block)
        yield id
        id
      end

      def unregister(tag, sequence)
        key = [tag, sequence]

        if block = @bound[key]
          Tk.execute(:bind, tag, sequence, nil)
          id = @store.index(block)
          @store[id] = nil
          @bound.delete(key)
        end
      end
    end
  end
end
