# rLoggerLoki

## Overview

`rLoggerLoki` is an R package that enables you to send log messages from your R environment to a Loki instance. It provides a simple interface to attach custom labels and traceback information, which aids in filtering and debugging. This package is particularly useful for centralized logging and monitoring in R-based applications.

## Installation

You can install rLoggerLoki from GitHub using `devtools`:

```
# install.packages("devtools")
devtools::install_github("ESCRI11/rLoggerLoki")
```

## Basic usage

### Send Logs to Loki

To send a log message to Loki, you need to specify the log message, custom labels, and Loki endpoint URL:

```
library(rLoggerLoki)

log_to_loki("This is a test log",
            list(app = "MyApp", level = "INFO"),
            "http://your-loki-instance:3100/loki/api/v1/push")
```

### Send Logs with Traceback Information

```
log_to_loki("This is an error",
            list(app = "MyApp", level = "ERROR"),
            "http://your-loki-instance:3100/loki/api/v1/push",
            trace = traceback(2, as.character = TRUE))
```

### Set Global Loki Endpoint

To avoid specifying the Loki endpoint every time you log a message, you can set it globally:

```
set_loki_endpoint("http://your-loki-instance:3100")
```

## License

MIT License. See [LICENSE.md](LICENSE.md) for more details.

