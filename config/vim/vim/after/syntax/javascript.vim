" Set line wrapping for comments to 80 characters
fun! AdjustWrapForLine()
   if !exists('s:lastLine') || line('.') != s:lastLine
      let s:lastLine = line(".")
      let matched = matchstr(getline('.'), '^\s*\/\=\(\*\|\/\)')

      if !empty(matched)
         set textwidth=90
      else
         set textwidth=120
      endif
   endif
endfun
autocmd CursorMoved * call AdjustWrapForLine()
" End of line wrapping config
