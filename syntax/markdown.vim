if exists("b:md_syntax_file_read") | finish | endif
let b:md_syntax_file_read = 1

" Vim syntax file
" Language:  Markdown
" Maintainer:  Ben Williams <benw@plasticboy.com>
" URL:    http://plasticboy.com/markdown-vim-mode/
" Remark:  Uses HTML syntax file
"
" Modified significantly by GVF (2018-11-25)

" Read the HTML syntax to start with
if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
  if exists('b:current_syntax')
    unlet b:current_syntax
  endif
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn spell toplevel
syn case ignore
syn sync linebreaks=1

" we can use conceal to hide some elements of markdown.  That's what the `execute` commands down there are about
let s:conceal = ''
let s:concealends = ''
if has('conceal') && get(g:, 'vim_markdown_conceal', 1)
  let s:conceal = ' conceal'
  let s:concealends = ' concealends'
endif

" additions to HTML groups
if get(g:, 'vim_markdown_emphasis_multiline', 1)
    let s:oneline = ''
else
    let s:oneline = ' oneline'
endif

" Underline
syn region mkdUnderline matchgroup=mkdUnderline start="\%(_\)"    end="\%(_\)"
execute 'syn region htmlUnderline matchgroup=mkdUnderline start="\%(^\|\s\)\zs_\ze[^\\_\t ]" end="[^\\_\t ]\zs_\ze\_W" keepend contains=@Spell' . s:oneline . s:concealends

" Italic
syn region mkdItalic matchgroup=mkdItalic start="\%(\*\)"    end="\%(\*\)"
execute 'syn region htmlItalic matchgroup=mkdItalic start="\%(^\|\s\)\zs\*\ze[^\\\*\t ]\%(\%([^*]\|\\\*\|\n\)*[^\\\*\t ]\)\?\*\_W" end="[^\\\*\t ]\zs\*\ze\_W" keepend contains=@Spell' . s:oneline . s:concealends

" Bold
syn region mkdBold matchgroup=mkdBold start="\%(\*\*\|__\)"    end="\%(\*\*\|__\)"
execute 'syn region htmlBold matchgroup=mkdBold start="\%(^\|\s\)\zs\*\*\ze\S" end="\S\zs\*\*" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBold matchgroup=mkdBold start="\%(^\|\s\)\zs__\ze\S" end="\S\zs__" keepend contains=@Spell' . s:oneline . s:concealends

" Bold Italic
syn region mkdBoldItalic matchgroup=mkdBoldItalic start="\%(\*\*\*\|___\)"    end="\%(\*\*\*\|___\)"
execute 'syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\%(^\|\s\)\zs\*\*\*\ze\S" end="\S\zs\*\*\*" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\%(^\|\s\)\zs___\ze\S" end="\S\zs___" keepend contains=@Spell' . s:oneline . s:concealends

" [link](URL) | [link][id] | [link][] | ![image](URL)
syn region mkdFootnotes matchgroup=mkdDelimiter start="\[^"    end="\]"
execute 'syn region mkdID matchgroup=mkdDelimiter    start="\["    end="\]" contained oneline' . s:conceal
execute 'syn region mkdURL matchgroup=mkdDelimiter   start="("     end=")"  contained oneline' . s:conceal
execute 'syn region mkdLink matchgroup=mkdDelimiter  start="\\\@<!!\?\[\ze[^]\n]*\n\?[^]\n]*\][[(]" end="\]" contains=@mkdNonListItem,@Spell nextgroup=mkdURL,mkdID skipwhite' . s:concealends

" Autolink without angle brackets.
" mkd  inline links:      protocol     optional  user:pass@  sub/domain                    .com, .co.uk, etc         optional port   path/querystring/hash fragment
"                         ------------ _____________________ ----------------------------- _________________________ ----------------- __
syn match   mkdInlineURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*/

" Autolink with parenthesis.
syn region  mkdInlineURL matchgroup=mkdDelimiter start="(\(https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*)\)\@=" end=")"

" Autolink with angle brackets.
syn region mkdInlineURL matchgroup=mkdDelimiter start="\\\@<!<\ze[a-z][a-z0-9,.-]\{1,22}:\/\/[^> ]*>" end=">"

" Link definitions: [id]: URL (Optional Title)
syn region mkdLinkDef matchgroup=mkdDelimiter   start="^ \{,3}\zs\[\^\@!" end="]:" oneline nextgroup=mkdLinkDefTarget skipwhite
syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+"+     end=+"+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+'+     end=+'+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+(+     end=+)+  contained

"HTML headings starting with pound signs
syn region htmlH1         start="^\s*#"                   end="$" contains=@Spell
syn region htmlH2         start="^\s*##"                  end="$" contains=@Spell
syn region htmlH3         start="^\s*###"                 end="$" contains=@Spell
syn region htmlH4         start="^\s*####"                end="$" contains=@Spell
syn region htmlH5         start="^\s*#####"               end="$" contains=@Spell
syn region htmlH6         start="^\s*######"              end="$" contains=@Spell

" HTML heading underlined with equals or minus
syn match  htmlH1       /^.\+\n=\+$/ contains=mkdLink,mkdInlineURL,@Spell
syn match  htmlH2       /^.\+\n-\+$/ contains=mkdLink,mkdInlineURL,@Spell

" GVF Trailing space is interpreted by markdown as a line break so mark it as an error
syn match  mkdTrailingSpace    /  \+$/ contained

" GVF double space after period, colon, question mark, exclamation.  Trying to stop this so make it an error
syn match mkdDoubleSpace       /[.?;!:]  / contained

