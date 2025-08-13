#' Get AI Help after an Error
#'
#' Call `ai()` to help you fix an error. This will stream LLM response to your console intended to help
#' understand and fix the error.  
#'
#' @return string
#' @export
ai <- function(){
  chat <- ellmer::chat_ollama(model = "gpt-oss:20B")
  x <- rlang::last_error()
  chat$chat(glue::glue("I ran {x$call[1]} and got the error {x$message[1]}. 
  I have {paste0(.packages(), collapse = ", ")} loaded currently. 
  I have this list of objects defined: {paste0(ls(), collapse = ", ")}.
  Can you help me fix this? I'm using R and I need a quick solution, 
  just one or two paragraphs."))
}