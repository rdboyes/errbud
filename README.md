
<!-- README.md is generated from README.Rmd. Please edit that file -->

# errbud <a href="https://github.com/rdboyes/errbud"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

<!-- badges: end -->

The goal of errbud is to make it easy for you to get help fixing R
errors from LLMs.

## Installation

You can install the development version of errbud from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("rdboyes/errbud")
```

## Installing Ollama

Ollama is required for this package to work. Install Ollama from their
site:

- [MacOS](https://ollama.com/download/mac)
- [Windows](https://ollama.com/download/windows)
- [Linux](https://ollama.com/download/linux)

``` sh
# linux install script
curl -fsSL https://ollama.com/install.sh | sh
```

Once Ollama is installed, (optionally) install `ollamar` to interact
with it from R.

``` r
pak::pak('ollamar')
```

If everything has worked correctly, you should be able to contact your
ollama server from inside R now:

``` r
ollamar::test_connection()

# Ollama local server running
# <httr2_response>
# GET http://localhost:11434/
# Status: 200 OK
# Content-Type: text/plain
# Body: In memory (17 bytes)
```

## Download and run a model

If you don’t know where to start, `qwen2.5-coder:0.5b` is only 400MB and
will run on almost any modern hardware. Bigger models will run slower
and give better advice, as a general rule. Once you get a sense for how
reliable and fast `qwen2.5-coder:0.5b` is, you can try bigger versions
of `qwen2.5-coder`, which are listed
[here](https://ollama.com/library/qwen2.5-coder). To download and run
`qwen2.5-coder:0.5b`, use:

``` r
ollamar::pull('qwen2.5-coder:0.5b')
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
sum[1]
```

![](/man/figures/error.png)

Call `ai()` to help explain what’s going on:

``` r
errbud::ai()
```

### Output (this example from local gpt-oss:20B)

The error “object of type ‘builtin’ is not subsettable” usually means
you called the subsetting operator `[ ]` without attaching it to a real
object (e.g., `x[1]` vs. just `[` or mis‑spelled a function name). R’s
`[` is an S3 generic that works on vector, matrix, data frame, list,
etc., and it expects an object on its left‑hand side. In your session
you only have the default packages loaded and three objects (`chat`,
`pkgs`, `x`). The fix is simply to provide a concrete object inside the
brackets. For example, if you want the first element of `x`, type
`x[1]`; if you want the element of `pkgs` whose name is stored in
`chat`, type `pkgs[chat]` (or `pkgs[[chat]]` if you need a single
element from a list). If you intended to use a different function (say
`subset` from base R or `filter` from `dplyr`), call that function
directly: `subset(x, condition)` or `dplyr::filter(df, condition)`. Once
`[` is attached to an actual object, the “builtin not subsettable” error
disappears.
