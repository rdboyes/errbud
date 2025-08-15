#' Get AI Help after an Error
#'
#' Call `ai()` to help you fix an error. This will stream LLM response to your console intended to help
#' understand and fix the error.  
#'
#' @return string
#' @export
ai <- function(){
  chat <- ellmer::chat_ollama(model = "gpt-oss:20B")
  chat$chat(get_context_for_llm())
}

#' Copy Error with Information to Clipboard
#'
#' Call `aicopy()` to copy your error message and other information useful to LLMs to clipboard.
#' This could be pasted into ChatGPT or Claude in order to help you fix the error. 
#'
#' @return NULL
#' @export
aicopy <- function(){
  clipr::write_clip(get_context_for_llm())
  return(NULL)
}

get_context_for_llm <- function(){
  x <- rlang::last_error()

  code <- capture.output(x$call)
  message <- capture.output(x)

  pkgs <- tryCatch(paste0(.packages(), collapse = ", "), error =\(x){"no packages"})
  objs <- tryCatch(paste0(ls(), collapse = ", "), error = \(x){" [none]"})

  return(glue::glue("I ran {code} and got the error {message}. 
  I have {pkgs} loaded currently. 
  I have this list of objects defined: {objs}.
  Can you help me fix this? I'm using the R programming language and I need a quick solution, 
  just one or two paragraphs."))
}