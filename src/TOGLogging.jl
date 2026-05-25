"We can remove logging once all is functioning well for your privacy."
module TOGLogging

export LOGS

using Logging

const LOGS = "logs"

struct Logger <: AbstractLogger
    console_logger::ConsoleLogger
    file_logger::SimpleLogger
end

Logging.min_enabled_level(logger::Logger) = min(Logging.min_enabled_level(logger.console_logger), Logging.min_enabled_level(logger.file_logger))
Logging.shouldlog(logger::Logger, level, _module, group, id) = Logging.shouldlog(logger.console_logger, level, _module, group, id) || Logging.shouldlog(logger.file_logger, level, _module, group, id)
Logging.handle_message(logger::Logger, level, message, _module, group, id, file, line; kwargs...) = begin
    message_str = "$(Threads.threadid())<$(time())> $message"
    Logging.handle_message(logger.console_logger, level, message_str, _module, group, id, file, line; kwargs...) # DEBUG
    Logging.handle_message(logger.file_logger, level, message_str, _module, group, id, file, line; kwargs...)
    flush(logger.file_logger.stream)
end

function awaken()
    !isdir(LOGS) && mkdir(LOGS)
    file_stream(x) = open(joinpath(LOGS, "$(time())-$x"), "a")
    file_logger = SimpleLogger(file_stream("tog.txt"), Logging.Info)
    console_logger = ConsoleLogger(stdout, Logging.Info)
    logger = Logger(console_logger, file_logger)
    global_logger(logger)
end

end
