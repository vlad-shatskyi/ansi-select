module Ansi
  class Selector
    # @param [Array<#to_s>] options
    #
    # @return [#to_s] option
    def self.select(options)
      require_relative "selector/single_impl"

      SingleImpl.new(options).select
    end

    # @param [Array<#to_s>] options
    #
    # @return [Array<#to_s>] option
    def self.multi_select(options)
      require_relative "selector/multi_impl"

      MultiImpl.new(options).select
    end
  end
end
