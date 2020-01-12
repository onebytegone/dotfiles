" Set word wrap
set textwidth=90

" Color the column at the end of the word wrap
set colorcolumn=+1

" Increase length of commit summary guide
syn clear gitcommitSummary
syn match gitcommitSummary "^.\{0,72\}" contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflow contains=@Spell

" Color the column after the end of the commit summary
set colorcolumn+=73
