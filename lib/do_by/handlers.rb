require "do_by/handler/base"
require "do_by/handler/due_by"
require "do_by/handler/due_in"

module DoBy
  HANDLERS = [DoBy::Handler::DueIn, DoBy::Handler::DueBy, DoBy::Handler::DueBy2ndArgument]
  DEFAULT_HANDLER = DoBy::Handler::DueIn
end