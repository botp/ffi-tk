# frozen_string_literal: true
module Tk
  class LabelFrame < Frame
    include Cget, Configure

    def self.tk_command
      'labelframe'
    end
  end
end
