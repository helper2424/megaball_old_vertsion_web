# This file is used by Rack-based servers to start the application.

# Unicorn self-process killer
require 'unicorn/worker_killer'
# Max requests per worker
use Unicorn::WorkerKiller::MaxRequests, 7900, 8192
# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))

require 'unicorn/oob_gc'
use Unicorn::OobGC, 1500

require ::File.expand_path('../config/environment',  __FILE__)
run MegaballWeb::Application
