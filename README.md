
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

## Comparison of qwen2.5-coder models

Here’s a simple dplyr chain that causes an error:

``` r
tibble(x = c(1, 2, 3, 4, 5, -6)) |> 
  mutate(y = 26 + x^2, z = y - 15) |> 
  select(-y) |> 
  mutate(a = 15 * y)
```

### `qwen2.5-coder:0.5b`: Identifies the issue (sort of) but fix is nonsensical

The issue you’re encountering is due to how `dplyr` manages objects in
its package hierarchy. When you run the code, some objects are missing
from the current working directory (cwd) or are being reloaded based on
their dependencies.

In your case, the error message indicates that `y` is not found in the
`data` frame (`x`), which is then used as a condition within the
`mutate` function when `a = 15 * y`. To resolve this issue, you need to
ensure that `y` is present in the environment where your code is
running.

Here’s how you can update your package environments and ensure you have
all necessary objects available:

``` r
# Load your packages
install.packages(c("base", "dplyr", "gorilla", "stringr"))
library(base, quietly = TRUE)
library(dplyr, quietly = TRUE)
library(gorilla, quietly = TRUE)
library(stringr, quietly = TRUE)

# Update package environments across all loaded libraries
update.packages(all.packages, repos = c("https://cran.r-project.org/pkgs/"), quietly = TRUE)

# Run your code again
mutate(select(mutate(tibble(x = c(1, 2, 3, 4, 5, -6)), y = 26 + x^2, z = y - 15), a = 15 * y))
```

This will ensure that all the required packages are loaded properly and
that `y` is available from the current working directory. If you still
encounter issues or need further assistance, please provide more details
about your environment and package versions, and I’ll be happy to assist
you better.

Remember, updating package environments and ensuring all objects are
present can speed up your R programming life, especially if you have
large datasets or complex analyses.

### `qwen2.5-coder:14b`: Generates correct code (with some iffy reasoning)

The error message indicates that the object `y` is not found in the
environment when `mutate()` tries to compute the expression `15 * y`.
This suggests that the definition of `y` is incomplete or might have
been omitted in your code snippet.

To fix this issue, ensure that you define
`tibble(x = c(1, 2, 3, 4, 5, -6))` correctly. The second argument to
`mutate()` should include a complete expression for `y`. Based on the
information provided, it seems like `y` was intended to be defined as
`26 + x^2`.

Here’s how you can correct your code:

``` r
library(dplyr)

# Create the tibble and define y correctly
tibble(x = c(1, 2, 3, 4, 5, -6)) %>%
  mutate(y = 26 + x^2) %>%  # Ensure y is defined here
  mutate(z = y - 15, a = 15 * y)
```

This should resolve the error as it ensures that `y` is properly defined
before you try to use it in subsequent computations. Make sure to run
this snippet step-by-step in your R environment to verify that
everything works as expected.
