#' Get AI Help after an Error
#'
#' Call `ai()` to help you fix an error. This will stream LLM response to your console intended to help
#' understand and fix the error. Will default to your most recently installed model that is less than 16 GB in size 
#' (or, if you have less than 16 GB of RAM, less than your available RAM) if the option `"errbud_model"` 
#' is not set.
#'
#' @return string
#' @export
ai <- function(){
  model <- getOption("errbud_model", default = NULL)

  if (is.null(model)){
    mem_target <- min(16237037568, memuse::Sys.meminfo()$totalram |> as.numeric())
    models_available = ollamar::list_models() 
    fits = sapply(strsplit(x$size, " "), 
      FUN = \(x){as.numeric(x[1]) * 10e8 < mem_target || x[2] == "MB"})
    models_available = models_available[fits, ]
    newest <- which.max(lubridate::as_datetime(models_available$modified))
    model <- models_available$name[newest]
  }

  chat <- ellmer::chat_ollama(model = model)
  chat$chat(get_context_for_llm(followup = FALSE), echo = TRUE)
  return(invisible(NULL))
}

#' Copy Error with Information to Clipboard
#'
#' Call `aicopy()` to copy your error message and other information useful to LLMs to clipboard.
#' This could be pasted into ChatGPT or Claude (for example) in order to help you fix the error. 
#'
#' @return NULL
#' @export
aicopy <- function(){
  clipr::write_clip(get_context_for_llm(followup = TRUE))
  return(NULL)
}

get_context_for_llm <- function(followup){
  x <- rlang::last_error()

  code <- capture.output(x$call)
  message <- capture.output(x)

  session <- paste0(capture.output(sessionInfo()), collapse = "\n")
  objs <- tryCatch(paste0(ls(), collapse = ", "), error = \(x){" [none]"})
  
  if (followup){
    ending <- "I can provide more detail if you need it."
  } else {
    ending <- "No followup will be provided. Do not ask for clarification, do your best with the information available."
  }

  return(glue::glue("
  I ran {code} and got the error {message}. 
  
  I have this list of objects defined: {objs}.

  Can you help me fix this? I'm using the R programming language and I need a quick solution, 
  just one or two paragraphs. {ending}
  
  My sessionInfo is: 

  {session}"))
}