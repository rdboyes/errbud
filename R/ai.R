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
    fits = sapply(strsplit(models_available$size, " "), 
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

  code <- paste0(utils::capture.output(x$call), collpase = "\n")
  message <- paste0(utils::capture.output(x), collapse = "\n")

  session <- utils::sessionInfo()
  version <- session$R.version$version.string
  basepkgs <- paste0(session$basePkgs, collapse = ", ")
  loaded <- paste0(names(session$otherPkgs), collapse = ", ")
  platform <- session$platform


  objs <- tryCatch(paste0(ls(), collapse = ", "), error = \(x){" [none]"})
  
  if (followup){
    ending <- "I can provide more detail if you need it. You can suggest R commands to run that would get the information you need."
  } else {
    ending <- "No followup will be provided. Do not ask for clarification, do your best with the information available."
  }

  return(glue::glue("
  I ran the code '{code}' and got the error:
  
  {message} 
  
  I have this list of objects defined: {objs}.

  I have the following base packages loaded: {basepkgs}

  I have the following other packages loaded: {loaded}

  Can you help me fix this? I'm using the R programming language version {version} on {platform} and I need a quick solution, 
  just one or two paragraphs. {ending}"))
}