program define chatgpt_context
    version 15.0
    // Corrected syntax definition
    syntax varlist(name=variables), KEYOPENAI(string) [ALL] [Uptoerror]

    // Step 1: Validate API Key and Input Options
    local api_key = "`keyopenai'"
    if "`api_key'" == "" {
        di as err "API key is required. Please provide a valid OpenAI API key."
        exit 198
    }

    // Step 2: Error Handling and Log Capture
    if "`uptoerror'" != "" {
        tempfile log_temp
        quietly log using `log_temp', text replace

        // Replace with the actual path to your .do file
        capture noisily {
            do "your_do_file.do"  // <-- Replace with your actual .do file path
        }
        log close

        // Extract commands up to the last error
        local cmds = ""
        file open readlog using `log_temp', read
        while (r(eof) == 0) {
            file read readlog line
            if regexm("`line'", "replace_with_error_pattern") break
            local cmds "`cmds' `line'"
        }
        file close readlog
    }

    // Step 3: Generate Context from Variables
    local context = ""
    if "`variables'" != "" {
        describe `variables', short
        local context = r(result)
    } else if "`all'" != "" {
        ds, has(type numeric)
        local varlist `r(varlist)'
        describe `varlist', short
        local context = r(result)
    }

    // Step 4: Send Request to ChatGPT
    local command_text = "Explain the error in the following context: " + "`cmds'. " + "Also, provide suggestions to fix it."
    chatgpt talk, key_openai("`api_key'") command("`command_text'") stata

end
