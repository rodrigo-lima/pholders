#!/usr/bin/env ruby

module DebugUtils

	def DebugUtils.debug_line (message)
		say(". <%= color('#{message}', YELLOW) %>") if $verbose
	end

	def DebugUtils.output_line (message)
		say("<%= color('#{message}', CYAN) %>") 
	end

	def DebugUtils.result_line (message)
		say("<%= color('#{message}', GREEN) %>") 
	end

	def DebugUtils.error_line (message)
		say("! <%= color('#{message}', RED) %> !") 
	end

end