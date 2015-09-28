module Ansi
  class Select
    # @param [Array<#to_s>] options
    #
    # @return [#to_s] option
    def self.select(options)
      require_relative "select/single_select_impl"

      SingleSelectImpl.new(options).select
    end

    # @param [Array<#to_s>] options
    #
    # @return [Array<#to_s>] option
    def self.multi_select(options)
      require_relative "select/multi_select_impl"

      MultiSelectImpl.new(options).select
    end
  end
end