" Blockquote beginning with greater than sign
syn region mkdBlockquote   start=/^\s*>/                   end=/$/ contains=mkdLink,mkdInlineURL,mkdTrailingSpace,mkdDoubleSpace,@Spell

" Footnote in square brackets
syn region mkdFootnote     start="\[^"                     end="\]"

" inline code surrounded by tick marks
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!`/                     end=/\(\([^\\]\|^\)\\\)\@<!`/'  . s:concealends

" block code surrounded by three tick marks (GVF both of these needed, and in this order)
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!``/ skip=/[^`]`[^`]/   end=/\(\([^\\]\|^\)\\\)\@<!``/' . s:concealends
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start=/^\s*\z(`\{3,}\)[^`]*$/                       end=/^\s*\z1`*\s*$/'            . s:concealends

" block code surrounded by three tilde (GVF both of these needed, and in this order)
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!\~\~/  end=/\(\([^\\]\|^\)\\\)\@<!\~\~/'               . s:concealends
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start=/^\s*\z(\~\{3,}\)\s*[0-9A-Za-z_+-]*\s*$/      end=/^\s*\z1\~*\s*$/'           . s:concealends

" block code using <code> or <pre>
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start="<pre[^>]*\\\@<!>"                            end="</pre>"'                   . s:concealends
execute 'syn region mkdCode matchgroup=mkdCodeDelimiter start="<code[^>]*\\\@<!>"                           end="</code>"'                  . s:concealends

" code starting with 4 or 8 spaces but only if there is a blank line before it
syn match  mkdCode         /^\s*\n\(\(\s\{8,}[^ ]\|\t\t\+[^\t]\).*\n\)\+/
syn match  mkdCode         /\%^\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/
syn match  mkdCode         /^\s*\n\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/

" GVF I also want code to start with four spaces even if the line before is not empty
" GVF removed this because it prevents good indenting
" syn match  mkdCode          /^\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/

" bullet
syn match  mkdListItem     /^\s*\%([-*+]\|\d\+\.\)\ze\s\+/ contained

" numbered list
syn region mkdListItemLine start="^\s*\%([-*+]\|\d\+\.\)\s\+" end="$" oneline contains=@mkdNonListItem,mkdListItem,@Spell

"" GVF is this everything that's not in a list?
"" Can I delete this?
"syn region mkdNonListItemBlock start="\(\%^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@!\|\n\(\_^\_$\|\s\{4,}[^ ]\|\t+[^\t]\)\@!\)" end="^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@=" contains=@mkdNonListItem,@Spell

" GVF make stuff in tables bold
syn match mkdTableContent /|\zs[^|]\{1,}\ze|/ contains=mkdCode

" rule
syn match  mkdRule         /^\s*\*\s\{0,1}\*\s\{0,1}\*\(\*\|\s\)*$/
syn match  mkdRule         /^\s*-\s\{0,1}-\s\{0,1}-\(-\|\s\)*$/
syn match  mkdRule         /^\s*_\s\{0,1}_\s\{0,1}_\(_\|\s\)*$/

if get(g:, 'vim_markdown_math', 0)
  syn include @tex syntax/tex.vim
  syn region mkdMath start="\\\@<!\$" end="\$" skip="\\\$" contains=@tex keepend
  syn region mkdMath start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@tex keepend
endif

syn cluster mkdNonListItem contains=@htmlTop,htmlItalic,htmlUnderline,htmlBold,htmlBoldItalic,mkdFootnotes,mkdInlineURL,mkdLink,mkdLinkDef,mkdDoubleSpace,mkdTrailingSpace,mkdBlockquote,mkdCode,mkdRule,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6,mkdMath

" string and code are red
HtmlHiLink mkdString         String
HtmlHiLink mkdCode           String
HtmlHiLink mkdCodeDelimiter  String
HtmlHiLink mkdCodeStart      String
HtmlHiLink mkdCodeEnd        String
HtmlHiLink markdownCodeBlock String

" blockquotes and footnotes are blue
HtmlHiLink mkdFootnote       Comment
HtmlHiLink mkdBlockquote     Comment

" make table content bold

" light blue for list stars and rules
HtmlHiLink mkdListItem       Identifier
HtmlHiLink mkdRule           Identifier

" colors of parts of links
HtmlHiLink mkdFootnotes      htmlLink
HtmlHiLink mkdLink           htmlLink
HtmlHiLink mkdURL            htmlString
HtmlHiLink mkdInlineURL      htmlLink
HtmlHiLink mkdLinkDef        mkdID
HtmlHiLink mkdLinkDefTarget  mkdURL
HtmlHiLink mkdLinkTitle      htmlString
HtmlHiLink mkdDelimiter      Delimiter
HtmlHiLink mkdID             Identifier

" GVF trailing space is a line break in markdown.  I don't use it so mark it an error
HtmlHiLink mkdTrailingSpace      Error

" GVF double space after period,colon, etc. is an error
HtmlHiLink mkdDoubleSpace      Error

" GVF color overrides for titles (yellow and magenta)
hi htmlH1 ctermfg=yellow cterm=bold,underline
hi htmlH2 ctermfg=207
hi htmlH3 ctermfg=207
hi htmlH4 ctermfg=207

" GVF color override for String (code) to make it red
hi String ctermfg=09

" GVF make table content bold
hi mkdTableContent ctermfg=03 cterm=bold

" GVF color overrides for emphasis (light blue)
high htmlUnderline ctermfg=14
high htmlBold ctermfg=14
high htmlItalic ctermfg=14
high htmlBoldItalic ctermfg=14

" GVF color overrides for lists (bold yellow for list number or symbol)
hi Identifier ctermfg=11 cterm=bold

let b:current_syntax = "mkd"

delcommand HtmlHiLink
" vim: ts=8
