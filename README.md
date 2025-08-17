
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

If you don’t know where to start, `qwen2.5-coder:3b` is only 2 GB and
will run on almost any modern hardware. `qwen2.5-coder:7b` is around 5
GB. Bigger models will run slower and give better advice, as a general
rule. If you just want to see how the package works, you can download
`qwen2.5-coder:0.5b`, which is 400 MB. Once you get a sense for how
reliable and fast `qwen2.5-coder:0.5b` is, you can try bigger versions
of `qwen2.5-coder`, which are listed
[here](https://ollama.com/library/qwen2.5-coder). `gpt-oss:20b` is
better than all of these in my experience if you have the hardware to
run it. To download and run `qwen2.5-coder:0.5b`, use:

``` r
ollamar::pull('qwen2.5-coder:0.5b')
```

For detailed examples of model output, refer to:

``` r
vignette("model_comparison", package = "errbud")
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

### Output (this example from local qwen2.5-coder:7b)

It looks like you’re encountering an error because you’re trying to
subset a built-in function (`sum`) using `[`. Built-in functions in R
are not designed to be subsetted in this way.

If you want to access elements from a list or vector, make sure you use
the correct syntax for subsetting. For example:

``` r
# Assuming sum is a list, you can access its elements like this:
result <- sum[[1]]
```

However, if `sum` is indeed a built-in function and not a list or
vector, then there might be a misunderstanding. Could it be that `sum`
was mistakenly used as a variable name at some point in your code? In
that case, make sure you don’t override built-in functions with
user-defined variables.
