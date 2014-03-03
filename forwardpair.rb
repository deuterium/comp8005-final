=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    forwardpair.rb - 
--
--  Class:          ForwardPair
--
--  DATE:           March 3, 2014
--
--  REVISIONS:      See development repo: https://github.com/deuterium/comp8005-final
--
--  DESIGNERS:      Chris Wood - chriswood.ca@gmail.com
--
--  PROGRAMMERS:    Chris Wood - chriswood.ca@gmail.com
--
--  NOTES:
--  
---------------------------------------------------------------------------------------
=end

class ForwardPair
    attr_accessor :remote_out_port, :remote_in_port, :internal_in_port, :internal_out_port
    def initialize(remote_out, remote_in, internal_out, internal_in)
        @remote_out_port = remote_out
        @remote_in_port = remote_in
        @internal_out_port = internal_out
        @internal_in_port = internal_in
    end
end