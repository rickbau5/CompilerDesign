if exists("b:current_syntax")
    finish
endif

syn match Character /'.+'/
syn match Number '\d\+'
syn match Boolean 'true'
syn match Boolean 'false'
syn match Operator '[\+\-\=\>\<\!\?\*]'
syn match Operator 'and'
syn match Operator 'or' 
syn match Operator 'not'

syn keyword Keyword break return static
syn keyword Type bool char int
syn keyword Repeat while
syn keyword Conditional if else

syn match comment "//.*$" contains=Comment
