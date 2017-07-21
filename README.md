# wren-stream-proposal

_A proposed reference API for wren streams, implemented in wren with no native optimisation._

These streams would be used to unify the interface for file/stdin/stdout/network reading and writing.

The hope is that once an API for the `Stream` class is decided on, a partially native implmentation can be made to improve performance.

A refference implementation can be found in `stream.wren`, and an example usage can be found in `main.wren`.

Please have a play about, and try to find any issues/improvments

Opening __Issues__ and creating __Pull Requests__ is highly encoraged (and in fact the only reason this repo exists)
