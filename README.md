
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

### `qwen2.5-coder:1.5b`: Sort of understands error, code is useless

The error message is occurring because R was unable to find the variable
`y` in the environment where the mutate operation was performed. This
could be due to either:

- The `y` variable not being passed as an argument to the mutate
  function or a typo in the column name within the mutate function.

- The mutation code might be trying to manipulate `x` before accessing
  `y`, resulting in an attempt to access `y` when the value of `y`
  hasn’t been assigned yet.

To fix this issue, you can manually assign the value of `y` before
performing the mutate operation. Replace the error-prone line with:

``` r
y = 26 + x^2
mutate(tibble(x = c(1, 2, 3, 4, 5, -6)), y = y, z = y - 15)
a = 15 * y
```

This way, R can find the value of `y` before processing it in the mutate
operation.

### `qwen2.5-coder:3b`: Doesn’t understand error, still manages to fix it

The error you’re encountering is likely due to an issue within the
`tidyverse` family of packages as they integrate various functionalities
into a unified workflow. The code snippet you provided involves several
data manipulation operations using `dplyr`, which can sometimes lead to
unexpected behavior if not properly managed within your environment.

To resolve this issue, ensure that all required packages are loaded and
that your dataset is correctly defined at the time of operation. Here’s
how you can modify your code:

``` r
# Ensure all necessary packages are loaded
library(tidyverse)

# Define a tidy data frame with column x
x_df <- tibble(x = c(1, 2, 3, 4, 5, -6))

# Mutate the data frame to include y and z columns
x_df <- x_df %>%
  mutate(y = 26 + x^2) %>%
  mutate(z = y - 15)

# Compute column 'a' as 15 times y
x_df$a <- 15 * x_df$y

# Print the resulting data frame to verify changes
print(x_df)
```

This approach should resolve the error you’re encountering and allow you
to manipulate your dataset effectively within your R environment.

### `qwen2.5-coder:7b`: Better fix, still doesn’t understand error

The error you’re encountering is due to the `y` column being created
after you attempt to use it in the `mutate(a = 15 * y)` step. To fix
this, ensure that all columns used in subsequent operations are defined
before they are referenced.

Here’s how you can adjust your code:

``` r
data <- mutate(
  tibble(x = c(1, 2, 3, 4, 5, -6)), 
  y = 26 + x^2,
  z = y - 15
)
result <- mutate(data, a = 15 * y)
```

By separating the creation of `data` and `result`, you ensure that `y`
is available when you attempt to use it in the second
`mutate(a = 15 * y)` call.

If this doesn’t resolve your issue or if you need further assistance,
feel free to ask.

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

### `qwen2.5-coder:32b`: So close to getting it

The error you’re encountering is due to the fact that `y` is being used
in a `mutate()` context where it hasn’t been defined yet in the current
pipeline. In `dplyr`, when mutating columns, each new column is not
immediately available for use in subsequent operations within the same
`mutate()` call unless you chain them properly.

To fix this, you can break the `mutate()` calls into separate steps so
that `y` is defined before it’s used to calculate `a`. Here’s how you
can do it:

``` r
library(dplyr)
tibble(x = c(1, 2, 3, 4, 5, -6)) %>%
    mutate(y = 26 + x^2) %>%
    mutate(-y) %>% 
    mutate(a = 15 * y)
```

This code first calculates `y`, then negates it (though the `-y` step
doesn’t seem to be affecting `a`, so you might want to remove or adjust
it if not needed), and finally calculates `a` using the defined `y`. If
the negation of `y` is intended for use in another part of your
analysis, ensure that it fits logically within your data
transformations.

### `gpt-oss`: Success

`mutate()` evaluates its expressions in the order they are written and
inside a single call all the new columns are available to the subsequent
ones. In your code you nest two calls:

``` r
mutate(                                       # outer mutate
  select(                                     # inner SELECT
    mutate(tibble(x = c(1, 2, 3, 4, 5, -6)),  # create y and z
           y = 26 + x^2,
           z = y - 15),
    -y                                        # drop y
  ),
  a = 15 * y                                  # outer mutate tries to use y
)
```

The `select( … , -y)` removes the column **y** before the outer
`mutate()` tries to reference it, so R cannot find `y` and throws the
error.

**Fix:** create `a` before you drop `y`, or keep `y` in the data frame
until after you are done using it. A concise way is:

``` r
library(dplyr)

tibble(x = c(1, 2, 3, 4, 5, -6)) %>%
  mutate(
    y = 26 + x^2,
    z = y - 15,
    a = 15 * y
  ) %>%
  select(-y)          # drop y only after a is computed
```

This keeps `y` available for the calculation of `a`, then removes it
once it is no longer needed.
