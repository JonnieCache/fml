require File.join(__dir__, 'lib/boot')
require File.join(ROOT_DIR, 'lib/db')

require 'app/controllers/tasks_controller'
require 'app/controllers/tags_controller'
require 'app/controllers/state_controller'
require 'app/controllers/root_controller'

use Rack::Static, urls: ["/assets"], root: "public"

map('/tasks') { run TasksController }
map('/tags')  { run TagsController }
map('/state') { run StateController }
map('/')      { run RootController }
